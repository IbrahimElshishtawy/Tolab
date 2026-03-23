<?php

namespace App\Modules\UserManagement\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Auth\Resources\UserIdentityResource;
use App\Modules\UserManagement\Requests\UpdateProfileRequest;
use App\Modules\UserManagement\Resources\ProfileResource;
use App\Modules\UserManagement\Services\UserService;
use Illuminate\Http\Request;

class MeController extends ApiController
{
    public function __construct(protected UserService $userService)
    {
    }

    public function me(Request $request)
    {
        return $this->success('User profile retrieved successfully.', UserIdentityResource::make($request->user()));
    }

    public function profile(Request $request)
    {
        $user = $request->user()->load(['studentProfile', 'staffProfile', 'staffPermission']);

        return $this->success('Detailed profile retrieved successfully.', ProfileResource::make($user));
    }

    public function updateProfile(UpdateProfileRequest $request)
    {
        $user = $this->userService->updateOwnProfile($request->user(), $request->validated());

        return $this->success('Profile updated successfully.', ProfileResource::make($user));
    }
}
