<?php

namespace App\Modules\Enrollment\Services;

use App\Core\Enums\GroupMemberRole;
use App\Core\Enums\UserRole;
use App\Core\Exceptions\ApiException;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\Group\Models\GroupMember;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\UserManagement\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

class EnrollmentService
{
    public function __construct(protected AuditLogService $auditLogService)
    {
    }

    public function paginateAdmin(array $filters, int $perPage): LengthAwarePaginator
    {
        return $this->baseQuery($filters)
            ->paginate($perPage)
            ->withQueryString();
    }

    public function lookups(): array
    {
        $students = User::query()
            ->where('role', UserRole::STUDENT->value)
            ->with('studentProfile')
            ->orderBy('username')
            ->get()
            ->map(fn (User $student) => [
                'id' => $student->id,
                'name' => $student->username,
                'email' => $student->email,
                'department_name' => $student->studentProfile?->department?->name ?? 'Department',
                'section_name' => $student->studentProfile?->section?->name ?? 'Section',
                'level_label' => $student->studentProfile?->level ? 'Level '.$student->studentProfile->level : 'Level',
            ])
            ->values();

        $offerings = CourseOffering::query()
            ->withCount('enrollments')
            ->with([
                'subject.department',
                'section.department',
                'doctor',
                'ta',
            ])
            ->orderByDesc('created_at')
            ->get()
            ->map(function (CourseOffering $offering) {
                $capacity = max($offering->enrollments_count + 8, 40);

                return [
                    'id' => $offering->id,
                    'course' => [
                        'id' => $offering->subject_id,
                        'code' => $offering->subject?->code,
                        'name' => $offering->subject?->name,
                        'department_name' => $offering->subject?->department?->name,
                    ],
                    'section' => [
                        'id' => $offering->section_id,
                        'name' => $offering->section?->name,
                        'department_name' => $offering->section?->department?->name,
                        'capacity' => $capacity,
                        'occupancy' => $offering->enrollments_count,
                    ],
                    'department_name' => $offering->section?->department?->name ?? $offering->subject?->department?->name ?? 'Department',
                    'semester' => $offering->semester,
                    'academic_year' => $offering->academic_year,
                    'doctor' => $offering->doctor ? [
                        'id' => $offering->doctor->id,
                        'name' => $offering->doctor->username,
                        'email' => $offering->doctor->email,
                        'role' => 'Doctor',
                    ] : null,
                    'assistant' => $offering->ta ? [
                        'id' => $offering->ta->id,
                        'name' => $offering->ta->username,
                        'email' => $offering->ta->email,
                        'role' => 'Assistant',
                    ] : null,
                    'capacity' => $capacity,
                    'occupancy' => $offering->enrollments_count,
                ];
            })
            ->values();

        $doctors = User::query()
            ->where('role', UserRole::DOCTOR->value)
            ->orderBy('username')
            ->get()
            ->map(fn (User $user) => [
                'id' => $user->id,
                'name' => $user->username,
                'email' => $user->email,
                'role' => 'Doctor',
                'department_name' => $user->staffProfile?->department?->name ?? 'Department',
            ])
            ->values();

        $assistants = User::query()
            ->where('role', UserRole::TA->value)
            ->orderBy('username')
            ->get()
            ->map(fn (User $user) => [
                'id' => $user->id,
                'name' => $user->username,
                'email' => $user->email,
                'role' => 'Assistant',
                'department_name' => $user->staffProfile?->department?->name ?? 'Department',
            ])
            ->values();

        return [
            'students' => $students,
            'offerings' => $offerings,
            'doctors' => $doctors,
            'assistants' => $assistants,
            'semesters' => $offerings->pluck('semester')->filter()->unique()->values()->all(),
            'academic_years' => $offerings->pluck('academic_year')->filter()->unique()->values()->all(),
        ];
    }

