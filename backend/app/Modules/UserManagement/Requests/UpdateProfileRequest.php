<?php

namespace App\Modules\UserManagement\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'username' => ['sometimes', 'string', 'max:120'],
            'full_name' => ['sometimes', 'nullable', 'string', 'max:180'],
            'phone' => ['sometimes', 'nullable', 'string', 'max:40'],
            'avatar' => ['sometimes', 'nullable', 'string', 'max:255'],
            'language' => ['sometimes', 'nullable', 'string', 'max:10'],
            'notification_enabled' => ['sometimes', 'boolean'],
        ];
    }
}
