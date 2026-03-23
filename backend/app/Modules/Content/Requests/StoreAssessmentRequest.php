<?php

namespace App\Modules\Content\Requests;

use App\Modules\Content\Enums\AssessmentType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreAssessmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'type' => ['required', Rule::enum(AssessmentType::class)],
            'title' => ['required', 'string', 'max:180'],
            'description' => ['nullable', 'string'],
            'due_at' => ['nullable', 'date'],
            'files' => ['nullable', 'array'],
            'files.*' => ['file', 'max:10240', 'mimes:pdf,doc,docx,xls,xlsx,csv,jpg,jpeg,png,zip,rar'],
        ];
    }
}
