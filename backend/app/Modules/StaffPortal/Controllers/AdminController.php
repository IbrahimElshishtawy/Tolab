<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Services\AdminPortalService;

class AdminController extends ApiController
{
    public function __construct(protected AdminPortalService $service) {}

    public function overview()
    {
        return $this->success('Admin overview retrieved successfully.', $this->service->overview());
    }

    public function permissions()
    {
        return $this->success('Permissions retrieved successfully.', $this->service->permissions()->pluck('name')->values());
    }

    public function departments()
    {
        return $this->success('Departments retrieved successfully.', $this->service->departments());
    }
}
