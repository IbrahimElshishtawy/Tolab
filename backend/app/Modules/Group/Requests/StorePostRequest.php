<?php

namespace App\Modules\Group\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StorePostRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'content_text' => ['required', 'string', 'max:5000'],
        ];
    }
}
