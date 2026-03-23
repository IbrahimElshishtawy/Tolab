<?php

namespace App\Modules\UserManagement\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProfileResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'role' => $this->role->value,
            'username' => $this->username,
            'email' => $this->email,
            'is_active' => $this->is_active,
            'student_profile' => $this->studentProfile,
            'staff_profile' => [
                'department_id' => $this->staffProfile?->department_id,
                'title' => $this->staffProfile?->title?->value,
            ],
            'staff_permissions' => $this->staffPermission,
        ];
    }
}
