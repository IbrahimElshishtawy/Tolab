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
            ]),
            'section' => $this->whenLoaded('section', fn () => [
                'id' => $this->section?->id,
                'name' => $this->section?->name,
                'grade_year' => $this->section?->grade_year,
            ]),
            'doctor' => $this->whenLoaded('doctor', fn () => $this->doctor ? [
                'id' => $this->doctor->id,
                'username' => $this->doctor->username,
            ] : null),
            'ta' => $this->whenLoaded('ta', fn () => $this->ta ? [
                'id' => $this->ta->id,
                'username' => $this->ta->username,
            ] : null),
            'group_id' => $this->group_id,
        ];
    }
}
