<?php

namespace App\Modules\Content\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreCourseFileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:180'],
            'category' => ['nullable', 'string', 'max:80'],
            'file' => ['required', 'file', 'max:10240', 'mimes:pdf,doc,docx,ppt,pptx,xls,xlsx,csv,jpg,jpeg,png,zip,rar'],
        ];
    }
}
