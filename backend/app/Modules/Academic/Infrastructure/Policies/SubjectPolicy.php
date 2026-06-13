<?php

namespace App\Modules\Academic\Infrastructure\Policies;

use App\Core\Enums\UserRole;
use App\Modules\Academic\Infrastructure\CourseOffering;
use App\Modules\Academic\Infrastructure\Subject;
use App\Modules\UserManagement\Models\User;

class SubjectPolicy
{
    public function viewResults(User $user, Subject $subject): bool
    {
        if ($user->isAdmin()) {
            return true;
        }

        if (!$user->isStaff()) {
            return false;
        }

        // Check if the user has an assignment for this subject
        $isAssigned = $user->staffAssignments()->where('subject_id', $subject->id)->exists()
            || CourseOffering::query()
                ->where('subject_id', $subject->id)
                ->where(function ($query) use ($user) {
                    $query->where('doctor_user_id', $user->id)
                        ->orWhere('ta_user_id', $user->id);
                })
                ->exists();

        return $isAssigned;
    }

    public function manageGrades(User $user, Subject $subject, string $categoryKey): bool
    {
        if ($user->isAdmin()) {
            return true;
        }

        if (!$user->isStaff()) {
            return false;
        }

        // Check if the user is assigned to the subject
        $isAssigned = $user->staffAssignments()->where('subject_id', $subject->id)->exists()
            || CourseOffering::query()
                ->where('subject_id', $subject->id)
                ->where(function ($query) use ($user) {
                    $query->where('doctor_user_id', $user->id)
                        ->orWhere('ta_user_id', $user->id);
                })
                ->exists();

        if (!$isAssigned) {
            return false;
        }

        // Validate the category key based on role
        if ($user->role === UserRole::DOCTOR) {
            return in_array($categoryKey, ['midterm', 'final'], true);
        }

        if ($user->role === UserRole::TA) {
            return in_array($categoryKey, ['quiz', 'oral', 'sheets', 'attendance', 'coursework'], true);
        }

        return false;
    }
}
