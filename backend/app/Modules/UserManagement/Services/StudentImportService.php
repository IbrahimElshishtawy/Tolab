<?php

namespace App\Modules\UserManagement\Services;

use App\Core\Enums\UserRole;
use App\Core\Exceptions\ApiException;
use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Models\Section;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\UserManagement\Imports\StudentSpreadsheetImport;
use App\Modules\UserManagement\Models\StudentProfile;
use App\Modules\UserManagement\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Maatwebsite\Excel\HeadingRowImport;
use Symfony\Component\HttpFoundation\Response;

class StudentImportService
{
    private const REQUIRED_COLUMNS = [
        'student_name',
        'university_email',
        'national_id',
        'department_name',
        'section_name',
        'grade_year',
    ];

    public function __construct(
        protected AuditLogService $auditLogService,
    ) {
    }

    public function import(UploadedFile $file, User $actor): array
    {
        $headings = $this->readHeadings($file);
        $missingColumns = array_values(array_diff(self::REQUIRED_COLUMNS, $headings));

        if ($missingColumns !== []) {
            throw new ApiException(
                'The uploaded file is missing required student columns.',
                ['file' => array_map(fn (string $column) => "Missing column: {$column}", $missingColumns)],
                Response::HTTP_UNPROCESSABLE_ENTITY
            );
        }

        $import = new StudentSpreadsheetImport();
        $import->import($file);

        $rows = $import->rows
            ->map(fn ($row) => collect($row)->map(fn ($value) => is_string($value) ? trim($value) : $value)->all())
            ->filter(fn (array $row) => collect($row)->filter(fn ($value) => $value !== null && $value !== '')->isNotEmpty())
            ->values();

        $report = [
            'total_rows' => $rows->count(),
            'imported_rows' => 0,
            'updated_rows' => 0,
            'failed_rows' => 0,
            'errors' => [],
        ];

        $rows->each(function (array $row, int $index) use (&$report) {
            $rowNumber = $index + 2;
            $normalized = $this->normalizeRow($row);

            $validator = Validator::make($normalized, [
                'student_name' => ['required', 'string', 'max:180'],
                'university_email' => ['required', 'email:rfc', 'max:180'],
                'national_id' => ['required', 'regex:/^\d{14}$/'],
                'department_name' => ['required', 'string', 'max:150'],
                'section_name' => ['required', 'string', 'max:150'],
                'grade_year' => ['required', 'integer', 'between:1,8'],
                'student_code' => ['nullable', 'string', 'max:50'],
                'gpa' => ['nullable', 'numeric', 'between:0,4'],
            ]);

            if ($validator->fails()) {
                $report['failed_rows']++;
                $report['errors'][] = [
                    'row' => $rowNumber,
                    'email' => $normalized['university_email'] ?? null,
                    'errors' => $validator->errors()->toArray(),
                ];

                return;
            }

            try {
                $wasCreated = DB::transaction(fn () => $this->upsertStudent($normalized));

                if ($wasCreated) {
                    $report['imported_rows']++;
                } else {
                    $report['updated_rows']++;
                }
            } catch (\Throwable $exception) {
                report($exception);

                $report['failed_rows']++;
                $report['errors'][] = [
                    'row' => $rowNumber,
                    'email' => $normalized['university_email'] ?? null,
                    'errors' => [
                        'row' => [$exception->getMessage()],
                    ],
                ];
            }
        });

        $this->auditLogService->log($actor, 'students.import', null, [
            'total_rows' => $report['total_rows'],
            'imported_rows' => $report['imported_rows'],
            'updated_rows' => $report['updated_rows'],
            'failed_rows' => $report['failed_rows'],
        ], request());

        return $report;
    }

