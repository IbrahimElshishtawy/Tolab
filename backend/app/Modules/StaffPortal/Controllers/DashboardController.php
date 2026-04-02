<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class DashboardController extends ApiController
{
    public function __construct(protected PortalService $service)
    {
    }

    public function index(Request $request)
    {
        return $this->success('Dashboard loaded successfully.', $this->service->dashboard($request->user()));
    }
}
