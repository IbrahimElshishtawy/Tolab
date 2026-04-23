<?php

namespace App\Modules\StaffPortal\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreSubjectGroupPostRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:180'],
            'content' => ['required', 'string', 'max:5000'],
            'post_type' => ['nullable', 'string', 'max:30'],
            'priority' => ['nullable', 'string', 'max:20'],
            'is_pinned' => ['nullable', 'boolean'],
            'attachment_label' => ['nullable', 'string', 'max:180'],
            'attachment_url' => ['nullable', 'url', 'max:255'],
        ];
    }
}
