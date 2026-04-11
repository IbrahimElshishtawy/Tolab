<?php

namespace App\Modules\Academic\Policies;

use App\Modules\Academic\Models\CourseOffering;
use App\Modules\UserManagement\Models\User;

class CourseOfferingPolicy
{
    public function view(User $user, CourseOffering $courseOffering): bool
    {
        if ($user->isAdmin()) {
            return true;
        }

        if ($courseOffering->doctor_user_id === $user->id || $courseOffering->ta_user_id === $user->id) {
            return true;
        }

        return $courseOffering->enrollments()
            ->active()
            ->where('student_user_id', $user->id)
            ->exists();
    }

    public function manage(User $user, CourseOffering $courseOffering): bool
    {
        return $user->isAdmin();
    }
}
