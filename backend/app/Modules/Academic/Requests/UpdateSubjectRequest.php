<?php

namespace App\Modules\Academic\Requests;

use App\Core\Enums\Semester;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateSubjectRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $subjectId = $this->route('subject')?->id ?? $this->route('id');

        return [
            'name' => ['sometimes', 'string', 'max:150'],
            'code' => ['sometimes', 'string', 'max:40', Rule::unique('subjects', 'code')->ignore($subjectId)],
            'department_id' => ['sometimes', 'integer', 'exists:departments,id'],
            'grade_year' => ['sometimes', 'integer', 'between:1,5'],
            'semester' => ['sometimes', Rule::enum(Semester::class)],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }
}
