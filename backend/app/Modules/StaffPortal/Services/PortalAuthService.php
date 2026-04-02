<?php

namespace App\Modules\StaffPortal\Services;

use App\Core\Exceptions\ApiException;
use App\Modules\Auth\Services\TokenService;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\UserManagement\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Symfony\Component\HttpFoundation\Response;

class PortalAuthService
{
    public function __construct(
        protected TokenService $tokenService,
        protected AuditLogService $auditLogService,
    ) {
    }

    public function login(array $payload): array
    {
        $user = User::query()
            ->where(function ($query) use ($payload) {
                $query->where('university_email', $payload['university_email'])
                    ->orWhere('email', $payload['university_email']);
            })
            ->first();

        if (! $user || ! Hash::check($payload['password'], $user->password_hash)) {
            throw new ApiException('Invalid credentials.', [], Response::HTTP_UNAUTHORIZED);
        }

        if (! $user->is_active) {
            throw new ApiException('Your account is inactive.', [], Response::HTTP_FORBIDDEN);
        }

        return DB::transaction(function () use ($user, $payload) {
            $user->update(['last_login_at' => now()]);
            $tokens = $this->tokenService->issue($user, $payload['device_name'] ?? 'flutter-app');
            $this->auditLogService->log($user, 'staff-portal.login', $user, [], request());

            return [
                'user' => $user->fresh(['roles.permissions', 'permissions']),
                'tokens' => [
                    'access_token' => $tokens->accessToken,
                    'refresh_token' => $tokens->refreshToken,
                ],
            ];
        });
    }

    public function logout(User $user, ?string $refreshToken): void
    {
        if ($refreshToken) {
            $this->tokenService->revoke($refreshToken);
        }

        $user->currentAccessToken()?->delete();
        $this->auditLogService->log($user, 'staff-portal.logout', $user, [], request());
    }

    public function forgotPassword(array $payload): void
    {
        $user = User::query()
            ->where('university_email', $payload['university_email'])
            ->orWhere('email', $payload['university_email'])
            ->first();

        if ($user) {
            $this->auditLogService->log($user, 'staff-portal.password-reset-requested', $user, [], request());
        }
    }
}
