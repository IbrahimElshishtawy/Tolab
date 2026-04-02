<?php

namespace App\Modules\StaffPortal\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UploadPortalResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->file_name,
            'mime_type' => $this->mime_type,
            'size_label' => number_format(($this->size ?? 0) / 1024, 1).' KB',
            'url' => $this->file_url,
        ];
    }
}
