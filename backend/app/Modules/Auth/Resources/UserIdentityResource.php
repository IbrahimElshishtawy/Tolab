<?php

namespace App\Modules\Auth\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserIdentityResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'role' => $this->role->value,
            'username' => $this->username,
            'email' => $this->email,
        ];
    }
}
