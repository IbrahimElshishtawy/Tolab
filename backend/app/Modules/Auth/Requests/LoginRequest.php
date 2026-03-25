<?php

namespace App\Modules\Auth\Requests;

use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            // Accept local/dev domains like admin@tolab.local during development.
            'email' => ['required', 'email:rfc'],
            'password' => ['required', 'string', 'min:6', 'max:255'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ];
    }
}
