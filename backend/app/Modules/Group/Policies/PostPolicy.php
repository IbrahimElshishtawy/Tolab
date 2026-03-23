<?php

namespace App\Modules\Group\Policies;

use App\Modules\Group\Models\Post;
use App\Modules\UserManagement\Models\User;

class PostPolicy
{
    public function delete(User $user, Post $post): bool
    {
        return $user->isAdmin() || $post->author_user_id === $user->id;
    }
}
