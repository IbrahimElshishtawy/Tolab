<?php

namespace App\Modules\Schedule\Requests;

use App\Core\Enums\WeekPattern;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class TimetableFilterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'week' => ['nullable', Rule::enum(WeekPattern::class)],
        ];
    }
}
