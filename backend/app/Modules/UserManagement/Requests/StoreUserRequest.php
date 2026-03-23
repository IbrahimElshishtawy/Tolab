<?php

namespace App\Modules\UserManagement\Requests;

use App\Core\Enums\StaffTitle;
use App\Core\Enums\UserRole;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'role' => ['required', Rule::enum(UserRole::class)],
            'username' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email:rfc,dns', 'max:255', 'unique:users,email'],
            'password' => ['nullable', 'string', 'min:8', 'max:255'],
            'national_id' => ['nullable', 'string', 'max:40', 'unique:users,national_id'],
            'is_active' => ['sometimes', 'boolean'],
            'student_profile' => ['nullable', 'array'],
            'student_profile.gpa' => ['nullable', 'numeric', 'between:0,4'],
            'student_profile.grade_year' => ['required_if:role,'.UserRole::STUDENT->value, 'integer', 'between:1,5'],
            'student_profile.section_id' => ['nullable', 'integer', 'exists:sections,id'],
            'student_profile.department_id' => ['nullable', 'integer', 'exists:departments,id'],
            'staff_profile' => ['nullable', 'array'],
            'staff_profile.department_id' => ['nullable', 'integer', 'exists:departments,id'],
            'staff_profile.title' => ['nullable', Rule::enum(StaffTitle::class)],
            'staff_permissions' => ['nullable', 'array'],
            'staff_permissions.can_upload_content' => ['sometimes', 'boolean'],
            'staff_permissions.can_manage_grades' => ['sometimes', 'boolean'],
            'staff_permissions.can_manage_schedule' => ['sometimes', 'boolean'],
            'staff_permissions.can_moderate_group' => ['sometimes', 'boolean'],
        ];
    }
}