    public function summary(array $filters): array
    {
        $records = $this->baseQuery($filters)->get();
        $courseSummary = $records
            ->groupBy(fn (Enrollment $enrollment) => ($enrollment->courseOffering?->subject?->code ?? 'COURSE').' • '.($enrollment->courseOffering?->subject?->name ?? 'Untitled course'))
            ->map(function (Collection $items, string $courseLabel) {
                return [
                    'course_label' => $courseLabel,
                    'enrolled_count' => $items->where('status', 'enrolled')->count(),
                    'pending_count' => $items->where('status', 'pending')->count(),
                    'rejected_count' => $items->where('status', 'rejected')->count(),
                ];
            })
            ->sortByDesc(fn (array $item) => $item['enrolled_count'] + $item['pending_count'] + $item['rejected_count'])
            ->values();

        $sectionSummary = $records
            ->groupBy('course_offering_id')
            ->map(function (Collection $items) {
                /** @var Enrollment|null $sample */
                $sample = $items->first();
                $occupied = $items->where('status', '!=', 'rejected')->count();
                $capacity = max($occupied + 8, 40);

                return [
                    'section_name' => $sample?->courseOffering?->section?->name ?? 'Section',
                    'course_label' => ($sample?->courseOffering?->subject?->code ?? 'COURSE').' • '.($sample?->courseOffering?->subject?->name ?? 'Untitled course'),
                    'occupied' => $occupied,
                    'capacity' => $capacity,
                ];
            })
            ->sortByDesc(fn (array $item) => $item['capacity'] > 0 ? $item['occupied'] / $item['capacity'] : 0)
            ->values();

        $averageOccupancy = $sectionSummary->isEmpty()
            ? 0
            : round($sectionSummary->avg(fn (array $item) => $item['capacity'] > 0 ? $item['occupied'] / $item['capacity'] : 0), 4);

        return [
            'total_enrollments' => $records->count(),
            'enrolled_count' => $records->where('status', 'enrolled')->count(),
            'pending_count' => $records->where('status', 'pending')->count(),
            'rejected_count' => $records->where('status', 'rejected')->count(),
            'average_occupancy' => $averageOccupancy,
            'course_summary' => $courseSummary->all(),
            'section_summary' => $sectionSummary->all(),
            'status_breakdown' => [
                ['status' => 'enrolled', 'count' => $records->where('status', 'enrolled')->count()],
                ['status' => 'pending', 'count' => $records->where('status', 'pending')->count()],
                ['status' => 'rejected', 'count' => $records->where('status', 'rejected')->count()],
            ],
        ];
    }

    public function create(array $payload, User $actor): Enrollment
    {
        return DB::transaction(function () use ($payload, $actor) {
            $student = User::query()->findOrFail($payload['student_user_id']);
            $this->ensureStudent($student);

            $attributes = $this->normalizePayload($payload);
            $enrollment = Enrollment::query()->firstOrNew([
                'student_user_id' => $attributes['student_user_id'],
                'course_offering_id' => $attributes['course_offering_id'],
            ]);
            $enrollment->fill($attributes);
            $enrollment->save();

            $this->loadEnrollmentRelations($enrollment);
            $this->ensureGroupMembership($enrollment->courseOffering, $student);
            $this->auditLogService->log($actor, 'enrollment.create', $enrollment, [], request());

            return $enrollment;
        });
    }

    public function update(Enrollment $enrollment, array $payload, User $actor): Enrollment
    {
        return DB::transaction(function () use ($enrollment, $payload, $actor) {
            $previousOfferingId = $enrollment->course_offering_id;
            $previousStudentId = $enrollment->student_user_id;

            $student = User::query()->findOrFail($payload['student_user_id']);
            $this->ensureStudent($student);

            $attributes = $this->normalizePayload($payload);
            $enrollment->fill($attributes);
            $enrollment->save();

            if ($previousOfferingId !== $enrollment->course_offering_id || $previousStudentId !== $enrollment->student_user_id) {
                $previousOffering = CourseOffering::query()->find($previousOfferingId);
                if ($previousOffering) {
                    $this->removeGroupMembership($previousOffering, (int) $previousStudentId);
                }
            }

            $this->loadEnrollmentRelations($enrollment);
            $this->ensureGroupMembership($enrollment->courseOffering, $student);
            $this->auditLogService->log($actor, 'enrollment.update', $enrollment, [], request());

            return $enrollment;
        });
    }

    public function bulkCreate(array $payload, User $actor): array
    {
        $items = [];

        DB::transaction(function () use ($payload, $actor, &$items) {
            foreach ($payload['enrollments'] as $enrollmentPayload) {
                $items[] = $this->create($enrollmentPayload, $actor);
            }
        });

        return $items;
    }

    public function delete(Enrollment $enrollment, User $actor): void
    {
        DB::transaction(function () use ($enrollment, $actor) {
            $this->loadEnrollmentRelations($enrollment);
            $this->removeGroupMembership($enrollment->courseOffering, $enrollment->student_user_id);

            $this->auditLogService->log($actor, 'enrollment.delete', $enrollment, [], request());
            $enrollment->delete();
        });
    }

