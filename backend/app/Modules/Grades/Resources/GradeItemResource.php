<?php

namespace App\Modules\Grades\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GradeItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $courseOfferingId = null;
        if ($this->gradeCategory && $this->student) {
            $enrollment = \App\Modules\Enrollment\Models\Enrollment::where('student_user_id', $this->student->user_id)
                ->whereHas('courseOffering', fn($q) => $q->where('subject_id', $this->gradeCategory->subject_id))
                ->first();
            $courseOfferingId = $enrollment?->course_offering_id;
        }

        $studentUserId = $this->student?->user_id;
        $type = $this->gradeCategory?->key_name;
        $maxScore = $this->gradeCategory?->max_score;

        return [
            'id' => $this->id,
            'course_offering_id' => $courseOfferingId,
            'student_user_id' => $studentUserId,
            'type' => $type,
            'score' => $this->score,
            'max_score' => $maxScore,
            'note' => $this->note,
            'updated_by' => $this->relationLoaded('grader') ? ($this->grader ? [
                'id' => $this->grader->id,
                'username' => $this->grader->username,
                'full_name' => $this->grader->full_name,
            ] : null) : $this->graded_by,
            'updated_at' => $this->updated_at,
        ];
    }
}
