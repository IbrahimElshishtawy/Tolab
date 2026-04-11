<?php

namespace App\Modules\Group\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GroupResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'course_offering_id' => $this->course_offering_id,
            'name' => $this->name,
            'description' => $this->description,
            'course' => $this->whenLoaded('courseOffering', fn () => $this->courseOffering ? [
                'id' => $this->courseOffering->id,
                'academic_year' => $this->courseOffering->academic_year,
                'semester' => $this->courseOffering->semester?->value ?? $this->courseOffering->semester,
                'subject' => [
                    'id' => $this->courseOffering->subject?->id,
                    'name' => $this->courseOffering->subject?->name,
                    'code' => $this->courseOffering->subject?->code,
                ],
                'section' => [
                    'id' => $this->courseOffering->section?->id,
                    'name' => $this->courseOffering->section?->name,
                ],
            ] : null),
            'members_count' => $this->whenCounted('members'),
        ];
    }
}
