<?php

namespace App\Modules\Group\Policies;

use App\Modules\Group\Models\GroupChat;
use App\Modules\UserManagement\Models\User;

class GroupPolicy
{
    public function view(User $user, GroupChat $group): bool
    {
        if ($user->isAdmin()) {
            return true;
        }

        $group->loadMissing('courseOffering');

        if ($group->courseOffering?->doctor_user_id === $user->id || $group->courseOffering?->ta_user_id === $user->id) {
            return true;
        }

        return $group->courseOffering?->enrollments()
            ->active()
            ->where('student_user_id', $user->id)
            ->exists() ?? false;
    }

    public function post(User $user, GroupChat $group): bool
    {
        return $this->view($user, $group);
    }

    public function message(User $user, GroupChat $group): bool
    {
        return $this->view($user, $group);
    }
}
