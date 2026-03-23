<?php

namespace App\Modules\Enrollment\Requests;

use Illuminate\Foundation\Http\FormRequest;

class BulkEnrollmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'enrollments' => ['required', 'array', 'min:1'],
            'enrollments.*.student_user_id' => ['required', 'integer', 'exists:users,id'],
            'enrollments.*.course_offering_id' => ['required', 'integer', 'exists:course_offerings,id'],
        ];
    }
}
