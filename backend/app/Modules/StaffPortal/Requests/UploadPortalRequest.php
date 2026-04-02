<?php

namespace App\Modules\StaffPortal\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UploadPortalRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'file' => ['required', 'file', 'mimes:pdf,png,jpg,jpeg', 'max:10240'],
        ];
    }
}