    protected function baseQuery(array $filters): Builder
    {
        $query = Enrollment::query()
            ->with([
                'student.studentProfile.department',
                'student.studentProfile.section',
                'courseOffering.subject.department',
                'courseOffering.section.department',
                'courseOffering.doctor',
                'courseOffering.ta',
            ]);

        if ($search = trim((string) ($filters['search'] ?? ''))) {
            $query->where(function (Builder $builder) use ($search) {
                $builder
                    ->whereHas('student', fn (Builder $student) => $student
                        ->where('username', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%"))
                    ->orWhereHas('courseOffering.subject', fn (Builder $subject) => $subject
                        ->where('name', 'like', "%{$search}%")
                        ->orWhere('code', 'like', "%{$search}%"))
                    ->orWhereHas('courseOffering.section', fn (Builder $section) => $section
                        ->where('name', 'like', "%{$search}%"))
                    ->orWhereHas('courseOffering.doctor', fn (Builder $doctor) => $doctor
                        ->where('username', 'like', "%{$search}%"))
                    ->orWhereHas('courseOffering.ta', fn (Builder $assistant) => $assistant
                        ->where('username', 'like', "%{$search}%"));
            });
        }

        if (! empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (! empty($filters['section_id'])) {
            $query->whereHas('courseOffering', fn (Builder $builder) => $builder->where('section_id', $filters['section_id']));
        }

        if (! empty($filters['course_id'])) {
            $query->whereHas('courseOffering', fn (Builder $builder) => $builder->where('subject_id', $filters['course_id']));
        }

        if (! empty($filters['semester'])) {
            $query->whereHas('courseOffering', fn (Builder $builder) => $builder->where('semester', $filters['semester']));
        }

        if (! empty($filters['academic_year'])) {
            $query->whereHas('courseOffering', fn (Builder $builder) => $builder->where('academic_year', $filters['academic_year']));
        }

        if (! empty($filters['staff_id'])) {
            $query->whereHas('courseOffering', fn (Builder $builder) => $builder
                ->where('doctor_user_id', $filters['staff_id'])
                ->orWhere('ta_user_id', $filters['staff_id']));
        }

        $sortBy = $filters['sort_by'] ?? 'updated_at';
        $direction = strtolower((string) ($filters['sort_direction'] ?? 'desc')) === 'asc' ? 'asc' : 'desc';

        return match ($sortBy) {
            'student_name' => $query->join('users as students', 'students.id', '=', 'enrollments.student_user_id')
                ->select('enrollments.*')
                ->orderBy('students.username', $direction),
            'student_id' => $query->orderBy('student_user_id', $direction),
            'status' => $query->orderBy('status', $direction),
            default => $query->orderBy('updated_at', $direction),
        };
    }

    protected function normalizePayload(array $payload): array
    {
        return [
            'student_user_id' => $payload['student_user_id'],
            'course_offering_id' => $payload['course_offering_id'],
            'status' => $payload['status'] ?? 'pending',
        ];
    }

    protected function ensureStudent(User $student): void
    {
        if ($student->role !== UserRole::STUDENT) {
            throw new ApiException('Only students can be enrolled.', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }
    }

    protected function loadEnrollmentRelations(Enrollment $enrollment): void
    {
        $enrollment->loadMissing([
            'student.studentProfile.department',
            'student.studentProfile.section',
            'courseOffering.subject.department',
            'courseOffering.section.department',
            'courseOffering.doctor',
            'courseOffering.ta',
        ]);
        $enrollment->courseOffering?->loadCount('enrollments');
    }

    protected function ensureGroupMembership(CourseOffering $offering, User $student): void
    {
        if (! $offering->group_id) {
            return;
        }

        GroupMember::query()->updateOrCreate(
            ['group_id' => $offering->group_id, 'user_id' => $student->id],
            ['role_in_group' => GroupMemberRole::MEMBER->value]
        );
    }

    protected function removeGroupMembership(?CourseOffering $offering, int $studentUserId): void
    {
        if (! $offering?->group_id) {
            return;
        }

        GroupMember::query()
            ->where('group_id', $offering->group_id)
            ->where('user_id', $studentUserId)
            ->delete();
    }
}
