<?php

namespace App\Modules\Enrollment\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreEnrollmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'student_user_id' => ['required', 'integer', 'exists:users,id'],
            'course_offering_id' => ['required', 'integer', 'exists:course_offerings,id'],
        ];
    }
}
