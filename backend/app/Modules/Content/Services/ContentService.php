<?php

namespace App\Modules\Content\Services;

use App\Core\Exceptions\ApiException;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Content\Models\Assessment;
use App\Modules\Content\Models\CourseFile;
use App\Modules\Content\Models\Exam;
use App\Modules\Content\Models\Lecture;
use App\Modules\Content\Models\SectionSession;
use App\Modules\Content\Models\Summary;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

class ContentService
{
    public function __construct(
        protected FileUploadService $fileUploadService,
        protected AuditLogService $auditLogService,
    ) {}

    public function bundle(CourseOffering $courseOffering): CourseOffering
    {
        return $courseOffering->load([
            'lectures.attachments',
            'sectionSessions.attachments',
            'summaries',
            'assessments.attachments',
            'exams.attachments',
            'files',
        ]);
    }

    public function createLecture(CourseOffering $offering, array $payload, User $actor): Lecture
    {
        return DB::transaction(function () use ($offering, $payload, $actor) {
            $lecture = $offering->lectures()->create(collect($payload)->except('files')->toArray());
            $this->storeAttachments($lecture, $payload['files'] ?? [], $actor, 'lectures');
            $this->auditLogService->log($actor, 'content.lecture.create', $lecture, ['course_offering_id' => $offering->id], request());

            return $lecture->load('attachments');
        });
    }

    public function updateLecture(Lecture $lecture, array $payload, User $actor): Lecture
    {
        return DB::transaction(function () use ($lecture, $payload, $actor) {
            $lecture->update(collect($payload)->except('files')->toArray());
            $this->storeAttachments($lecture, $payload['files'] ?? [], $actor, 'lectures');
            $this->auditLogService->log($actor, 'content.lecture.update', $lecture, [], request());

            return $lecture->load('attachments');
        });
    }

    public function deleteModel(Model $model, User $actor, string $action): void
    {
        $this->auditLogService->log($actor, $action, $model, [], request());
        $model->delete();
    }

    public function createSectionSession(CourseOffering $offering, array $payload, User $actor): SectionSession
    {
        return DB::transaction(function () use ($offering, $payload, $actor) {
            $session = $offering->sectionSessions()->create(collect($payload)->except('files')->toArray());
            $this->storeAttachments($session, $payload['files'] ?? [], $actor, 'section-sessions');
            $this->auditLogService->log($actor, 'content.section-session.create', $session, [], request());

            return $session->load('attachments');
        });
    }

    public function updateSectionSession(SectionSession $session, array $payload, User $actor): SectionSession
    {
        return DB::transaction(function () use ($session, $payload, $actor) {
            $session->update(collect($payload)->except('files')->toArray());
            $this->storeAttachments($session, $payload['files'] ?? [], $actor, 'section-sessions');
            $this->auditLogService->log($actor, 'content.section-session.update', $session, [], request());

            return $session->load('attachments');
        });
    }

    public function createSummary(CourseOffering $offering, array $payload, User $actor): Summary
    {
        $file = $this->fileUploadService->store($payload['file'], $actor, 'summaries');

        return DB::transaction(function () use ($offering, $payload, $actor, $file) {
            $summary = $offering->summaries()->create([
                'title' => $payload['title'],
                'file_url' => $file['file_url'],
                'created_by' => $actor->id,
            ]);

            $this->auditLogService->log($actor, 'content.summary.create', $summary, [], request());

            return $summary;
        });
    }

    public function createAssessment(CourseOffering $offering, array $payload, User $actor): Assessment
    {
        return DB::transaction(function () use ($offering, $payload, $actor) {
            $assessment = $offering->assessments()->create([
                'type' => $payload['type'],
                'title' => $payload['title'],
                'description' => $payload['description'] ?? null,
                'due_at' => $payload['due_at'] ?? null,
                'created_by' => $actor->id,
            ]);

            $this->storeAttachments($assessment, $payload['files'] ?? [], $actor, 'assessments');
            $this->auditLogService->log($actor, 'content.assessment.create', $assessment, [], request());

            return $assessment->load('attachments');
        });
    }

    public function updateAssessment(Assessment $assessment, array $payload, User $actor): Assessment
    {
        return DB::transaction(function () use ($assessment, $payload, $actor) {
            $assessment->update(collect($payload)->except('files')->toArray());
            $this->storeAttachments($assessment, $payload['files'] ?? [], $actor, 'assessments');
            $this->auditLogService->log($actor, 'content.assessment.update', $assessment, [], request());

            return $assessment->load('attachments');
        });
    }

    public function createExam(CourseOffering $offering, array $payload, User $actor): Exam
    {
        return DB::transaction(function () use ($offering, $payload, $actor) {
            $exam = $offering->exams()->create([
                'title' => $payload['title'],
                'exam_at' => $payload['exam_at'],
                'created_by' => $actor->id,
            ]);

            $this->storeAttachments($exam, $payload['files'] ?? [], $actor, 'exams');
            $this->auditLogService->log($actor, 'content.exam.create', $exam, [], request());

            return $exam->load('attachments');
        });
    }

    public function updateExam(Exam $exam, array $payload, User $actor): Exam
    {
        return DB::transaction(function () use ($exam, $payload, $actor) {
            $exam->update(collect($payload)->except('files')->toArray());
            $this->storeAttachments($exam, $payload['files'] ?? [], $actor, 'exams');
            $this->auditLogService->log($actor, 'content.exam.update', $exam, [], request());

            return $exam->load('attachments');
        });
    }

    public function createCourseFile(CourseOffering $offering, array $payload, User $actor): CourseFile
    {
        $file = $this->fileUploadService->store($payload['file'], $actor, 'course-files');

        return DB::transaction(function () use ($offering, $payload, $file, $actor) {
            $courseFile = $offering->files()->create([
                'title' => $payload['title'],
                'file_url' => $file['file_url'],
                'category' => $payload['category'] ?? null,
            ]);

            $this->auditLogService->log($actor, 'content.file.create', $courseFile, [], request());

            return $courseFile;
        });
    }

    protected function storeAttachments(Model $model, array $files, User $actor, string $directory): void
    {
        foreach ($files as $file) {
            $stored = $this->fileUploadService->store($file, $actor, $directory);
            $model->attachments()->create($stored);
        }
    }

    public function assertManageAllowed(User $user): void
    {
        if (! $user->canManageContent()) {
            throw new ApiException('You are not allowed to manage course content.', [], Response::HTTP_FORBIDDEN);
        }
    }
}
