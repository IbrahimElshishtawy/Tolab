<?php

namespace App\Modules\StaffPortal\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TaskPortalResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'subject_id' => $this->subject_id,
            'title' => $this->title,
            'owner_name' => $this->owner_name,
            'lecture_or_section_name' => $this->lecture_or_section_name,
            'file_url' => $this->file_path,
            'due_date' => optional($this->due_date)->format('Y-m-d'),
            'is_published' => $this->is_published,
        ];
    }
}
