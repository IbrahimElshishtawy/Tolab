<?php

namespace App\Modules\StaffPortal\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SubjectPortalResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'code' => $this->code,
            'description' => $this->description,
            'department_name' => $this->department?->name,
            'academic_year_name' => $this->academicYear?->name ?? (string) $this->grade_year,
            'is_active' => $this->is_active,
            'sections' => $this->whenLoaded('sections', fn () => $this->sections->map(fn ($section) => [
                'id' => $section->id,
                'name' => $section->name,
                'code' => $section->code,
                'assistant_name' => $section->assistant?->full_name ?: $section->assistant?->username,
                'is_active' => $section->is_active,
            ])->values()),
        ];
    }
}
