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

        return $courseOffering->group()->with(['courseOffering.subject', 'courseOffering.section'])->withCount('members')->firstOrFail();
    }

    public function getGroup(GroupChat $group, User $user): GroupChat
    {
        $this->ensureMember($group, $user);

        return $group->load(['courseOffering.subject', 'courseOffering.section'])->loadCount('members');
    }

    public function listPosts(GroupChat $group, User $user, int $limit, ?int $before = null)
    {
        $this->ensureMember($group, $user);

        return $group->posts()
            ->with(['author:id,username,full_name,avatar'])
            ->withCount('comments')
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

            return $post->load(['author:id,username,full_name,avatar'])->loadCount('comments');
        });
    }

    public function deletePost(Post $post, User $user): void
    {
        if (! $user->isAdmin()) {
            throw new ApiException('You are not allowed to delete this post.', [], Response::HTTP_FORBIDDEN);
        }

        $this->auditLogService->log($user, 'group.post.delete', $post, [], request());
        $post->delete();
    }

    public function listComments(Post $post, User $user)
    {
        $this->ensureMember($post->group, $user);

        return $post->comments()
            ->with('author:id,username,full_name,avatar')
            ->latest()
            ->get();
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

            return $comment->load('author:id,username,full_name,avatar');
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
            ->with('sender:id,username,full_name,avatar')
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

            return $message->load('sender:id,username,full_name,avatar');
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

        if ($this->userCanAccessGroup($group, $user)) {
            return;
        }

        throw new ApiException('You are not allowed to access this group.', [], Response::HTTP_FORBIDDEN);
    }

    protected function userCanAccessGroup(GroupChat $group, User $user): bool
    {
        $courseOffering = $this->resolveAccessibleCourseOffering($group);

        if ($courseOffering->doctor_user_id === $user->id || $courseOffering->ta_user_id === $user->id) {
            return true;
        }

        return $courseOffering->enrollments()
            ->active()
            ->where('student_user_id', $user->id)
            ->exists();
    }

    protected function resolveAccessibleCourseOffering(GroupChat $group): CourseOffering
    {
        $group->loadMissing('courseOffering');

        $courseOffering = $group->courseOffering;

        if (! $courseOffering) {
            throw new ApiException('Course offering not found for this group.', [], Response::HTTP_NOT_FOUND);
        }

        return $courseOffering;
    }
}
