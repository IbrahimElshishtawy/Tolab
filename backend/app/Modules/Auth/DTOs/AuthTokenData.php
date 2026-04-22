<?php

namespace App\Modules\Auth\DTOs;

use App\Modules\UserManagement\Models\User;

readonly class AuthTokenData
{
    public function __construct(
        public string $accessToken,
        public string $refreshToken,
        public User $user,
    ) {}
}
