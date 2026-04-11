<?php

namespace App\Modules\Academic\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CourseOfferingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'academic_year' => $this->academic_year,
            'semester' => $this->semester->value,
            'subject' => $this->whenLoaded('subject', fn () => [
                'id' => $this->subject?->id,
                'name' => $this->subject?->name,
                'code' => $this->subject?->code,
                'department_id' => $this->subject?->department_id,
                'department_name' => $this->subject?->department?->name,
            ]),
            'section' => $this->whenLoaded('section', fn () => [
                'id' => $this->section?->id,
                'name' => $this->section?->name,
                'grade_year' => $this->section?->grade_year,
                'department_id' => $this->section?->department_id,
                'department_name' => $this->section?->department?->name,
            ]),
            'doctor' => $this->whenLoaded('doctor', fn () => $this->doctor ? [
                'id' => $this->doctor->id,
                'username' => $this->doctor->username,
                'full_name' => $this->doctor->full_name,
                'email' => $this->doctor->email,
            ] : null),
            'ta' => $this->whenLoaded('ta', fn () => $this->ta ? [
                'id' => $this->ta->id,
                'username' => $this->ta->username,
                'full_name' => $this->ta->full_name,
                'email' => $this->ta->email,
            ] : null),
            'group' => $this->whenLoaded('group', fn () => $this->group ? [
                'id' => $this->group->id,
                'name' => $this->group->name,
            ] : null),
        ];
    }
}
