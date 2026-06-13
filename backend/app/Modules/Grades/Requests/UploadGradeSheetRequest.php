<?php

namespace App\Modules\Grades\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UploadGradeSheetRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category_key' => ['required', 'string', 'max:50'],
            'file' => ['required', 'file', 'mimes:pdf,csv,xls,xlsx', 'max:10240'], // 10MB limit
        ];
    }
}
