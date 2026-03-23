<?php

namespace App\Modules\Content\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateExamRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['sometimes', 'string', 'max:180'],
            'exam_at' => ['sometimes', 'date'],
            'files' => ['nullable', 'array'],
            'files.*' => ['file', 'max:10240', 'mimes:pdf,doc,docx,jpg,jpeg,png,zip,rar'],
        ];
    }
}
