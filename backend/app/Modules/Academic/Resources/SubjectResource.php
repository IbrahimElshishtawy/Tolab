<?php

namespace App\Modules\Academic\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SubjectResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'code' => $this->code,
            'department_id' => $this->department_id,
            'grade_year' => $this->grade_year,
            'semester' => $this->semester->value,
            'is_active' => $this->is_active,
        ];
    }
}
