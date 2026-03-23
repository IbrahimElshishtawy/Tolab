<?php

namespace App\Modules\Group\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GroupResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'course_offering_id' => $this->course_offering_id,
            'name' => $this->name,
            'description' => $this->description,
            'members_count' => $this->whenCounted('members'),
        ];
    }
}
