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
            'subject_name' => $this->subject?->name,
            'title' => $this->title,
            'description' => $this->description,
            'week_number' => $this->week_number,
            'instructor_name' => $this->instructor_name,
            'video_url' => $this->video_url,
            'file_url' => $this->file_path,
            'is_published' => $this->is_published,
            'published_at' => optional($this->published_at)->toIso8601String(),
            'status_label' => ! $this->is_published ? 'Draft' : (($this->starts_at && now()->lt($this->starts_at)) ? 'Scheduled' : 'Published'),
            'delivery_mode' => $this->delivery_mode,
            'meeting_url' => $this->meeting_url,
            'starts_at' => optional($this->starts_at)->toIso8601String(),
            'ends_at' => optional($this->ends_at)->toIso8601String(),
            'location_label' => $this->location_label,
            'attachment_label' => $this->attachment_label,
            'publisher_name' => $this->author?->full_name ?: $this->author?->username,
        ];
    }
}
