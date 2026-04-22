<?php

namespace App\Modules\Auth\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Auth\Requests\ChangePasswordRequest;
use App\Modules\Auth\Requests\LoginRequest;
use App\Modules\Auth\Requests\LogoutRequest;
use App\Modules\Auth\Requests\RefreshTokenRequest;
use App\Modules\Auth\Resources\AuthResource;
use App\Modules\Auth\Services\AuthService;

class AuthController extends ApiController
{
    public function __construct(protected AuthService $authService) {}

    public function login(LoginRequest $request)
    {
        $tokens = $this->authService->login($request->validated());

        return $this->success('Login successful.', AuthResource::make($tokens));
    }

    public function refresh(RefreshTokenRequest $request)
    {
        $tokens = $this->authService->refresh($request->validated());

        return $this->success('Token refreshed successfully.', AuthResource::make($tokens));
    }

    public function logout(LogoutRequest $request)
    {
        $this->authService->logout($request->user(), $request->validated('refresh_token'));

        return $this->success('Logout successful.');
    }

    public function changePassword(ChangePasswordRequest $request)
    {
        $this->authService->changePassword($request->user(), $request->validated());

        return $this->success('Password changed successfully.');
    }
}
