<?php

namespace App\Modules\Academic\Requests;

use App\Core\Enums\Semester;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreSubjectRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:150'],
            'code' => ['required', 'string', 'max:40', 'unique:subjects,code'],
            'department_id' => ['required', 'integer', 'exists:departments,id'],
            'grade_year' => ['required', 'integer', 'between:1,5'],
            'semester' => ['required', Rule::enum(Semester::class)],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}
