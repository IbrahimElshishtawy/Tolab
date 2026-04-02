<?php

namespace App\Modules\StaffPortal\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StaffMemberResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'user' => SessionUserResource::make($this),
            'department_name' => $this->staffProfile?->department?->name,
            'assignment_summary' => $this->staffAssignments
                ->map(fn ($assignment) => $assignment->subject?->name)
                ->filter()
                ->join(', '),
        ];
    }
}
