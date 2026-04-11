<?php

namespace App\Modules\Group\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MessageResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'group_id' => $this->group_id,
            'sender_user_id' => $this->sender_user_id,
            'text' => $this->text,
            'sender' => $this->whenLoaded('sender', fn () => $this->sender ? [
                'id' => $this->sender->id,
                'username' => $this->sender->username,
                'full_name' => $this->sender->full_name,
                'avatar' => $this->sender->avatar,
            ] : null),
            'created_at' => $this->created_at,
        ];
    }
}
