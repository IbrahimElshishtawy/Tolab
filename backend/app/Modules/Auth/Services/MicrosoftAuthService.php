<?php

namespace App\Modules\Auth\Services;

use App\Core\Enums\UserRole;
use App\Core\Exceptions\ApiException;
use App\Modules\Auth\DTOs\MicrosoftIdentityData;
use App\Modules\UserManagement\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Arr;
use Illuminate\Support\Str;
use Laravel\Socialite\Facades\Socialite;
use Laravel\Socialite\Testing\FakeProvider;
use Laravel\Socialite\Two\InvalidStateException;
use SocialiteProviders\Manager\OAuth2\User as OAuthUser;
use Symfony\Component\HttpFoundation\Response;

class MicrosoftAuthService
{
    public function __construct(
        protected StudentLinkingService $studentLinkingService,
    ) {}

    public function redirect(): RedirectResponse
    {
        $driver = $this->driver();

        if ($driver instanceof FakeProvider) {
            return $driver->redirect();
        }

        return $driver
            ->with(['prompt' => 'select_account'])
            ->redirect();
    }

    public function handleCallback(): array
    {
        try {
            /** @var OAuthUser $socialiteUser */
            $socialiteUser = $this->driver()->user();
        } catch (InvalidStateException $exception) {
            throw new ApiException('The Microsoft authentication state is invalid or has expired.', [], Response::HTTP_UNAUTHORIZED);
        }

        $identity = $this->mapIdentity($socialiteUser);
        $emailMatchedStudent = $this->findStudentByUniversityEmail($identity->email);
        $microsoftMatchedStudent = $this->findStudentByMicrosoftId($identity->microsoftId);

        if ($microsoftMatchedStudent && (! $emailMatchedStudent || $microsoftMatchedStudent->id !== $emailMatchedStudent->id)) {
            throw new ApiException('This Microsoft account is already linked to another student.', [], Response::HTTP_CONFLICT);
        }

        if (! $emailMatchedStudent) {
            throw new ApiException('No student record was found for this Microsoft university email.', [], Response::HTTP_FORBIDDEN);
        }

        if (! $emailMatchedStudent->is_active) {
            throw new ApiException('This student account is inactive.', [], Response::HTTP_FORBIDDEN);
        }

        if ($emailMatchedStudent->is_microsoft_linked) {
            if (! hash_equals((string) $emailMatchedStudent->microsoft_id, $identity->microsoftId)) {
                throw new ApiException('This Microsoft account does not match the linked student account.', [], Response::HTTP_CONFLICT);
            }

            return [
                'status' => 'authenticated',
                'tokens' => $this->studentLinkingService->authenticateLinkedStudent($emailMatchedStudent, $identity),
            ];
        }

        return $this->studentLinkingService->createLinkChallenge($emailMatchedStudent, $identity);
    }

    protected function driver()
    {
        $driver = Socialite::driver('microsoft');

        if ($driver instanceof FakeProvider) {
            return $driver;
        }

        return $driver->scopes(['openid', 'profile', 'User.Read']);
    }

    protected function mapIdentity(OAuthUser $socialiteUser): MicrosoftIdentityData
    {
        $claims = $this->decodeIdTokenClaims($socialiteUser->accessTokenResponseBody['id_token'] ?? null);
        $raw = $socialiteUser->getRaw();
        $email = $this->normalizeEmail(
            Arr::get($raw, 'mail')
            ?? Arr::get($raw, 'userPrincipalName')
            ?? $socialiteUser->getEmail()
        );

        if (! $email) {
            throw new ApiException('Microsoft did not return a usable university email for this account.', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $microsoftId = Arr::get($claims, 'oid')
            ?? Arr::get($claims, 'sub')
            ?? $socialiteUser->getId();

        if (! $microsoftId) {
            throw new ApiException('Microsoft did not return a stable account identifier.', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $avatar = Arr::get($raw, 'avatar');

        return new MicrosoftIdentityData(
            microsoftId: (string) $microsoftId,
            email: $email,
            name: $socialiteUser->getName() ?: Arr::get($raw, 'displayName'),
            avatar: is_string($avatar) ? $avatar : null,
            claims: $claims,
            raw: $raw,
        );
    }

    protected function findStudentByUniversityEmail(string $email): ?User
    {
        return User::query()
            ->where('role', UserRole::STUDENT->value)
            ->where(function ($query) use ($email) {
                $query->whereRaw('LOWER(university_email) = ?', [$email])
                    ->orWhereRaw('LOWER(email) = ?', [$email]);
            })
            ->first();
    }

    protected function findStudentByMicrosoftId(string $microsoftId): ?User
    {
        return User::query()
            ->where('role', UserRole::STUDENT->value)
            ->where('microsoft_id', $microsoftId)
            ->first();
    }

    protected function decodeIdTokenClaims(?string $idToken): array
    {
        if (! $idToken || substr_count($idToken, '.') < 2) {
            return [];
        }

        [, $payload] = explode('.', $idToken, 3);
        $payload = strtr($payload, '-_', '+/');
        $payload .= str_repeat('=', (4 - strlen($payload) % 4) % 4);
        $json = base64_decode($payload);
        $claims = json_decode($json ?: '', true);

        return is_array($claims) ? $claims : [];
    }

    protected function normalizeEmail(?string $email): ?string
    {
        if (! $email) {
            return null;
        }

        return Str::lower(trim($email));
    }
}
