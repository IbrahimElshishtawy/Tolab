<?php

namespace App\Modules\Academic\Services;

use App\Core\Enums\GroupMemberRole;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Repositories\CourseOfferingRepository;
use App\Modules\Group\Models\GroupChat;
use App\Modules\Group\Models\GroupMember;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\UserManagement\Models\User;
use Illuminate\Support\Facades\DB;

class CourseOfferingService
{
    public function __construct(
        protected CourseOfferingRepository $repository,
        protected AuditLogService $auditLogService,
    ) {}

    public function paginateAdmin(array $filters, int $perPage = 15)
    {
        return $this->repository->paginate($this->repository->adminListing($filters), $perPage);
    }

    public function create(array $payload, User $actor): CourseOffering
    {
        return DB::transaction(function () use ($payload, $actor) {
            $offering = CourseOffering::query()->create($payload);

            $group = GroupChat::query()->create([
                'course_offering_id' => $offering->id,
                'name' => "{$offering->subject->code} - {$offering->section->name}",
                'description' => 'Official course group chat',
                'created_by' => $actor->id,
            ]);

            $offering->update(['group_id' => $group->id]);
            $this->syncStaffMembers($offering, $group);
            $this->auditLogService->log($actor, 'academic.course-offering.create', $offering, [], request());

            return $offering->fresh(['subject', 'section', 'doctor', 'ta', 'group']);
        });
    }

    public function update(CourseOffering $offering, array $payload, User $actor): CourseOffering
    {
        return DB::transaction(function () use ($offering, $payload, $actor) {
            $offering->update($payload);
            $group = $offering->group ?? GroupChat::query()->create([
                'course_offering_id' => $offering->id,
                'name' => "{$offering->subject->code} - {$offering->section->name}",
                'description' => 'Official course group chat',
                'created_by' => $actor->id,
            ]);

            $offering->update(['group_id' => $group->id]);
            $this->syncStaffMembers($offering, $group);
            $this->auditLogService->log($actor, 'academic.course-offering.update', $offering, [], request());

            return $offering->fresh(['subject', 'section', 'doctor', 'ta', 'group']);
        });
    }

    protected function syncStaffMembers(CourseOffering $offering, GroupChat $group): void
    {
        $members = collect([
            [$offering->doctor_user_id, GroupMemberRole::OWNER->value],
            [$offering->ta_user_id, GroupMemberRole::MOD->value],
        ])->filter(fn ($item) => ! empty($item[0]));

        foreach ($members as [$userId, $role]) {
            GroupMember::query()->updateOrCreate(
                ['group_id' => $group->id, 'user_id' => $userId],
                ['role_in_group' => $role]
            );
        }
    }
}
