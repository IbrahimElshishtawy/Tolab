<?php

namespace App\Modules\Content\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CourseContentBundleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'lectures' => LectureResource::collection($this->lectures),
            'sections' => SectionSessionResource::collection($this->sectionSessions),
            'summaries' => SummaryResource::collection($this->summaries),
            'assessments' => AssessmentResource::collection($this->assessments),
            'exams' => ExamResource::collection($this->exams),
            'files' => CourseFileResource::collection($this->files),
        ];
    }
}
