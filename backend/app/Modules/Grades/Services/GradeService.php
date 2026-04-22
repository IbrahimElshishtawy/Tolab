<?php

namespace App\Modules\Grades\Services;

use App\Core\Exceptions\ApiException;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Grades\Models\GradeItem;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\UserManagement\Models\User;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

class GradeService
{
    public function __construct(protected AuditLogService $auditLogService) {}

    public function listForCourse(CourseOffering $courseOffering, ?int $studentUserId = null)
    {
        return $courseOffering->grades()
            ->when($studentUserId, fn ($query, $id) => $query->where('student_user_id', $id))
            ->latest('updated_at')
            ->get();
    }

    public function create(CourseOffering $courseOffering, array $payload, User $actor): GradeItem
    {
        if (! $actor->canManageGrades()) {
            throw new ApiException('You are not allowed to manage grades.', [], Response::HTTP_FORBIDDEN);
        }

        return DB::transaction(function () use ($courseOffering, $payload, $actor) {
            $grade = $courseOffering->grades()->create([
                ...$payload,
                'updated_by' => $actor->id,
            ]);

            $this->auditLogService->log($actor, 'grades.create', $grade, [], request());

            return $grade;
        });
    }

    public function update(GradeItem $gradeItem, array $payload, User $actor): GradeItem
    {
        if (! $actor->canManageGrades()) {
            throw new ApiException('You are not allowed to manage grades.', [], Response::HTTP_FORBIDDEN);
        }

        $gradeItem->update([
            ...$payload,
            'updated_by' => $actor->id,
        ]);

        $this->auditLogService->log($actor, 'grades.update', $gradeItem, [], request());

        return $gradeItem->refresh();
    }

    public function delete(GradeItem $gradeItem, User $actor): void
    {
        if (! $actor->canManageGrades()) {
            throw new ApiException('You are not allowed to manage grades.', [], Response::HTTP_FORBIDDEN);
        }

        $this->auditLogService->log($actor, 'grades.delete', $gradeItem, [], request());
        $gradeItem->delete();
    }
}
