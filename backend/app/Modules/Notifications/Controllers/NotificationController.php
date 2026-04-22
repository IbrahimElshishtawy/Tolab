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

    public function index(Request $request)
    {
        $notifications = $this->notificationService->list($request->user(), $this->paginationSanitizer->perPage($request));

        return $this->success('Notifications retrieved successfully.', UserNotificationResource::collection($notifications));
    }

    public function markRead(UserNotification $notification)
    {
        $notification = $this->notificationService->markRead($notification, request()->user());

        return $this->success('Notification marked as read.', UserNotificationResource::make($notification));
    }

    public function broadcast(BroadcastNotificationRequest $request)
    {
        $this->notificationService->broadcast($request->validated(), $request->user());

        return $this->success('Notification broadcast queued successfully.');
    }
}
