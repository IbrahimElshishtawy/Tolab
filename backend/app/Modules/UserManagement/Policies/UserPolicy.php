<?php

namespace App\Modules\UserManagement\Policies;

use App\Modules\UserManagement\Models\User;

class UserPolicy
{
    public function before(User $user, string $ability): ?bool
    {
        return $user->isAdmin() ? true : null;
    }
}
