<?php

namespace App\Modules\Grades\Requests;

use App\Modules\Grades\Enums\GradeType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateGradeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'student_user_id' => ['sometimes', 'integer', 'exists:users,id'],
            'type' => ['sometimes', Rule::enum(GradeType::class)],
            'score' => ['sometimes', 'numeric', 'min:0'],
            'max_score' => ['sometimes', 'numeric', 'gt:0'],
            'note' => ['nullable', 'string'],
        ];
    }
}
