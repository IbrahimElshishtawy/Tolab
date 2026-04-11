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
            'author' => $this->whenLoaded('author', fn () => $this->author ? [
                'id' => $this->author->id,
                'username' => $this->author->username,
                'full_name' => $this->author->full_name,
                'avatar' => $this->author->avatar,
            ] : null),
            'created_at' => $this->created_at,
        ];
    }
}
