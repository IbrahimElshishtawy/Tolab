<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Auth\Interface\Requests\RefreshTokenRequest;
use App\Modules\StaffPortal\Requests\ForgotPasswordRequest;
use App\Modules\StaffPortal\Requests\PortalLoginRequest;
use App\Modules\StaffPortal\Resources\SessionUserResource;
use App\Modules\StaffPortal\Services\PortalAuthService;
use Illuminate\Http\Request;

class AuthController extends ApiController
{
    public function __construct(protected PortalAuthService $service) {}

        /**
     * @OA\Post(
     *     path="/api/staff-portal/auth/login",
     *     summary="login action in AuthController",
     *     tags={"StaffPortal"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"university_email", "password"},
     *             @OA\Property(property="university_email", type="string", description="Rules: required, email"),
     *             @OA\Property(property="password", type="string", description="Rules: required, string"),
     *             @OA\Property(property="device_name", type="string", description="Rules: nullable, string, max:120")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest")
     * )
     */
    public function login(PortalLoginRequest $request)
    {
        $payload = $this->service->login($request->validated());

        return $this->success('Login successful.', $this->formatSessionPayload($payload));
    }

        /**
     * @OA\Post(
     *     path="/api/staff-portal/auth/refresh",
     *     summary="refresh action in AuthController",
     *     tags={"StaffPortal"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"refresh_token"},
     *             @OA\Property(property="refresh_token", type="string", description="Rules: required, string, min:32, max:255"),
     *             @OA\Property(property="device_name", type="string", description="Rules: nullable, string, max:100")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest")
     * )
     */
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

        /**
     * @OA\Post(
     *     path="/api/staff-portal/auth/logout",
     *     summary="logout action in AuthController",
     *     tags={"StaffPortal"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"refresh_token"},
     *             @OA\Property(property="refresh_token", type="string", description="Rules: required, string, min:32, max:255"),
     *             @OA\Property(property="device_name", type="string", description="Rules: nullable, string, max:100")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function logout(Request $request)
    {
        $this->service->logout($request->user(), $request->input('refresh_token'));

        return $this->success('Logout successful.');
    }

        /**
     * @OA\Post(
     *     path="/api/staff-portal/auth/forgot-password",
     *     summary="forgotPassword action in AuthController",
     *     tags={"StaffPortal"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"university_email"},
     *             @OA\Property(property="university_email", type="string", description="Rules: required, email")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest")
     * )
     */
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
