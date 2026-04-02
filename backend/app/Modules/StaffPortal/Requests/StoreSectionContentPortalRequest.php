<?php

namespace App\Modules\StaffPortal\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreSectionContentPortalRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'subject_id' => ['nullable', 'integer', 'exists:subjects,id'],
            'title' => ['required', 'string', 'max:180'],
            'assistant_name' => ['nullable', 'string', 'max:180'],
            'week_number' => ['nullable', 'integer', 'between:1,20'],
            'video_url' => ['nullable', 'url'],
        ];
    }
}
