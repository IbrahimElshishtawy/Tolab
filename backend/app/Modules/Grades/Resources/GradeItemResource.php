<?php

namespace App\Modules\Grades\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GradeItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'course_offering_id' => $this->course_offering_id,
            'student_user_id' => $this->student_user_id,
            'type' => $this->type->value,
            'score' => $this->score,
            'max_score' => $this->max_score,
            'note' => $this->note,
            'updated_by' => $this->whenLoaded('updater', fn () => $this->updater ? [
                'id' => $this->updater->id,
                'username' => $this->updater->username,
                'full_name' => $this->updater->full_name,
            ] : null, $this->updated_by),
            'updated_at' => $this->updated_at,
        ];
    }
}
