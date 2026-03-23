<?php

namespace App\Modules\Notifications\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserNotificationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'body' => $this->body,
            'type' => $this->type->value,
            'ref_type' => $this->ref_type,
            'ref_id' => $this->ref_id,
            'is_read' => $this->is_read,
            'created_at' => $this->created_at,
        ];
    }
}
