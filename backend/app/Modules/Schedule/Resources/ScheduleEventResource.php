<?php

namespace App\Modules\Schedule\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ScheduleEventResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'course_offering_id' => $this->course_offering_id,
            'type' => $this->type->value,
            'day_of_week' => $this->day_of_week,
            'start_time' => $this->start_time,
            'end_time' => $this->end_time,
            'location' => $this->location,
            'week_pattern' => $this->week_pattern->value,
            'note' => $this->note,
        ];
    }
}
