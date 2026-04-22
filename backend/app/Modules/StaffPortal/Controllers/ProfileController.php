<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Requests\UpdatePortalSettingsRequest;
use App\Modules\StaffPortal\Resources\SessionUserResource;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class ProfileController extends ApiController
{
    public function __construct(protected PortalService $service) {}

    public function show(Request $request)
    {
        return $this->success('Profile retrieved successfully.', SessionUserResource::make($this->service->profile($request->user())));
    }

    public function updateSettings(UpdatePortalSettingsRequest $request)
    {
        return $this->success('Settings updated successfully.', SessionUserResource::make($this->service->updateSettings($request->user(), $request->validated())));
    }
}
