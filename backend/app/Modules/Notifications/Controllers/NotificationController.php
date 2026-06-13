<?php

namespace App\Modules\Notifications\Controllers;

use App\Core\Base\ApiController;
use App\Core\Services\PaginationSanitizer;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\Notifications\Requests\BroadcastNotificationRequest;
use App\Modules\Notifications\Resources\UserNotificationResource;
use App\Modules\Notifications\Services\NotificationService;
use Illuminate\Http\Request;

class NotificationController extends ApiController
{
    public function __construct(
        protected NotificationService $notificationService,
        protected PaginationSanitizer $paginationSanitizer,
    ) {}

        /**
     * @OA\Get(
     *     path="/api/notifications",
     *     summary="index action in NotificationController",
     *     tags={"Notifications"},
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
    public function index(Request $request)
    {
        $notifications = $this->notificationService->list($request->user(), $this->paginationSanitizer->perPage($request));

        return $this->success('Notifications retrieved successfully.', UserNotificationResource::collection($notifications));
    }

        /**
     * @OA\Patch(
     *     path="/api/notifications/{notification}/read",
     *     summary="markRead action in NotificationController",
     *     tags={"Notifications"},
     *     @OA\Parameter(
     *         name="notification",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The notification parameter"
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
    public function markRead(UserNotification $notification)
    {
        $notification = $this->notificationService->markRead($notification, request()->user());

        return $this->success('Notification marked as read.', UserNotificationResource::make($notification));
    }

        /**
     * @OA\Post(
     *     path="/api/admin/notifications/broadcast",
     *     summary="broadcast action in NotificationController",
     *     tags={"Notifications"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"title", "body"},
     *             @OA\Property(property="title", type="string", description="Rules: required, string, max:180"),
     *             @OA\Property(property="body", type="string", description="Rules: required, string, max:5000"),
     *             @OA\Property(property="type", type="string", description="Rules: nullable, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="ref_type", type="string", description="Rules: nullable, string, max:80"),
     *             @OA\Property(property="ref_id", type="integer", description="Rules: nullable, integer")
     *         )
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
    public function broadcast(BroadcastNotificationRequest $request)
    {
        $this->notificationService->broadcast($request->validated(), $request->user());

        return $this->success('Notification broadcast queued successfully.');
    }
}
