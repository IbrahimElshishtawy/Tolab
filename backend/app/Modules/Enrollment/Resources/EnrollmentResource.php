<?php

namespace App\Modules\Enrollment\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EnrollmentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'student_user_id' => $this->student_user_id,
            'course_offering_id' => $this->course_offering_id,
            'created_at' => $this->created_at,
        ];
    }
}
