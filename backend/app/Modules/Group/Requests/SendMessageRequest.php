<?php

namespace App\Modules\Group\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SendMessageRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'text' => ['required', 'string', 'max:5000'],
        ];
    }

    public function messages(): array
    {
        return [
            'text.required' => 'Message text is required.',
            'text.max' => 'Message text must not exceed 5000 characters.',
        ];
    }
}
