<?php

namespace App\Modules\UserManagement\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'role' => $this->role->value,
            'username' => $this->username,
            'email' => $this->email,
            'national_id' => $this->national_id,
            'is_active' => $this->is_active,
            'student_profile' => $this->whenLoaded('studentProfile', function () {
                return [
                    'gpa' => $this->studentProfile?->gpa,
                    'grade_year' => $this->studentProfile?->grade_year,
                    'section_id' => $this->studentProfile?->section_id,
                    'department_id' => $this->studentProfile?->department_id,
                ];
            }),
            'staff_profile' => $this->whenLoaded('staffProfile', function () {
                return [
                    'department_id' => $this->staffProfile?->department_id,
                    'title' => $this->staffProfile?->title?->value,
                ];
            }),
            'staff_permissions' => $this->whenLoaded('staffPermission', function () {
                return [
                    'can_upload_content' => $this->staffPermission?->can_upload_content ?? false,
                    'can_manage_grades' => $this->staffPermission?->can_manage_grades ?? false,
                    'can_manage_schedule' => $this->staffPermission?->can_manage_schedule ?? false,
                    'can_moderate_group' => $this->staffPermission?->can_moderate_group ?? false,
                ];
            }),
            'created_at' => $this->created_at,
        ];
    }
}
