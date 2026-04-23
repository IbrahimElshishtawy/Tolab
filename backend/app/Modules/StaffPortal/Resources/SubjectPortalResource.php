<?php

namespace App\Modules\StaffPortal\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SubjectPortalResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $firstOffering = $this->courseOfferings->first();

        return [
            'id' => $this->id,
            'name' => $this->name,
            'code' => $this->code,
            'description' => $this->description,
            'department_name' => $this->department?->name,
            'academic_year_name' => $this->academicYear?->name ?? (string) $this->grade_year,
            'is_active' => $this->is_active,
            'doctor_name' => $firstOffering?->doctor?->full_name ?: $firstOffering?->doctor?->username,
            'assistant_name' => $firstOffering?->ta?->full_name ?: $firstOffering?->ta?->username,
            'student_count' => $this->courseOfferings->sum(fn ($offering) => $offering->activeEnrollments()->count()),
            'lectures_count' => $this->courseOfferings->sum(fn ($offering) => $offering->lectures()->count()),
            'sections_count' => $this->sections->count(),
            'quizzes_count' => \App\Modules\StaffPortal\Models\Quiz::query()->where('subject_id', $this->id)->count(),
            'tasks_count' => \App\Modules\StaffPortal\Models\Task::query()->where('subject_id', $this->id)->count(),
            'progress' => 0.72,
            'last_activity_label' => 'Subject workspace synced',
            'status_label' => 'Healthy',
            'average_score' => 0,
            'pending_grades_count' => 0,
            'published_results_count' => 0,
            'group_posts_count' => 0,
            'sections' => $this->whenLoaded('sections', fn () => $this->sections->map(fn ($section) => [
                'id' => $section->id,
                'name' => $section->name,
                'code' => $section->code,
                'assistant_name' => $section->assistant?->full_name ?: $section->assistant?->username,
                'is_active' => $section->is_active,
            ])->values()),
        ];
    }
}
