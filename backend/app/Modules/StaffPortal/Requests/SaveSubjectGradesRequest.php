<?php

namespace App\Modules\StaffPortal\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SaveSubjectGradesRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category_key' => ['required', 'string', 'max:40'],
            'max_score' => ['required', 'numeric', 'min:0', 'max:1000'],
            'entries' => ['required', 'array', 'min:1'],
            'entries.*.student_code' => ['required', 'string', 'max:40'],
            'entries.*.score' => ['nullable', 'numeric', 'min:0', 'max:1000'],
            'entries.*.note' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
