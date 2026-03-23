<?php

namespace App\Modules\Group\Services;

use App\Core\Exceptions\ApiException;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Group\Models\Comment;
use App\Modules\Group\Models\GroupChat;
use App\Modules\Group\Models\Message;
use App\Modules\Group\Models\Post;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\UserManagement\Models\User;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

class GroupService
{
    public function __construct(protected AuditLogService $auditLogService)
    {
    }

    public function courseGroup(CourseOffering $courseOffering, User $user): GroupChat
    {
        $this->ensureMember($courseOffering->group, $user);

        return $courseOffering->group()->withCount('members')->firstOrFail();
    }

    public function getGroup(GroupChat $group, User $user): GroupChat
    {
        $this->ensureMember($group, $user);

        return $group->loadCount('members');
    }

    public function listPosts(GroupChat $group, User $user, int $limit, ?int $before = null)
    {
        $this->ensureMember($group, $user);

        return $group->posts()
            ->when($before, fn ($query, $cursor) => $query->where('id', '<', $cursor))
            ->latest('id')
            ->limit($limit)
            ->get();
    }

    public function createPost(GroupChat $group, array $payload, User $user): Post
    {
        $this->ensureMember($group, $user);

        return DB::transaction(function () use ($group, $payload, $user) {
            $post = $group->posts()->create([
                'author_user_id' => $user->id,
                'content_text' => $payload['content_text'],
            ]);

            $this->auditLogService->log($user, 'group.post.create', $post, [], request());

            return $post;
        });
    }

    public function deletePost(Post $post, User $user): void
    {
        if (! $user->isAdmin() && $post->author_user_id !== $user->id) {
            throw new ApiException('You are not allowed to delete this post.', [], Response::HTTP_FORBIDDEN);
        }

        $this->auditLogService->log($user, 'group.post.delete', $post, [], request());
        $post->delete();
    }

    public function listComments(Post $post, User $user)
    {
        $this->ensureMember($post->group, $user);

        return $post->comments()->latest()->get();
    }

    public function createComment(Post $post, array $payload, User $user): Comment
    {
        $this->ensureMember($post->group, $user);

        return DB::transaction(function () use ($post, $payload, $user) {
            $comment = $post->comments()->create([
                'author_user_id' => $user->id,
                'text' => $payload['text'],
            ]);

            $this->auditLogService->log($user, 'group.comment.create', $comment, [], request());

            return $comment;
        });
    }

    public function deleteComment(Comment $comment, User $user): void
    {
        if (! $user->isAdmin()) {
            throw new ApiException('You are not allowed to delete comments.', [], Response::HTTP_FORBIDDEN);
        }

        $this->auditLogService->log($user, 'group.comment.delete', $comment, [], request());
        $comment->delete();
    }

    public function listMessages(GroupChat $group, User $user, int $limit, ?int $before = null)
    {
        $this->ensureMember($group, $user);

        return $group->messages()
            ->when($before, fn ($query, $cursor) => $query->where('id', '<', $cursor))
            ->latest('id')
            ->limit($limit)
            ->get();
    }

    public function createMessage(GroupChat $group, array $payload, User $user): Message
    {
        $this->ensureMember($group, $user);

        return DB::transaction(function () use ($group, $payload, $user) {
            $message = $group->messages()->create([
                'sender_user_id' => $user->id,
                'text' => $payload['text'],
            ]);

            $this->auditLogService->log($user, 'group.message.create', $message, [], request());

            return $message;
        });
    }

    public function deleteMessage(Message $message, User $user): void
    {
        if (! $user->isAdmin()) {
            throw new ApiException('You are not allowed to delete messages.', [], Response::HTTP_FORBIDDEN);
        }

        $this->auditLogService->log($user, 'group.message.delete', $message, [], request());
        $message->delete();
    }

    protected function ensureMember(?GroupChat $group, User $user): void
    {
        if (! $group) {
            throw new ApiException('Group not found.', [], Response::HTTP_NOT_FOUND);
        }

        if ($user->isAdmin()) {
            return;
        }

        $isMember = $group->members()->where('user_id', $user->id)->exists();

        if (! $isMember) {
            throw new ApiException('You are not allowed to access this group.', [], Response::HTTP_FORBIDDEN);
        }
    }
}
