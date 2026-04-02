<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\StaffPortal\Resources\NotificationPortalResource;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class NotificationController extends ApiController
{
    public function __construct(protected PortalService $service)
    {
    }

    public function index(Request $request)
    {
        return $this->success('Notifications retrieved successfully.', NotificationPortalResource::collection($this->service->notifications($request->user())));
    }

    public function markRead(Request $request, UserNotification $notification)
    {
        return $this->success('Notification marked as read.', NotificationPortalResource::make($this->service->markNotificationRead($request->user(), $notification)));
    }
}
