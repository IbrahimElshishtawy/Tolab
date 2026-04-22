<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Resources\SchedulePortalResource;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class ScheduleController extends ApiController
{
    public function __construct(protected PortalService $service) {}

    public function index(Request $request)
    {
        return $this->success('Schedule retrieved successfully.', SchedulePortalResource::collection($this->service->schedule($request->user())));
    }
}
