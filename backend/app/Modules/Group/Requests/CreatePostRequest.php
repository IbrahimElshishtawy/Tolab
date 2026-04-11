<?php

namespace App\Modules\Group\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CreatePostRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        if ($this->filled('content') && ! $this->filled('content_text')) {
            $this->merge([
                'content_text' => $this->input('content'),
            ]);
        }
    }

    public function rules(): array
    {
        return [
            'content' => ['sometimes', 'string', 'max:5000'],
            'content_text' => ['required', 'string', 'max:5000'],
        ];
    }

    public function messages(): array
    {
        return [
            'content_text.required' => 'Post content is required.',
            'content_text.max' => 'Post content must not exceed 5000 characters.',
        ];
    }
}
