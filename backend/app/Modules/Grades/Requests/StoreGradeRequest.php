<?php

namespace App\Modules\Grades\Requests;

use App\Modules\Grades\Enums\GradeType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreGradeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'student_user_id' => ['required', 'integer', 'exists:users,id'],
            'type' => ['required', Rule::enum(GradeType::class)],
            'score' => ['required', 'numeric', 'min:0'],
            'max_score' => ['required', 'numeric', 'gt:0'],
            'note' => ['nullable', 'string'],
        ];
    }
}
