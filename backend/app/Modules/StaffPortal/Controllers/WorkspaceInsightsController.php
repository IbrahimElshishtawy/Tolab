<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class WorkspaceInsightsController extends ApiController
{
    public function __construct(protected PortalService $service) {}

    public function analytics(Request $request)
    {
        return $this->success(
            'Analytics summary retrieved successfully.',
            $this->service->analyticsSummary($request->user()),
        );
    }

    public function feed(Request $request)
    {
        return $this->success(
            'Staff feed retrieved successfully.',
            $this->service->staffFeed($request->user()),
        );
    }

    public function conflicts(Request $request)
    {
        return $this->success(
            'Schedule conflicts retrieved successfully.',
            $this->service->scheduleConflicts($request->user()),
        );
    }

    public function controlPanelSettings(Request $request)
    {
        return $this->success(
            'Control panel settings retrieved successfully.',
            $this->service->controlPanelSettings($request->user()),
        );
    }
}
