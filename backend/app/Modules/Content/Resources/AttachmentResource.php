<?php

namespace App\Modules\Content\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AttachmentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'file_url' => $this->file_url,
            'file_name' => $this->file_name,
            'mime_type' => $this->mime_type,
            'size' => $this->size,
            'uploaded_by' => $this->uploaded_by,
            'created_at' => $this->created_at,
        ];
    }
}
