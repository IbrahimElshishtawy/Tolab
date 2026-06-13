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

        /**
     * @OA\Delete(
     *     path="/api/admin/posts/{post}",
     *     summary="deletePost action in ModerationController",
     *     tags={"Moderation"},
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
        $this->moderationService->deletePost($post, request()->user());

        return $this->success('Post deleted successfully.');
    }

        /**
     * @OA\Delete(
     *     path="/api/admin/comments/{comment}",
     *     summary="deleteComment action in ModerationController",
     *     tags={"Moderation"},
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
        $this->moderationService->deleteComment($comment, request()->user());

        return $this->success('Comment deleted successfully.');
    }

        /**
     * @OA\Delete(
     *     path="/api/admin/messages/{message}",
     *     summary="deleteMessage action in ModerationController",
     *     tags={"Moderation"},
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
        $this->moderationService->deleteMessage($message, request()->user());

        return $this->success('Message deleted successfully.');
    }
}
