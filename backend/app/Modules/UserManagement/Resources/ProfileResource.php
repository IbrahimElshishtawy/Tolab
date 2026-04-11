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
            'full_name' => $this->full_name,
            'email' => $this->email,
            'university_email' => $this->university_email,
            'is_microsoft_linked' => $this->is_microsoft_linked,
            'is_active' => $this->is_active,
            'phone' => $this->phone,
            'avatar' => $this->avatar,
            'language' => $this->language,
            'notification_enabled' => $this->notification_enabled,
            'student_profile' => $this->studentProfile ? [
                'student_code' => $this->studentProfile->student_code,
                'gpa' => $this->studentProfile->gpa,
                'grade_year' => $this->studentProfile->grade_year,
                'department_id' => $this->studentProfile->department_id,
                'department_name' => $this->studentProfile->department?->name,
                'section_id' => $this->studentProfile->section_id,
                'section_name' => $this->studentProfile->section?->name,
            ] : null,
            'staff_profile' => [
                'department_id' => $this->staffProfile?->department_id,
                'department_name' => $this->staffProfile?->department?->name,
                'title' => $this->staffProfile?->title?->value,
            ],
            'staff_permissions' => $this->staffPermission ? [
                'can_upload_content' => $this->staffPermission->can_upload_content,
                'can_manage_grades' => $this->staffPermission->can_manage_grades,
                'can_manage_schedule' => $this->staffPermission->can_manage_schedule,
                'can_moderate_group' => $this->staffPermission->can_moderate_group,
            ] : null,
        ];
    }
}
