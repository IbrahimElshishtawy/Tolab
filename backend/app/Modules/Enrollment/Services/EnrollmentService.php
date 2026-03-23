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
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

class EnrollmentService
{
    public function __construct(protected AuditLogService $auditLogService)
    {
    }

    public function create(array $payload, User $actor): Enrollment
    {
        return DB::transaction(function () use ($payload, $actor) {
            $student = User::query()->findOrFail($payload['student_user_id']);

            if ($student->role !== UserRole::STUDENT) {
                throw new ApiException('Only students can be enrolled.', [], Response::HTTP_UNPROCESSABLE_ENTITY);
            }

            $enrollment = Enrollment::query()->firstOrCreate($payload);
            $this->ensureGroupMembership($enrollment->courseOffering, $student);
            $this->auditLogService->log($actor, 'enrollment.create', $enrollment, [], request());

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
            GroupMember::query()
                ->where('group_id', $enrollment->courseOffering->group_id)
                ->where('user_id', $enrollment->student_user_id)
                ->delete();

            $this->auditLogService->log($actor, 'enrollment.delete', $enrollment, [], request());
            $enrollment->delete();
        });
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
}
