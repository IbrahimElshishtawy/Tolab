<?php

namespace App\Modules\StaffPortal\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class QuizPortalResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'subject_id' => $this->subject_id,
            'title' => $this->title,
            'owner_name' => $this->owner_name,
            'quiz_type' => $this->quiz_type,
            'quiz_link' => $this->quiz_link,
            'quiz_date' => optional($this->quiz_date)->format('Y-m-d'),
            'is_published' => $this->is_published,
        ];
    }
}
