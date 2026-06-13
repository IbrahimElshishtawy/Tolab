<?php

namespace App\Modules\Grades\Policies;

use App\Modules\Grades\Models\StudentGrade;
use App\Modules\UserManagement\Models\User;

class GradePolicy
{
    public function view(User $user, StudentGrade $studentGrade): bool
    {
        if ($user->isAdmin()) {
            return true;
        }

        $studentUserId = $studentGrade->student?->user_id;
        if ($studentUserId === $user->id) {
            return true;
        }

        $subjectId = $studentGrade->gradeCategory?->subject_id;
        if ($subjectId) {
            $isAssigned = $user->staffAssignments()->where('subject_id', $subjectId)->exists()
                || \App\Modules\Academic\Infrastructure\CourseOffering::query()
                    ->where('subject_id', $subjectId)
                    ->where(function ($query) use ($user) {
                        $query->where('doctor_user_id', $user->id)
                            ->orWhere('ta_user_id', $user->id);
                    })
                    ->exists();
            if ($isAssigned) {
                return true;
            }
        }

        return false;
    }

    public function manage(User $user): bool
    {
        return $user->canManageGrades();
    }
}
