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
            'author' => $this->whenLoaded('author', fn () => $this->author ? [
                'id' => $this->author->id,
                'username' => $this->author->username,
                'full_name' => $this->author->full_name,
                'avatar' => $this->author->avatar,
            ] : null),
            'comments_count' => $this->whenCounted('comments'),
            'created_at' => $this->created_at,
        ];
    }
}
