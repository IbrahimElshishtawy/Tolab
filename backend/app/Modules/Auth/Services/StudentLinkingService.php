<?php

namespace App\Modules\Auth\Services;

use App\Core\Enums\UserRole;
use App\Core\Exceptions\ApiException;
use App\Modules\Auth\DTOs\AuthTokenData;
use App\Modules\Auth\DTOs\MicrosoftIdentityData;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\UserManagement\Models\User;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class StudentLinkingService
{
    private const LINK_TOKEN_PREFIX = 'microsoft-link:';

    private const LINK_TOKEN_TTL_MINUTES = 10;

    public function __construct(
        protected TokenService $tokenService,
        protected AuditLogService $auditLogService,
    ) {}

    public function createLinkChallenge(User $student, MicrosoftIdentityData $identity): array
    {
        $linkToken = Str::random(96);
        $expiresAt = now()->addMinutes(self::LINK_TOKEN_TTL_MINUTES);

        Cache::put($this->cacheKey($linkToken), [
            'user_id' => $student->id,
            'microsoft_id' => $identity->microsoftId,
            'microsoft_email' => $identity->email,
            'microsoft_name' => $identity->name,
            'microsoft_avatar' => $identity->avatar,
            'claims' => $identity->claims,
        ], $expiresAt);

        $this->auditLogService->log(null, 'auth.microsoft.link-challenge', $student, [
            'email' => $identity->email,
        ], request());

        return [
            'status' => 'link_required',
            'link_token' => $linkToken,
            'expires_at' => $expiresAt->toIso8601String(),
            'user' => [
                'id' => $student->id,
                'name' => $student->full_name,
                'university_email' => $student->university_email,
            ],
        ];
    }

    public function completeLink(array $payload): AuthTokenData
    {
        $linkPayload = Cache::get($this->cacheKey($payload['link_token']));

        if (! is_array($linkPayload)) {
            throw new ApiException('The Microsoft link session is invalid or has expired.', [], Response::HTTP_UNAUTHORIZED);
        }

        $student = User::query()
            ->whereKey($linkPayload['user_id'])
            ->where('role', UserRole::STUDENT->value)
            ->first();

        if (! $student) {
            Cache::forget($this->cacheKey($payload['link_token']));

            throw new ApiException('The requested student account could not be found.', [], Response::HTTP_NOT_FOUND);
        }

        if (! $student->is_active) {
            throw new ApiException('This student account is inactive.', [], Response::HTTP_FORBIDDEN);
        }

        if (! hash_equals((string) $student->national_id, (string) $payload['national_id'])) {
            Log::warning('Microsoft student link rejected due to national ID mismatch.', [
                'user_id' => $student->id,
                'ip' => request()->ip(),
            ]);

            $this->auditLogService->log(null, 'auth.microsoft.link-failed', $student, [
                'reason' => 'national_id_mismatch',
            ], request());

            throw new ApiException(
                'Unable to verify your identity with the provided information.',
                ['national_id' => ['Unable to verify your identity with the provided information.']],
                Response::HTTP_UNPROCESSABLE_ENTITY
            );
        }

        $conflict = User::query()
            ->where('microsoft_id', $linkPayload['microsoft_id'])
            ->whereKeyNot($student->id)
            ->exists();

        if ($conflict) {
            throw new ApiException('This Microsoft account is already linked to another student.', [], Response::HTTP_CONFLICT);
        }

        $tokens = DB::transaction(function () use ($student, $linkPayload, $payload) {
            $student->forceFill([
                'microsoft_id' => $linkPayload['microsoft_id'],
                'microsoft_email' => $linkPayload['microsoft_email'],
                'microsoft_name' => $linkPayload['microsoft_name'],
                'microsoft_avatar' => $linkPayload['microsoft_avatar'],
                'is_microsoft_linked' => true,
                'last_login_at' => now(),
            ])->save();

            $tokens = $this->tokenService->issue($student->fresh(['studentProfile', 'staffProfile', 'staffPermission']), $payload['device_name'] ?? 'microsoft-link');

            $this->auditLogService->log($student, 'auth.microsoft.linked', $student, [
                'microsoft_email' => $linkPayload['microsoft_email'],
            ], request());

            return $tokens;
        });

        Cache::forget($this->cacheKey($payload['link_token']));

        return $tokens;
    }

    public function authenticateLinkedStudent(User $student, MicrosoftIdentityData $identity): AuthTokenData
    {
        return DB::transaction(function () use ($student, $identity) {
            $student->forceFill([
                'microsoft_email' => $identity->email,
                'microsoft_name' => $identity->name,
                'microsoft_avatar' => $identity->avatar,
                'last_login_at' => now(),
            ])->save();

            $tokens = $this->tokenService->issue($student->fresh(['studentProfile', 'staffProfile', 'staffPermission']), 'microsoft-login');

            $this->auditLogService->log($student, 'auth.microsoft.login', $student, [
                'microsoft_email' => $identity->email,
            ], request());

            return $tokens;
        });
    }

    protected function cacheKey(string $linkToken): string
    {
        return self::LINK_TOKEN_PREFIX.$linkToken;
    }
}
