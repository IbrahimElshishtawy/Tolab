<?php

namespace App\Modules\StaffPortal\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class LecturePortalResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'subject_id' => $this->subject_id,
            'title' => $this->title,
            'week_number' => $this->week_number,
            'instructor_name' => $this->instructor_name,
            'video_url' => $this->video_url,
            'file_url' => $this->file_path,
            'is_published' => $this->is_published,
            'published_at' => $this->published_at,
        ];
    }
}
