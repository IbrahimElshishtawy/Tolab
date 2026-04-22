<?php

namespace App\Modules\StaffPortal\Services;

use App\Core\Enums\UserRole;
use App\Core\Exceptions\ApiException;
use App\Modules\Auth\Services\TokenService;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\UserManagement\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class PortalAuthService
{
    public function __construct(
        protected TokenService $tokenService,
        protected AuditLogService $auditLogService,
    ) {}

    public function login(array $payload): array
    {
        $user = $this->findUserByLoginIdentifier($payload['university_email']);

        if (! $user || ! Hash::check($payload['password'], $user->password_hash)) {
            throw new ApiException('Invalid credentials.', [], Response::HTTP_UNAUTHORIZED);
        }

        if (! $this->canAccessPortal($user)) {
            throw new ApiException('Only admin, doctor, and assistant accounts can access this portal.', [], Response::HTTP_FORBIDDEN);
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

    public function refresh(array $payload): array
    {
        return DB::transaction(function () use ($payload) {
            $tokens = $this->tokenService->rotate(
                $payload['refresh_token'],
                $payload['device_name'] ?? 'flutter-app',
            );

            if (! $tokens->user->is_active) {
                throw new ApiException('Your account is inactive.', [], Response::HTTP_FORBIDDEN);
            }

            if (! $this->canAccessPortal($tokens->user)) {
                throw new ApiException('Only admin, doctor, and assistant accounts can access this portal.', [], Response::HTTP_FORBIDDEN);
            }

            $this->auditLogService->log($tokens->user, 'staff-portal.refresh', $tokens->user, [], request());

            return [
                'user' => $tokens->user->fresh(['roles.permissions', 'permissions']),
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
        $user = $this->findUserByLoginIdentifier($payload['university_email']);

        if ($user) {
            $this->auditLogService->log($user, 'staff-portal.password-reset-requested', $user, [], request());
        }
    }

    protected function findUserByLoginIdentifier(string $identifier): ?User
    {
        $emails = $this->candidateEmails($identifier);

        return User::query()
            ->where(function ($query) use ($emails) {
                if (Schema::hasColumn('users', 'university_email')) {
                    $query->whereIn('university_email', $emails)
                        ->orWhereIn('email', $emails);

                    return;
                }

                $query->whereIn('email', $emails);
            })
            ->first();
    }

    protected function candidateEmails(string $identifier): array
    {
        $normalized = Str::lower(trim($identifier));
        $localPart = Str::before($normalized, '@');
        $domain = Str::after($normalized, '@');

        $localParts = [$localPart];
        if ($localPart === 'assistant') {
            $localParts[] = 'ta';
        } elseif ($localPart === 'ta') {
            $localParts[] = 'assistant';
        }

        $domains = [$domain];
        if ($domain === 'tolab.local') {
            $domains[] = 'tolab.edu';
        } elseif ($domain === 'tolab.edu') {
            $domains[] = 'tolab.local';
        }

        $candidates = [];
        foreach ($localParts as $candidateLocalPart) {
            foreach ($domains as $candidateDomain) {
                $candidates[] = $candidateLocalPart.'@'.$candidateDomain;
            }
        }

        return array_values(array_unique(array_filter($candidates)));
    }

    protected function canAccessPortal(User $user): bool
    {
        return $user->role === UserRole::ADMIN || $user->role?->isStaff();
    }
}
