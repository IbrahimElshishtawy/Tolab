<?php

namespace App\Modules\Auth\Services;

use App\Modules\Auth\DTOs\AuthTokenData;
use App\Modules\Shared\Models\RefreshToken;
use App\Modules\UserManagement\Models\User;
use Illuminate\Support\Str;

class TokenService
{
    public function issue(User $user, ?string $deviceName = null): AuthTokenData
    {
        $accessToken = $user->createToken($deviceName ?: 'mobile-app')->plainTextToken;
        $plainRefreshToken = Str::random(96);

        RefreshToken::query()->create([
            'user_id' => $user->id,
            'token_hash' => $this->hash($plainRefreshToken),
            'expires_at' => now()->addDays((int) env('AUTH_REFRESH_TOKEN_DAYS', 30)),
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);

        return new AuthTokenData(
            accessToken: $accessToken,
            refreshToken: $plainRefreshToken,
            user: $user->fresh(['studentProfile', 'staffProfile', 'staffPermission'])
        );
    }

    public function rotate(string $plainRefreshToken, ?string $deviceName = null): AuthTokenData
    {
        $refreshToken = RefreshToken::query()
            ->where('token_hash', $this->hash($plainRefreshToken))
            ->whereNull('revoked_at')
            ->where('expires_at', '>', now())
            ->firstOrFail();

        $refreshToken->update([
            'revoked_at' => now(),
            'last_used_at' => now(),
        ]);

        return $this->issue($refreshToken->user, $deviceName);
    }

    public function revoke(string $plainRefreshToken): void
    {
        RefreshToken::query()
            ->where('token_hash', $this->hash($plainRefreshToken))
            ->whereNull('revoked_at')
            ->update([
                'revoked_at' => now(),
            ]);
    }

    public function hash(string $plainToken): string
    {
        return hash_hmac('sha256', $plainToken, (string) env('AUTH_REFRESH_TOKEN_PEPPER', 'tolab-refresh-token'));
    }
}
