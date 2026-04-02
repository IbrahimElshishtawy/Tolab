<?php

namespace App\Modules\StaffPortal\Resources;

use App\Core\Enums\UserRole;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SessionUserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'full_name' => $this->full_name ?: $this->username,
            'university_email' => $this->university_email ?: $this->email,
            'role_type' => $this->role_type ?: match ($this->role) {
                UserRole::ADMIN => 'admin',
                UserRole::DOCTOR => 'doctor',
                UserRole::TA => 'assistant',
                default => 'assistant',
            },
            'is_active' => $this->is_active,
            'avatar' => $this->avatar,
            'phone' => $this->phone,
            'notification_enabled' => $this->notification_enabled,
            'language' => $this->language,
            'permissions' => $this->effectivePermissions(),
        ];
    }
}
