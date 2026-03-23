<?php

namespace App\Modules\Group\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CommentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'post_id' => $this->post_id,
            'author_user_id' => $this->author_user_id,
            'text' => $this->text,
            'created_at' => $this->created_at,
        ];
    }
}
