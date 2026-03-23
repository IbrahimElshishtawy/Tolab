<?php

namespace App\Modules\Content\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CourseFileResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'file_url' => $this->file_url,
            'category' => $this->category,
        ];
    }
}
