<?php

namespace App\Modules\Group\Controllers;

use App\Core\Base\ApiController;
use App\Core\Services\PaginationSanitizer;
use App\Modules\Academic\Infrastructure\CourseOffering;
use App\Modules\Group\Models\Comment;
use App\Modules\Group\Models\GroupChat;
use App\Modules\Group\Models\Message;
use App\Modules\Group\Models\Post;
use App\Modules\Group\Requests\CreateCommentRequest;
use App\Modules\Group\Requests\CreatePostRequest;
use App\Modules\Group\Requests\SendMessageRequest;
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
    ) {}

        /**
     * @OA\Get(
     *     path="/api/student/courses/{courseOffering}/group",
     *     summary="studentCourseGroup action in GroupController",
     *     tags={"Group"},
     *     @OA\Parameter(
     *         name="courseOffering",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The courseOffering parameter"
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function studentCourseGroup(CourseOffering $courseOffering)
    {
        $group = $this->groupService->courseGroup($courseOffering, request()->user());

        return $this->success('Course group retrieved successfully.', GroupResource::make($group));
    }

        /**
     * @OA\Get(
     *     path="/api/groups/{group}",
     *     summary="show action in GroupController",
     *     tags={"Group"},
     *     @OA\Parameter(
     *         name="group",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The group parameter"
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function show(GroupChat $group)
    {
        $group = $this->groupService->getGroup($group, request()->user());

        return $this->success('Group retrieved successfully.', GroupResource::make($group));
    }

        /**
     * @OA\Get(
     *     path="/api/groups/{group}/posts",
     *     summary="posts action in GroupController",
     *     tags={"Group"},
     *     @OA\Parameter(
     *         name="group",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The group parameter"
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function posts(Request $request, GroupChat $group)
    {
        $posts = $this->groupService->listPosts($group, $request->user(), $this->paginationSanitizer->cursorLimit($request), $request->integer('before'));

        return $this->success(
            'Posts retrieved successfully.',
            PostResource::collection($posts),
            200,
            [
                'limit' => $this->paginationSanitizer->cursorLimit($request),
                'before' => $request->integer('before'),
                'next_before' => $posts->last()?->id,
            ]
        );
    }

    public function storePost(CreatePostRequest $request, GroupChat $group)
    {
        $post = $this->groupService->createPost($group, $request->validated(), $request->user());

        return $this->success('Post created successfully.', PostResource::make($post), 201);
    }

        /**
     * @OA\Delete(
     *     path="/api/posts/{post}",
     *     summary="deletePost action in GroupController",
     *     tags={"Group"},
     *     @OA\Parameter(
     *         name="post",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The post parameter"
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function deletePost(Post $post)
    {
        $this->groupService->deletePost($post, request()->user());

        return $this->success('Post deleted successfully.');
    }

        /**
     * @OA\Get(
     *     path="/api/posts/{post}/comments",
     *     summary="comments action in GroupController",
     *     tags={"Group"},
     *     @OA\Parameter(
     *         name="post",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The post parameter"
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function comments(Post $post)
    {
        $comments = $this->groupService->listComments($post, request()->user());

        return $this->success('Comments retrieved successfully.', CommentResource::collection($comments));
    }

    public function storeComment(CreateCommentRequest $request, Post $post)
    {
        $comment = $this->groupService->createComment($post, $request->validated(), $request->user());

        return $this->success('Comment created successfully.', CommentResource::make($comment), 201);
    }

        /**
     * @OA\Delete(
     *     path="/api/comments/{comment}",
     *     summary="deleteComment action in GroupController",
     *     tags={"Group"},
     *     @OA\Parameter(
     *         name="comment",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The comment parameter"
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function deleteComment(Comment $comment)
    {
        $this->groupService->deleteComment($comment, request()->user());

        return $this->success('Comment deleted successfully.');
    }

        /**
     * @OA\Get(
     *     path="/api/groups/{group}/messages",
     *     summary="messages action in GroupController",
     *     tags={"Group"},
     *     @OA\Parameter(
     *         name="group",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The group parameter"
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function messages(Request $request, GroupChat $group)
    {
        $messages = $this->groupService->listMessages($group, $request->user(), $this->paginationSanitizer->cursorLimit($request), $request->integer('before'));

        return $this->success(
            'Messages retrieved successfully.',
            MessageResource::collection($messages),
            200,
            [
                'limit' => $this->paginationSanitizer->cursorLimit($request),
                'before' => $request->integer('before'),
                'next_before' => $messages->last()?->id,
            ]
        );
    }

    public function storeMessage(SendMessageRequest $request, GroupChat $group)
    {
        $message = $this->groupService->createMessage($group, $request->validated(), $request->user());

        return $this->success('Message created successfully.', MessageResource::make($message), 201);
    }

        /**
     * @OA\Delete(
     *     path="/api/messages/{message}",
     *     summary="deleteMessage action in GroupController",
     *     tags={"Group"},
     *     @OA\Parameter(
     *         name="message",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The message parameter"
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function deleteMessage(Message $message)
    {
        $this->groupService->deleteMessage($message, request()->user());

        return $this->success('Message deleted successfully.');
    }
}
