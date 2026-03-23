<?php

namespace App\Modules\Schedule\Requests;

use App\Core\Enums\WeekPattern;
use App\Modules\Schedule\Enums\ScheduleEventType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class BulkScheduleEventRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'events' => ['required', 'array', 'min:1'],
            'events.*.course_offering_id' => ['required', 'integer', 'exists:course_offerings,id'],
            'events.*.type' => ['required', Rule::enum(ScheduleEventType::class)],
            'events.*.day_of_week' => ['required', 'integer', 'between:0,6'],
            'events.*.start_time' => ['required', 'date_format:H:i'],
            'events.*.end_time' => ['required', 'date_format:H:i'],
            'events.*.location' => ['nullable', 'string', 'max:180'],
            'events.*.week_pattern' => ['required', Rule::enum(WeekPattern::class)],
            'events.*.note' => ['nullable', 'string'],
        ];
    }
}
