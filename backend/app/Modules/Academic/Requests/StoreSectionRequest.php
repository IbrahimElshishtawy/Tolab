<?php

namespace App\Modules\Academic\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreSectionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:150'],
            'grade_year' => ['required', 'integer', 'between:1,5'],
            'department_id' => ['required', 'integer', 'exists:departments,id'],
        ];
    }
}
