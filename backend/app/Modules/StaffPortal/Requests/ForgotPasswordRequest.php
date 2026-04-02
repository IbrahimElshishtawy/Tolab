<?php

namespace App\Modules\StaffPortal\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ForgotPasswordRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'university_email' => ['required', 'email'],
        ];
    }
}
