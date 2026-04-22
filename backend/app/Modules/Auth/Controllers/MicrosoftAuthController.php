<?php

namespace App\Modules\Auth\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Auth\Requests\CompleteMicrosoftLinkRequest;
use App\Modules\Auth\Resources\AuthResource;
use App\Modules\Auth\Services\MicrosoftAuthService;
use App\Modules\Auth\Services\StudentLinkingService;

class MicrosoftAuthController extends ApiController
{
    public function __construct(
        protected MicrosoftAuthService $microsoftAuthService,
        protected StudentLinkingService $studentLinkingService,
    ) {}

    public function redirect()
    {
        return $this->microsoftAuthService->redirect();
    }

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

    public function completeLink(CompleteMicrosoftLinkRequest $request)
    {
        $tokens = $this->studentLinkingService->completeLink($request->validated());

        return $this->success('Microsoft account linked successfully.', AuthResource::make($tokens));
    }
}
