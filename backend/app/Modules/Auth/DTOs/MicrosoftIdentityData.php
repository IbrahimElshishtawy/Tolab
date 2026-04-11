<?php

namespace App\Modules\Auth\DTOs;

class MicrosoftIdentityData
{
    public function __construct(
        public readonly string $microsoftId,
        public readonly string $email,
        public readonly ?string $name,
        public readonly ?string $avatar,
        public readonly array $claims = [],
        public readonly array $raw = [],
    ) {
    }

    public function toArray(): array
    {
        return [
            'microsoft_id' => $this->microsoftId,
            'email' => $this->email,
            'name' => $this->name,
            'avatar' => $this->avatar,
            'claims' => $this->claims,
            'raw' => $this->raw,
        ];
    }
}
