<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\StaffPortal\Resources\NotificationPortalResource;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class NotificationController extends ApiController
{
    public function __construct(protected PortalService $service) {}

        /**
     * @OA\Get(
     *     path="/api/staff-portal/notifications",
     *     summary="index action in NotificationController",
     *     tags={"StaffPortal"},
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
        return $this->success('Notifications retrieved successfully.', NotificationPortalResource::collection($this->service->notifications($request->user())));
    }

        /**
     * @OA\Patch(
     *     path="/api/staff-portal/notifications/{notification}/read",
     *     summary="markRead action in NotificationController",
     *     tags={"StaffPortal"},
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
    public function markRead(Request $request, UserNotification $notification)
    {
        return $this->success('Notification marked as read.', NotificationPortalResource::make($this->service->markNotificationRead($request->user(), $notification)));
    }
}
