<?php

namespace App\Modules\Group\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PostResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'group_id' => $this->group_id,
            'author_user_id' => $this->author_user_id,
            'content_text' => $this->content_text,
            'created_at' => $this->created_at,
        ];
    }
}
