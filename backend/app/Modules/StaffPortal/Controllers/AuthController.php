<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Requests\ForgotPasswordRequest;
use App\Modules\StaffPortal\Requests\PortalLoginRequest;
use App\Modules\StaffPortal\Resources\SessionUserResource;
use App\Modules\StaffPortal\Services\PortalAuthService;
use Illuminate\Http\Request;

class AuthController extends ApiController
{
    public function __construct(protected PortalAuthService $service)
    {
    }

    public function login(PortalLoginRequest $request)
    {
        $payload = $this->service->login($request->validated());

        return $this->success('Login successful.', [
            'user' => SessionUserResource::make($payload['user']),
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
}
