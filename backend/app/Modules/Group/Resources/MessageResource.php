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
            'created_at' => $this->created_at,
        ];
    }
}
