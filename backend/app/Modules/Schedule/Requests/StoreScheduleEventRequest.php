<?php

namespace App\Modules\Schedule\Requests;

use App\Core\Enums\WeekPattern;
use App\Modules\Schedule\Enums\ScheduleEventType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreScheduleEventRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'type' => ['required', Rule::enum(ScheduleEventType::class)],
            'day_of_week' => ['required', 'integer', 'between:0,6'],
            'start_time' => ['required', 'date_format:H:i'],
            'end_time' => ['required', 'date_format:H:i', 'after:start_time'],
            'location' => ['nullable', 'string', 'max:180'],
            'week_pattern' => ['required', Rule::enum(WeekPattern::class)],
            'note' => ['nullable', 'string'],
        ];
    }
}
