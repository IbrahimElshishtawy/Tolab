<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Resources\DashboardResource;
use App\Modules\StaffPortal\Services\DashboardService;
use Illuminate\Http\Request;

class DashboardController extends ApiController
{
    public function __construct(protected DashboardService $service)
    {
    }

    public function index(Request $request)
    {
        return $this->success(
            'Dashboard loaded successfully.',
            DashboardResource::make($this->service->dashboard($request->user())),
        );
    }
}
