<?php

namespace App\Modules\Content\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UploadFileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'file' => ['required', 'file', 'max:10240', 'mimes:pdf,doc,docx,ppt,pptx,xls,xlsx,csv,jpg,jpeg,png,zip,rar'],
            'category' => ['nullable', 'string', 'max:80'],
        ];
    }
}
