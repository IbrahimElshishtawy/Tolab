<?php

namespace App\Modules\Auth\Interface\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Auth\Interface\Requests\CompleteMicrosoftLinkRequest;
use App\Modules\Auth\Interface\Resources\AuthResource;
use App\Modules\Auth\Application\MicrosoftAuthService;
use App\Modules\Auth\Application\StudentLinkingService;

class MicrosoftAuthController extends ApiController
{
    public function __construct(
        protected MicrosoftAuthService $microsoftAuthService,
        protected StudentLinkingService $studentLinkingService,
    ) {}

        /**
     * @OA\Get(
     *     path="/api/auth/microsoft/redirect",
     *     summary="redirect action in MicrosoftAuthController",
     *     tags={"Auth"},
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest")
     * )
     */
    public function redirect()
    {
        return $this->microsoftAuthService->redirect();
    }

        /**
     * @OA\Get(
     *     path="/api/auth/microsoft/callback",
     *     summary="callback action in MicrosoftAuthController",
     *     tags={"Auth"},
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest")
     * )
     */
    public function callback()
    {
        $result = $this->microsoftAuthService->handleCallback();

        if ($result['status'] === 'authenticated') {
            return $this->success('Microsoft login successful.', AuthResource::make($result['tokens']));
        }

        return $this->success(
            'Microsoft account verified. Complete identity confirmation to finish linking.',
            $result
        );
    }

        /**
     * @OA\Post(
     *     path="/api/auth/microsoft/complete-link",
     *     summary="completeLink action in MicrosoftAuthController",
     *     tags={"Auth"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"link_token", "national_id"},
     *             @OA\Property(property="link_token", type="string", description="Rules: required, string, max:255"),
     *             @OA\Property(property="national_id", type="string", description="Rules: required, regex:/^\d{14}$/"),
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
    public function completeLink(CompleteMicrosoftLinkRequest $request)
    {
        $tokens = $this->studentLinkingService->completeLink($request->validated());

        return $this->success('Microsoft account linked successfully.', AuthResource::make($tokens));
    }
}
