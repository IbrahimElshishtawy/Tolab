<?php

namespace App\Modules\Moderation\Services;

use App\Modules\Group\Models\Comment;
use App\Modules\Group\Models\Message;
use App\Modules\Group\Models\Post;
use App\Modules\Group\Services\GroupService;
use App\Modules\UserManagement\Models\User;

class ModerationService
{
    public function __construct(protected GroupService $groupService)
    {
    }

    public function deletePost(Post $post, User $admin): void
    {
        $this->groupService->deletePost($post, $admin);
    }

    public function deleteComment(Comment $comment, User $admin): void
    {
        $this->groupService->deleteComment($comment, $admin);
    }

    public function deleteMessage(Message $message, User $admin): void
    {
        $this->groupService->deleteMessage($message, $admin);
    }
}
