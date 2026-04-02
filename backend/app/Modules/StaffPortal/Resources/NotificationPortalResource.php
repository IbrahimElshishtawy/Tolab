<?php

namespace App\Modules\StaffPortal\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class NotificationPortalResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'body' => $this->body,
            'category' => $this->category ?: $this->type,
            'is_read' => $this->is_read,
            'created_at' => optional($this->created_at)->toIso8601String(),
        ];
    }
}
