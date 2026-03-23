<?php

namespace App\Modules\Group\Controllers;

use App\Core\Base\ApiController;
use App\Core\Services\PaginationSanitizer;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Group\Models\GroupChat;
use App\Modules\Group\Models\Post;
use App\Modules\Group\Models\Message;
use App\Modules\Group\Models\Comment;
use App\Modules\Group\Requests\StoreCommentRequest;
use App\Modules\Group\Requests\StoreMessageRequest;
use App\Modules\Group\Requests\StorePostRequest;
use App\Modules\Group\Resources\CommentResource;
use App\Modules\Group\Resources\GroupResource;
use App\Modules\Group\Resources\MessageResource;
use App\Modules\Group\Resources\PostResource;
use App\Modules\Group\Services\GroupService;
use Illuminate\Http\Request;

class GroupController extends ApiController
{
    public function __construct(
        protected GroupService $groupService,
        protected PaginationSanitizer $paginationSanitizer,
    ) {
    }

    public function studentCourseGroup(CourseOffering $courseOffering)
    {
        $group = $this->groupService->courseGroup($courseOffering, request()->user());

        return $this->success('Course group retrieved successfully.', GroupResource::make($group));
    }

    public function show(GroupChat $group)
    {
        $group = $this->groupService->getGroup($group, request()->user());

        return $this->success('Group retrieved successfully.', GroupResource::make($group));
    }

    public function posts(Request $request, GroupChat $group)
    {
        $posts = $this->groupService->listPosts($group, $request->user(), $this->paginationSanitizer->cursorLimit($request), $request->integer('before'));

        return $this->success('Posts retrieved successfully.', PostResource::collection($posts));
    }

    public function storePost(StorePostRequest $request, GroupChat $group)
    {
        $post = $this->groupService->createPost($group, $request->validated(), $request->user());

        return $this->success('Post created successfully.', PostResource::make($post), 201);
    }

    public function deletePost(Post $post)
    {
        $this->groupService->deletePost($post, request()->user());

        return $this->success('Post deleted successfully.');
    }

    public function comments(Post $post)
    {
        $comments = $this->groupService->listComments($post, request()->user());

        return $this->success('Comments retrieved successfully.', CommentResource::collection($comments));
    }

    public function storeComment(StoreCommentRequest $request, Post $post)
    {
        $comment = $this->groupService->createComment($post, $request->validated(), $request->user());

        return $this->success('Comment created successfully.', CommentResource::make($comment), 201);
    }

    public function deleteComment(Comment $comment)
    {
        $this->groupService->deleteComment($comment, request()->user());

        return $this->success('Comment deleted successfully.');
    }

    public function messages(Request $request, GroupChat $group)
    {
        $messages = $this->groupService->listMessages($group, $request->user(), $this->paginationSanitizer->cursorLimit($request), $request->integer('before'));

        return $this->success('Messages retrieved successfully.', MessageResource::collection($messages));
    }

    public function storeMessage(StoreMessageRequest $request, GroupChat $group)
    {
        $message = $this->groupService->createMessage($group, $request->validated(), $request->user());

        return $this->success('Message created successfully.', MessageResource::make($message), 201);
    }

    public function deleteMessage(Message $message)
    {
        $this->groupService->deleteMessage($message, request()->user());

        return $this->success('Message deleted successfully.');
    }
}
