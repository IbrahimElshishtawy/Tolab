<?php

namespace App\Modules\Grades\Services;

use App\Core\Exceptions\ApiException;
use App\Modules\Academic\Infrastructure\CourseOffering;
use App\Modules\Grades\Models\StudentGrade;
use App\Modules\Grades\Models\GradeCategory;
use App\Modules\UserManagement\Models\StudentProfile;
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
            ->with(['gradeCategory', 'student', 'grader:id,username,full_name'])
            ->when($studentUserId, fn ($query, $id) => $query->whereHas('student', fn($q) => $q->where('user_id', $id)))
            ->latest('updated_at')
            ->get();
    }

    public function create(CourseOffering $courseOffering, array $payload, User $actor): StudentGrade
    {
        if (! $actor->canManageGrades()) {
            throw new ApiException('You are not allowed to manage grades.', [], Response::HTTP_FORBIDDEN);
        }

        return DB::transaction(function () use ($courseOffering, $payload, $actor) {
            $studentProfile = StudentProfile::where('user_id', $payload['student_user_id'])->firstOrFail();

            $category = GradeCategory::firstOrCreate(
                [
                    'subject_id' => $courseOffering->subject_id,
                    'key_name' => $payload['type'],
                ],
                [
                    'label' => ucfirst($payload['type']),
                    'max_score' => $payload['max_score'],
                    'status' => 'published',
                ]
            );

            $grade = StudentGrade::updateOrCreate(
                [
                    'student_id' => $studentProfile->id,
                    'grade_category_id' => $category->id,
                ],
                [
                    'score' => $payload['score'],
                    'note' => $payload['note'] ?? null,
                    'graded_by' => $actor->id,
                    'status' => 'published',
                ]
            );

            $this->auditLogService->log($actor, 'grades.create', $grade, [], request());

            return $grade->load(['gradeCategory', 'student', 'grader']);
        });
    }

    public function update(StudentGrade $gradeItem, array $payload, User $actor): StudentGrade
    {
        if (! $actor->canManageGrades()) {
            throw new ApiException('You are not allowed to manage grades.', [], Response::HTTP_FORBIDDEN);
        }

        $gradeItem->update([
            'score' => $payload['score'] ?? $gradeItem->score,
            'note' => $payload['note'] ?? $gradeItem->note,
            'graded_by' => $actor->id,
        ]);

        if (isset($payload['max_score']) && $gradeItem->gradeCategory) {
            $gradeItem->gradeCategory->update([
                'max_score' => $payload['max_score'],
            ]);
        }

        $this->auditLogService->log($actor, 'grades.update', $gradeItem, [], request());

        return $gradeItem->load(['gradeCategory', 'student', 'grader'])->refresh();
    }

    public function delete(StudentGrade $gradeItem, User $actor): void
    {
        if (! $actor->canManageGrades()) {
            throw new ApiException('You are not allowed to manage grades.', [], Response::HTTP_FORBIDDEN);
        }

        $this->auditLogService->log($actor, 'grades.delete', $gradeItem, [], request());
        $gradeItem->delete();
    }
}
