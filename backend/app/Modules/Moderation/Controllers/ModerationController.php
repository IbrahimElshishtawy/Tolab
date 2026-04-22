<?php

namespace App\Modules\Moderation\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Group\Models\Comment;
use App\Modules\Group\Models\Message;
use App\Modules\Group\Models\Post;
use App\Modules\Moderation\Services\ModerationService;

class ModerationController extends ApiController
{
    public function __construct(protected ModerationService $moderationService) {}

    public function deletePost(Post $post)
    {
        $this->moderationService->deletePost($post, request()->user());

        return $this->success('Post deleted successfully.');
    }

    public function deleteComment(Comment $comment)
    {
        $this->moderationService->deleteComment($comment, request()->user());

        return $this->success('Comment deleted successfully.');
    }

    public function deleteMessage(Message $message)
    {
        $this->moderationService->deleteMessage($message, request()->user());

        return $this->success('Message deleted successfully.');
    }
}
