<?php

namespace App\Modules\Academic\Repositories;

use App\Core\Base\BaseRepository;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Builder;

class CourseOfferingRepository extends BaseRepository
{
    public function __construct(CourseOffering $model)
    {
        parent::__construct($model);
    }

    public function adminListing(array $filters): Builder
    {
        return $this->query()
            ->with(['subject.department', 'section.department', 'doctor', 'ta', 'group'])
            ->when($filters['section_id'] ?? null, fn (Builder $query, $sectionId) => $query->where('section_id', $sectionId))
            ->when($filters['subject_id'] ?? null, fn (Builder $query, $subjectId) => $query->where('subject_id', $subjectId))
            ->when($filters['year'] ?? null, fn (Builder $query, $year) => $query->where('academic_year', $year))
            ->when($filters['semester'] ?? null, fn (Builder $query, $semester) => $query->where('semester', $semester));
    }

    public function forStudent(User $student): Builder
    {
        return $this->query()
            ->with(['subject.department', 'section.department', 'doctor', 'ta', 'group'])
            ->forStudent($student)
            ->latest('id');
    }
}
