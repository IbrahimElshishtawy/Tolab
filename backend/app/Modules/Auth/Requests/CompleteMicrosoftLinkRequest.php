<?php

namespace App\Modules\Auth\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CompleteMicrosoftLinkRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'link_token' => ['required', 'string', 'max:255'],
            'national_id' => ['required', 'regex:/^\d{14}$/'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ];
    }
}
