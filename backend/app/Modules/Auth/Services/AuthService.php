<?php

namespace App\Modules\Auth\Services;

use App\Core\Exceptions\ApiException;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\UserManagement\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Symfony\Component\HttpFoundation\Response;

class AuthService
{
    public function __construct(
        protected TokenService $tokenService,
        protected AuditLogService $auditLogService,
    ) {
    }

    public function login(array $credentials)
    {
        $user = User::query()->where('email', $credentials['email'])->first();

        if (! $user || ! Hash::check($credentials['password'], $user->password_hash)) {
            throw new ApiException('Invalid credentials.', [], Response::HTTP_UNAUTHORIZED);
        }

        if (! $user->is_active) {
            throw new ApiException('Your account is inactive.', [], Response::HTTP_FORBIDDEN);
        }

        return DB::transaction(function () use ($user, $credentials) {
            $tokens = $this->tokenService->issue($user, $credentials['device_name'] ?? null);
            $this->auditLogService->log($user, 'auth.login', $user, [], request());

            return $tokens;
        });
    }

    public function refresh(array $payload)
    {
        return DB::transaction(function () use ($payload) {
            $tokens = $this->tokenService->rotate($payload['refresh_token'], $payload['device_name'] ?? null);

            if (! $tokens->user->is_active) {
                throw new ApiException('Your account is inactive.', [], Response::HTTP_FORBIDDEN);
            }

            $this->auditLogService->log($tokens->user, 'auth.refresh', $tokens->user, [], request());

            return $tokens;
        });
    }

    public function logout(User $user, string $refreshToken): void
    {
        DB::transaction(function () use ($user, $refreshToken) {
            $this->tokenService->revoke($refreshToken);
            $user->currentAccessToken()?->delete();
            $this->auditLogService->log($user, 'auth.logout', $user, [], request());
        });
    }

    public function changePassword(User $user, array $payload): void
    {
        if (! Hash::check($payload['current_password'], $user->password_hash)) {
            throw new ApiException('Current password is incorrect.', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        DB::transaction(function () use ($user, $payload) {
            $user->update([
                'password_hash' => $payload['password'],
            ]);

            $this->auditLogService->log($user, 'auth.change-password', $user, [], request());
        });
    }
}
