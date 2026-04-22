<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Auth\Requests\RefreshTokenRequest;
use App\Modules\StaffPortal\Requests\ForgotPasswordRequest;
use App\Modules\StaffPortal\Requests\PortalLoginRequest;
use App\Modules\StaffPortal\Resources\SessionUserResource;
use App\Modules\StaffPortal\Services\PortalAuthService;
use Illuminate\Http\Request;

class AuthController extends ApiController
{
    public function __construct(protected PortalAuthService $service) {}

    public function login(PortalLoginRequest $request)
    {
        $payload = $this->service->login($request->validated());

        return $this->success('Login successful.', $this->formatSessionPayload($payload));
    }

    public function refresh(RefreshTokenRequest $request)
    {
        $payload = $this->service->refresh($request->validated());

        return $this->success('Token refreshed successfully.', [
            'token' => $payload['tokens']['access_token'],
            'access_token' => $payload['tokens']['access_token'],
            'refresh_token' => $payload['tokens']['refresh_token'],
            'tokens' => $payload['tokens'],
        ]);
    }

    public function logout(Request $request)
    {
        $this->service->logout($request->user(), $request->input('refresh_token'));

        return $this->success('Logout successful.');
    }

    public function forgotPassword(ForgotPasswordRequest $request)
    {
        $this->service->forgotPassword($request->validated());

        return $this->success('Password reset request submitted.');
    }

    protected function formatSessionPayload(array $payload): array
    {
        $user = SessionUserResource::make($payload['user'])->resolve();

        return [
            'token' => $payload['tokens']['access_token'],
            'access_token' => $payload['tokens']['access_token'],
            'refresh_token' => $payload['tokens']['refresh_token'],
            'role' => $user['role'] ?? $user['role_type'] ?? null,
            'user' => $user,
            'tokens' => $payload['tokens'],
        ];
    }
}
