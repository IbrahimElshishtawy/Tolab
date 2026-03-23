<?php

namespace App\Modules\UserManagement\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ToggleActivationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'is_active' => ['required', 'boolean'],
        ];
    }
}
