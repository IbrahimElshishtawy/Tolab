<?php

namespace App\Modules\Academic\Requests;

use App\Core\Enums\Semester;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateCourseOfferingRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'subject_id' => ['sometimes', 'integer', 'exists:subjects,id'],
            'section_id' => ['sometimes', 'integer', 'exists:sections,id'],
            'academic_year' => ['sometimes', 'string', 'max:20'],
            'semester' => ['sometimes', Rule::enum(Semester::class)],
            'doctor_user_id' => ['nullable', 'integer', 'exists:users,id'],
            'ta_user_id' => ['nullable', 'integer', 'exists:users,id'],
        ];
    }
}
