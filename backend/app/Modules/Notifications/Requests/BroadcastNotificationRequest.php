<?php

namespace App\Modules\Notifications\Requests;

use App\Core\Enums\NotificationType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class BroadcastNotificationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:180'],
            'body' => ['required', 'string', 'max:5000'],
            'type' => ['nullable', Rule::enum(NotificationType::class)],
            'ref_type' => ['nullable', 'string', 'max:80'],
            'ref_id' => ['nullable', 'integer'],
        ];
    }
}
