<?php

namespace App\Modules\Content\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreLectureRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:180'],
            'description' => ['nullable', 'string'],
            'date' => ['nullable', 'date'],
            'files' => ['nullable', 'array'],
            'files.*' => ['file', 'max:10240', 'mimes:pdf,doc,docx,ppt,pptx,jpg,jpeg,png,zip,rar'],
        ];
    }
}
