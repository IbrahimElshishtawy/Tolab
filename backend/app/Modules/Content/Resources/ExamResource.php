<?php

namespace App\Modules\Content\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ExamResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'exam_at' => $this->exam_at,
            'attachments' => AttachmentResource::collection($this->whenLoaded('attachments')),
        ];
    }
}
