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
            'name' => $this->full_name,
            'full_name' => $this->full_name,
            'email' => $this->email,
            'university_email' => $this->university_email,
            'is_microsoft_linked' => $this->is_microsoft_linked,
            'is_active' => $this->is_active,
            'last_login_at' => $this->last_login_at,
        ];
    }
}
