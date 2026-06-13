<?php

namespace App\Modules\Auth\Interface\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Auth\Interface\Requests\ChangePasswordRequest;
use App\Modules\Auth\Interface\Requests\LoginRequest;
use App\Modules\Auth\Interface\Requests\LogoutRequest;
use App\Modules\Auth\Interface\Requests\RefreshTokenRequest;
use App\Modules\Auth\Interface\Resources\AuthResource;
use App\Modules\Auth\Application\AuthService;

class AuthController extends ApiController
{
    public function __construct(protected AuthService $authService) {}

        /**
     * @OA\Post(
     *     path="/api/auth/login",
     *     summary="login action in AuthController",
     *     tags={"Auth"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"email", "password"},
     *             @OA\Property(property="email", type="string", description="Rules: required, email:rfc"),
     *             @OA\Property(property="password", type="string", description="Rules: required, string, min:6, max:255"),
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
        /**
     * @OA\Post(
     *     path="/api/login",
     *     summary="login action in AuthController",
     *     tags={"Auth"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"email", "password"},
     *             @OA\Property(property="email", type="string", description="Rules: required, email:rfc"),
     *             @OA\Property(property="password", type="string", description="Rules: required, string, min:6, max:255"),
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
    public function login(LoginRequest $request)
    {
        $tokens = $this->authService->login($request->validated());

        return $this->success('Login successful.', AuthResource::make($tokens));
    }

        /**
     * @OA\Post(
     *     path="/api/auth/refresh",
     *     summary="refresh action in AuthController",
     *     tags={"Auth"},
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
        $tokens = $this->authService->refresh($request->validated());

        return $this->success('Token refreshed successfully.', AuthResource::make($tokens));
    }

        /**
     * @OA\Post(
     *     path="/api/auth/logout",
     *     summary="logout action in AuthController",
     *     tags={"Auth"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"refresh_token"},
     *             @OA\Property(property="refresh_token", type="string", description="Rules: required, string, min:32, max:255")
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
    public function logout(LogoutRequest $request)
    {
        $this->authService->logout($request->user(), $request->validated('refresh_token'));

        return $this->success('Logout successful.');
    }

        /**
     * @OA\Post(
     *     path="/api/auth/change-password",
     *     summary="changePassword action in AuthController",
     *     tags={"Auth"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"current_password", "password"},
     *             @OA\Property(property="current_password", type="string", description="Rules: required, string"),
     *             @OA\Property(property="password", type="string", description="Rules: required, string, min:8, max:255, confirmed")
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
    public function changePassword(ChangePasswordRequest $request)
    {
        $this->authService->changePassword($request->user(), $request->validated());

        return $this->success('Password changed successfully.');
    }
}