    protected function upsertStudent(array $row): bool
    {
        $student = $this->resolveStudent($row);
        $department = $this->resolveDepartment($row['department_name']);
        $section = $this->resolveSection($department, $row['section_name'], (int) $row['grade_year']);

        $attributes = [
            'role' => UserRole::STUDENT,
            'role_type' => 'student',
            'username' => $row['student_name'],
            'full_name' => $row['student_name'],
            'email' => $row['university_email'],
            'university_email' => $row['university_email'],
            'national_id' => $row['national_id'],
            'is_active' => $student?->is_active ?? true,
        ];

        if ($student === null) {
            $student = User::query()->create([
                ...$attributes,
                'password_hash' => $row['national_id'],
            ]);
            $wasCreated = true;
        } else {
            $student->fill($attributes);

            if (! $student->password_hash) {
                $student->password_hash = $row['national_id'];
            }

            $student->save();
            $wasCreated = false;
        }

        StudentProfile::query()->updateOrCreate(
            ['user_id' => $student->id],
            [
                'student_code' => $row['student_code'] ?: null,
                'gpa' => $row['gpa'],
                'grade_year' => $row['grade_year'],
                'department_id' => $department->id,
                'section_id' => $section->id,
            ]
        );

        return $wasCreated;
    }

    protected function resolveStudent(array $row): ?User
    {
        $candidateIds = collect();

        $email = $row['university_email'];
        $candidateIds = $candidateIds->merge(
            User::query()
                ->where('role', UserRole::STUDENT->value)
                ->where(function ($query) use ($email) {
                    $query->whereRaw('LOWER(university_email) = ?', [$email])
                        ->orWhereRaw('LOWER(email) = ?', [$email]);
                })
                ->pluck('id')
        );

        $candidateIds = $candidateIds->merge(
            User::query()
                ->where('role', UserRole::STUDENT->value)
                ->where('national_id', $row['national_id'])
                ->pluck('id')
        );

        if ($row['student_code']) {
            $candidateIds = $candidateIds->merge(
                StudentProfile::query()
                    ->where('student_code', $row['student_code'])
                    ->pluck('user_id')
            );
        }

        $candidateIds = $candidateIds->filter()->unique()->values();

        if ($candidateIds->count() > 1) {
            throw new \RuntimeException('The row conflicts with multiple existing student records.');
        }

        if ($candidateIds->isEmpty()) {
            return null;
        }

        return User::query()
            ->with('studentProfile')
            ->find($candidateIds->first());
    }

    protected function resolveDepartment(string $departmentName): Department
    {
        return Department::query()->firstOrCreate(
            ['name' => $departmentName],
            ['is_active' => true]
        );
    }

    protected function resolveSection(Department $department, string $sectionName, int $gradeYear): Section
    {
        return Section::query()->firstOrCreate(
            [
                'department_id' => $department->id,
                'name' => $sectionName,
                'grade_year' => $gradeYear,
            ],
            [
                'code' => Str::upper(Str::slug($department->name.'-'.$sectionName.'-'.$gradeYear, '-')),
                'is_active' => true,
            ]
        );
    }

    protected function normalizeRow(array $row): array
    {
        return [
            'student_name' => $this->normalizeString($row['student_name'] ?? null),
            'university_email' => $this->normalizeEmail($row['university_email'] ?? null),
            'national_id' => $this->normalizeNationalId($row['national_id'] ?? null),
            'department_name' => $this->normalizeString($row['department_name'] ?? null),
            'section_name' => $this->normalizeString($row['section_name'] ?? null),
            'grade_year' => is_numeric($row['grade_year'] ?? null) ? (int) $row['grade_year'] : null,
            'student_code' => $this->normalizeString($row['student_code'] ?? null),
            'gpa' => is_numeric($row['gpa'] ?? null) ? round((float) $row['gpa'], 2) : null,
        ];
    }

    protected function readHeadings(UploadedFile $file): array
    {
        $headings = (new HeadingRowImport())->toArray($file);

        return collect($headings[0][0] ?? [])
            ->filter()
            ->values()
            ->all();
    }

    protected function normalizeEmail(mixed $value): ?string
    {
        if (! is_string($value) || trim($value) === '') {
            return null;
        }

        return Str::lower(trim($value));
    }

    protected function normalizeNationalId(mixed $value): ?string
    {
        if ($value === null) {
            return null;
        }

        $normalized = preg_replace('/\D+/', '', (string) $value);

        return $normalized !== '' ? $normalized : null;
    }

    protected function normalizeString(mixed $value): ?string
    {
        if (! is_string($value) && ! is_numeric($value)) {
            return null;
        }

        $normalized = trim((string) $value);

        return $normalized !== '' ? $normalized : null;
    }
}
