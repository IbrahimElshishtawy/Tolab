<?php

namespace App\Modules\Enrollment\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EnrollmentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $occupancy = (int) ($this->courseOffering?->enrollments_count ?? 0);
        $capacity = max($occupancy + 8, 40);

        return [
            'id' => $this->id,
            'student_user_id' => $this->student_user_id,
            'course_offering_id' => $this->course_offering_id,
            'status' => $this->status ?? 'pending',
            'student' => [
                'id' => $this->student?->id,
                'name' => $this->student?->username,
                'email' => $this->student?->email,
            ],
            'course' => [
                'id' => $this->courseOffering?->subject?->id,
                'code' => $this->courseOffering?->subject?->code,
                'name' => $this->courseOffering?->subject?->name,
                'department_name' => $this->courseOffering?->subject?->department?->name,
            ],
            'section' => [
                'id' => $this->courseOffering?->section?->id,
                'name' => $this->courseOffering?->section?->name,
                'department_name' => $this->courseOffering?->section?->department?->name,
                'capacity' => $capacity,
                'occupancy' => $occupancy,
            ],
            'doctor' => $this->courseOffering?->doctor ? [
                'id' => $this->courseOffering->doctor->id,
                'name' => $this->courseOffering->doctor->username,
                'email' => $this->courseOffering->doctor->email,
            ] : null,
            'assistant' => $this->courseOffering?->ta ? [
                'id' => $this->courseOffering->ta->id,
                'name' => $this->courseOffering->ta->username,
                'email' => $this->courseOffering->ta->email,
            ] : null,
            'department_name' => $this->courseOffering?->section?->department?->name ?? $this->courseOffering?->subject?->department?->name,
            'semester' => $this->courseOffering?->semester,
            'academic_year' => $this->courseOffering?->academic_year,
            'section_capacity' => $capacity,
            'section_occupancy' => $occupancy,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
