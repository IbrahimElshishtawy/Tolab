<?php

namespace App\Modules\StaffPortal\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePortalSettingsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'language' => ['nullable', 'string', 'max:10'],
            'notification_enabled' => ['nullable', 'boolean'],
            'phone' => ['nullable', 'string', 'max:40'],
        ];
    }
}
