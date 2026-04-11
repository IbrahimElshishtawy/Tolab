<?php

namespace App\Modules\Group\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CreateCommentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'text' => ['required', 'string', 'max:3000'],
        ];
    }

    public function messages(): array
    {
        return [
            'text.required' => 'Comment text is required.',
            'text.max' => 'Comment text must not exceed 3000 characters.',
        ];
    }
}
