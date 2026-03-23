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
        ];
    }
}
