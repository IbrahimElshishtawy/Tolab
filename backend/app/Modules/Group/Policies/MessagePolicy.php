<?php

namespace App\Modules\Group\Policies;

use App\Modules\Group\Models\Message;
use App\Modules\UserManagement\Models\User;

class MessagePolicy
{
    public function delete(User $user, Message $message): bool
    {
        return $user->isAdmin();
    }
}
