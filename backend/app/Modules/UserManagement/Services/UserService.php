<?php

namespace App\Modules\UserManagement\Services;

use App\Core\Enums\PasswordResetMode;
use App\Core\Enums\UserRole;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\UserManagement\Models\StaffPermission;
use App\Modules\UserManagement\Models\StaffProfile;
use App\Modules\UserManagement\Models\StudentProfile;
use App\Modules\UserManagement\Models\User;
use App\Modules\UserManagement\Repositories\UserRepository;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use PhpOffice\PhpSpreadsheet\IOFactory;

class UserService
{
    public function __construct(
        protected UserRepository $userRepository,
        protected AuditLogService $auditLogService,
    ) {
    }

    public function paginate(array $filters, int $perPage = 15)
    {
        return $this->userRepository->paginate($this->userRepository->filter($filters), $perPage);
    }

    public function create(array $payload, User $actor): User
    {
        return DB::transaction(function () use ($payload, $actor) {
            $role = $payload['role'] instanceof UserRole ? $payload['role'] : UserRole::from($payload['role']);
            $password = $payload['password']
                ?? ($role === UserRole::STUDENT ? $payload['national_id'] : Str::password(12));

            $user = User::query()->create([
                'role' => $role,
                'username' => $payload['username'],
                'email' => $payload['email'],
                'password_hash' => $password,
                'national_id' => $payload['national_id'] ?? null,
                'is_active' => $payload['is_active'] ?? true,
            ]);

            $this->syncProfiles($user, $payload);
            $this->auditLogService->log($actor, 'users.create', $user, ['role' => $user->role->value], request());

            return $user->fresh([
                'studentProfile.department',
                'studentProfile.section',
                'staffProfile.department',
                'staffPermission',
            ]);
        });
    }

    public function update(User $user, array $payload, User $actor): User
    {
        return DB::transaction(function () use ($user, $payload, $actor) {
            $user->fill(collect($payload)
                ->only(['role', 'username', 'email', 'national_id', 'is_active'])
                ->toArray());

            if (! empty($payload['password'])) {
                $user->password_hash = $payload['password'];
            }

            $user->save();
            $this->syncProfiles($user, $payload);
            $this->auditLogService->log($actor, 'users.update', $user, [], request());

            return $user->fresh([
                'studentProfile.department',
                'studentProfile.section',
                'staffProfile.department',
                'staffPermission',
            ]);
        });
    }

    public function setActivation(User $user, bool $isActive, User $actor): User
    {
        $user->update(['is_active' => $isActive]);
        $this->auditLogService->log($actor, 'users.activation', $user, ['is_active' => $isActive], request());

        return $user->fresh(['studentProfile', 'staffProfile', 'staffPermission']);
    }

    public function resetPassword(User $user, array $payload, User $actor): array
    {
        $newPassword = $payload['mode'] === PasswordResetMode::DEFAULT
            ? ($user->role === UserRole::STUDENT ? $user->national_id : Str::password(12))
            : $payload['password'];

        $user->update(['password_hash' => $newPassword]);

        $this->auditLogService->log($actor, 'users.reset-password', $user, ['mode' => $payload['mode']->value], request());

        return [
            'user_id' => $user->id,
            'new_password' => $newPassword,
        ];
    }

    public function updateOwnProfile(User $user, array $payload): User
    {
        $user->update(collect($payload)->only([
            'username',
            'full_name',
            'phone',
            'avatar',
            'language',
            'notification_enabled',
        ])->toArray());

        return $user->fresh([
            'studentProfile.department',
            'studentProfile.section',
            'staffProfile.department',
            'staffPermission',
        ]);
    }

    public function importStudents(UploadedFile $file, User $actor): array
    {
        return $this->importRows($file, UserRole::STUDENT, $actor);
    }

    public function importStaff(UploadedFile $file, User $actor): array
    {
        return $this->importRows($file, null, $actor);
    }

    protected function importRows(UploadedFile $file, ?UserRole $forcedRole, User $actor): array
    {
        $sheet = IOFactory::load($file->getRealPath())->getActiveSheet()->toArray();
        $headers = collect(array_shift($sheet) ?? [])->map(fn ($value) => Str::of((string) $value)->snake()->toString())->toArray();

        $created = 0;
        $updated = 0;

        DB::transaction(function () use ($sheet, $headers, $forcedRole, $actor, &$created, &$updated) {
            foreach ($sheet as $row) {
                $payload = array_filter(array_combine($headers, $row), fn ($value) => $value !== null && $value !== '');

                if (empty($payload['email']) || empty($payload['username'])) {
                    continue;
                }

                $role = $forcedRole ?? UserRole::from((string) $payload['role']);
                $user = User::query()->firstWhere('email', $payload['email']);

                $data = [
                    'role' => $role,
                    'username' => $payload['username'],
                    'email' => $payload['email'],
                    'national_id' => $payload['national_id'] ?? null,
                    'password_hash' => $payload['password'] ?? ($role === UserRole::STUDENT ? ($payload['national_id'] ?? Str::password(12)) : Str::password(12)),
                    'is_active' => true,
                ];

                if ($user) {
                    $user->update($data);
                    $updated++;
                } else {
                    $user = User::query()->create($data);
                    $created++;
                }

                $this->syncProfiles($user, [
                    'role' => $role,
                    'student_profile' => [
                        'gpa' => $payload['gpa'] ?? null,
                        'grade_year' => $payload['grade_year'] ?? null,
                        'section_id' => $payload['section_id'] ?? null,
                        'department_id' => $payload['department_id'] ?? null,
                    ],
                    'staff_profile' => [
                        'department_id' => $payload['department_id'] ?? null,
                        'title' => $payload['title'] ?? $role->value,
                    ],
                ]);
            }

            $this->auditLogService->log($actor, 'users.import', null, [
                'created' => $created,
                'updated' => $updated,
            ], request());
        });

        return compact('created', 'updated');
    }

    protected function syncProfiles(User $user, array $payload): void
    {
        if ($user->role === UserRole::STUDENT) {
            StudentProfile::query()->updateOrCreate(
                ['user_id' => $user->id],
                collect($payload['student_profile'] ?? [])
                    ->only(['gpa', 'grade_year', 'section_id', 'department_id'])
                    ->toArray()
            );

            StaffProfile::query()->where('user_id', $user->id)->delete();
            StaffPermission::query()->where('user_id', $user->id)->delete();

            return;
        }

        StaffProfile::query()->updateOrCreate(
            ['user_id' => $user->id],
            collect($payload['staff_profile'] ?? [])
                ->only(['department_id', 'title'])
                ->toArray()
        );

        StaffPermission::query()->updateOrCreate(
            ['user_id' => $user->id],
            collect($payload['staff_permissions'] ?? [])
                ->only(['can_upload_content', 'can_manage_grades', 'can_manage_schedule', 'can_moderate_group'])
                ->all()
        );

        StudentProfile::query()->where('user_id', $user->id)->delete();
    }
}
