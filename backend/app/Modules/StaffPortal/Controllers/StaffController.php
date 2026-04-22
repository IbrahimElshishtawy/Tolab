<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Requests\TogglePortalStaffActivationRequest;
use App\Modules\StaffPortal\Resources\StaffMemberResource;
use App\Modules\StaffPortal\Services\AdminPortalService;
use App\Modules\UserManagement\Models\User;

class StaffController extends ApiController
{
    public function __construct(protected AdminPortalService $service) {}

    public function index()
    {
        return $this->success('Staff retrieved successfully.', StaffMemberResource::collection($this->service->staff()));
    }

    public function toggleActivation(TogglePortalStaffActivationRequest $request, User $user)
    {
        return $this->success('Staff activation updated successfully.', StaffMemberResource::make($this->service->toggleActivation($user, $request->boolean('is_active'))));
    }
}
