<?php

namespace App\Modules\Schedule\Requests;

use App\Core\Enums\WeekPattern;
use App\Modules\Schedule\Enums\ScheduleEventType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateScheduleEventRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'type' => ['sometimes', Rule::enum(ScheduleEventType::class)],
            'day_of_week' => ['sometimes', 'integer', 'between:0,6'],
            'start_time' => ['sometimes', 'date_format:H:i'],
            'end_time' => ['sometimes', 'date_format:H:i'],
            'location' => ['nullable', 'string', 'max:180'],
            'week_pattern' => ['sometimes', Rule::enum(WeekPattern::class)],
            'note' => ['nullable', 'string'],
        ];
    }
}
