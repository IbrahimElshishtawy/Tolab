<?php

namespace App\Modules\Schedule\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Str;

class ScheduleEventResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $courseOffering = $this->courseOffering;
        $subject = $courseOffering?->subject;
        $section = $courseOffering?->section;
        $doctor = $courseOffering?->doctor;
        $ta = $courseOffering?->ta;
        $departmentName = $subject?->department?->name
            ?? $section?->department?->name
            ?? 'Department';
        $instructor = $doctor?->username ?? $ta?->username ?? 'Instructor';
        $assignedStaffIds = array_values(array_filter([
            $doctor?->id,
            $ta?->id,
        ]));

        return [
            'id' => $this->id,
            'course_offering_id' => $this->course_offering_id,
            'title' => trim(Str::headline($this->type->value).' '.($subject?->name ?? 'Session')),
            'subject' => $subject?->name ?? 'Subject',
            'subject_id' => $subject?->id,
            'section' => $section?->name ?? 'Section',
            'section_id' => $section?->id,
            'instructor' => $instructor,
            'instructor_name' => $instructor,
            'instructor_id' => $doctor?->id ?? $ta?->id,
            'department' => $departmentName,
            'department_name' => $departmentName,
            'academic_year' => $courseOffering?->academic_year,
            'year_label' => $courseOffering?->academic_year,
            'student_scope_label' => $section?->name ? $section->name.' cohort' : null,
            'assigned_staff_ids' => $assignedStaffIds,
            'group_id' => $courseOffering?->group_id,
            'status' => $this->resolveComputedStatus(),
            'type' => $this->type->value,
            'day_of_week' => $this->day_of_week,
            'start_at' => $this->resolveStartAt()->toIso8601String(),
            'end_at' => $this->resolveEndAt()->toIso8601String(),
            'start_time' => $this->start_time,
            'end_time' => $this->end_time,
            'location' => $this->location,
            'week_pattern' => $this->week_pattern->value,
            'note' => $this->note,
            'is_synced' => true,
        ];
    }
}
