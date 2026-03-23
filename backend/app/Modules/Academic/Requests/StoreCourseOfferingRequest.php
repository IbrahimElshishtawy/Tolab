<?php

namespace App\Modules\Academic\Requests;

use App\Core\Enums\Semester;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreCourseOfferingRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'subject_id' => ['required', 'integer', 'exists:subjects,id'],
            'section_id' => ['required', 'integer', 'exists:sections,id'],
            'academic_year' => ['required', 'string', 'max:20'],
            'semester' => ['required', Rule::enum(Semester::class)],
            'doctor_user_id' => ['nullable', 'integer', 'exists:users,id'],
            'ta_user_id' => ['nullable', 'integer', 'exists:users,id'],
        ];
    }
}
