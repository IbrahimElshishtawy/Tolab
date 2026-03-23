<?php

namespace App\Modules\Group\Policies;

use App\Modules\Group\Models\GroupChat;
use App\Modules\UserManagement\Models\User;

class GroupPolicy
{
    public function view(User $user, GroupChat $group): bool
    {
        return $user->isAdmin() || $group->members()->where('user_id', $user->id)->exists();
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
