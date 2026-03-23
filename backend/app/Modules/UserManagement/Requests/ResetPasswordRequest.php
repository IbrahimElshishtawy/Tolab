<?php

namespace App\Modules\UserManagement\Requests;

use App\Core\Enums\PasswordResetMode;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ResetPasswordRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'mode' => ['required', Rule::enum(PasswordResetMode::class)],
            'password' => ['required_if:mode,'.PasswordResetMode::CUSTOM->value, 'nullable', 'string', 'min:8', 'max:255'],
        ];
    }
}
