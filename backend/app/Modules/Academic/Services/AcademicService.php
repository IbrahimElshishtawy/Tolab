<?php

namespace App\Modules\Academic\Services;

use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Models\Section;
use App\Modules\Academic\Models\Subject;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\UserManagement\Models\User;

class AcademicService
{
    public function __construct(protected AuditLogService $auditLogService)
    {
    }

    public function createDepartment(array $payload, User $actor): Department
    {
        $department = Department::query()->create($payload);
        $this->auditLogService->log($actor, 'academic.department.create', $department, [], request());

        return $department;
    }

    public function createSection(array $payload, User $actor): Section
    {
        $section = Section::query()->create($payload);
        $this->auditLogService->log($actor, 'academic.section.create', $section, [], request());

        return $section;
    }

    public function createSubject(array $payload, User $actor): Subject
    {
        $subject = Subject::query()->create($payload);
        $this->auditLogService->log($actor, 'academic.subject.create', $subject, [], request());

        return $subject;
    }

    public function updateSubject(Subject $subject, array $payload, User $actor): Subject
    {
        $subject->update($payload);
        $this->auditLogService->log($actor, 'academic.subject.update', $subject, [], request());

        return $subject->refresh();
    }
}
