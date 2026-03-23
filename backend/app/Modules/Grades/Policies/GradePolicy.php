<?php

namespace App\Modules\Grades\Policies;

use App\Modules\Grades\Models\GradeItem;
use App\Modules\UserManagement\Models\User;

class GradePolicy
{
    public function view(User $user, GradeItem $gradeItem): bool
    {
        return $user->isAdmin() || $gradeItem->student_user_id === $user->id || $gradeItem->courseOffering?->doctor_user_id === $user->id || $gradeItem->courseOffering?->ta_user_id === $user->id;
    }

    public function manage(User $user): bool
    {
        return $user->canManageGrades();
    }
}
