<?php

namespace App\Modules\Group\Policies;

use App\Modules\Group\Models\Comment;
use App\Modules\UserManagement\Models\User;

class CommentPolicy
{
    public function delete(User $user, Comment $comment): bool
    {
        return $user->isAdmin();
    }
}
