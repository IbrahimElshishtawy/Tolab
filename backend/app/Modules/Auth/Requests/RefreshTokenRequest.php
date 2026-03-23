<?php

namespace App\Modules\Auth\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RefreshTokenRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'refresh_token' => ['required', 'string', 'min:32', 'max:255'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ];
    }
}
