<?php

namespace App\Modules\Academic\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SectionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'grade_year' => $this->grade_year,
            'department_id' => $this->department_id,
        ];
    }
}
