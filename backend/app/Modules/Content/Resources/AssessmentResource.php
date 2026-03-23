<?php

namespace App\Modules\Content\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AssessmentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'type' => $this->type->value,
            'title' => $this->title,
            'description' => $this->description,
            'due_at' => $this->due_at,
            'attachments' => AttachmentResource::collection($this->whenLoaded('attachments')),
        ];
    }
}
