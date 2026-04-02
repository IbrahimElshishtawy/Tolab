<?php

namespace App\Modules\StaffPortal\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreTaskPortalRequest extends FormRequest
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
            'owner_name' => ['nullable', 'string', 'max:180'],
            'lecture_or_section_name' => ['nullable', 'string', 'max:180'],
            'due_date' => ['nullable', 'date'],
            'week_number' => ['nullable', 'integer', 'between:1,20'],
        ];
    }
}
