<?php

namespace App\Modules\StaffPortal\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreLecturePortalRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'subject_id' => ['nullable', 'integer', 'exists:subjects,id'],
            'title' => ['required', 'string', 'max:180'],
            'description' => ['nullable', 'string', 'max:5000'],
            'instructor_name' => ['nullable', 'string', 'max:180'],
            'week_number' => ['nullable', 'integer', 'between:1,20'],
            'video_url' => ['nullable', 'url'],
            'meeting_url' => ['nullable', 'url'],
            'delivery_mode' => ['nullable', 'string', 'max:20'],
            'location_label' => ['nullable', 'string', 'max:180'],
            'attachment_label' => ['nullable', 'string', 'max:180'],
            'publish_date' => ['nullable', 'date'],
            'publish_time' => ['nullable', 'date_format:H:i'],
            'publish_now' => ['nullable', 'boolean'],
            'save_as_draft' => ['nullable', 'boolean'],
        ];
    }
}
