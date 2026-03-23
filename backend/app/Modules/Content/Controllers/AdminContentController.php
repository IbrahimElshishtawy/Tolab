<?php

namespace App\Modules\Content\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Content\Models\Assessment;
use App\Modules\Content\Models\CourseFile;
use App\Modules\Content\Models\Exam;
use App\Modules\Content\Models\Lecture;
use App\Modules\Content\Models\SectionSession;
use App\Modules\Content\Models\Summary;
use App\Modules\Content\Requests\StoreAssessmentRequest;
use App\Modules\Content\Requests\StoreCourseFileRequest;
use App\Modules\Content\Requests\StoreExamRequest;
use App\Modules\Content\Requests\StoreLectureRequest;
use App\Modules\Content\Requests\StoreSectionSessionRequest;
use App\Modules\Content\Requests\StoreSummaryRequest;
use App\Modules\Content\Requests\UpdateAssessmentRequest;
use App\Modules\Content\Requests\UpdateExamRequest;
use App\Modules\Content\Requests\UpdateLectureRequest;
use App\Modules\Content\Requests\UpdateSectionSessionRequest;
use App\Modules\Content\Resources\AssessmentResource;
use App\Modules\Content\Resources\CourseFileResource;
use App\Modules\Content\Resources\ExamResource;
use App\Modules\Content\Resources\LectureResource;
use App\Modules\Content\Resources\SectionSessionResource;
use App\Modules\Content\Resources\SummaryResource;
use App\Modules\Content\Services\ContentService;

class AdminContentController extends ApiController
{
    public function __construct(protected ContentService $contentService)
    {
    }

    public function storeLecture(StoreLectureRequest $request, CourseOffering $courseOffering)
    {
        $this->contentService->assertManageAllowed($request->user());
        $lecture = $this->contentService->createLecture($courseOffering, $request->validated(), $request->user());

        return $this->success('Lecture created successfully.', LectureResource::make($lecture), 201);
    }

    public function updateLecture(UpdateLectureRequest $request, Lecture $lecture)
    {
        $this->contentService->assertManageAllowed($request->user());
        $lecture = $this->contentService->updateLecture($lecture, $request->validated(), $request->user());

        return $this->success('Lecture updated successfully.', LectureResource::make($lecture));
    }

    public function deleteLecture(Lecture $lecture)
    {
        $this->contentService->assertManageAllowed(request()->user());
        $this->contentService->deleteModel($lecture, request()->user(), 'content.lecture.delete');

        return $this->success('Lecture deleted successfully.');
    }

    public function storeSectionSession(StoreSectionSessionRequest $request, CourseOffering $courseOffering)
    {
        $this->contentService->assertManageAllowed($request->user());
        $session = $this->contentService->createSectionSession($courseOffering, $request->validated(), $request->user());

        return $this->success('Section session created successfully.', SectionSessionResource::make($session), 201);
    }

    public function updateSectionSession(UpdateSectionSessionRequest $request, SectionSession $sectionSession)
    {
        $this->contentService->assertManageAllowed($request->user());
        $session = $this->contentService->updateSectionSession($sectionSession, $request->validated(), $request->user());

        return $this->success('Section session updated successfully.', SectionSessionResource::make($session));
    }

    public function deleteSectionSession(SectionSession $sectionSession)
    {
        $this->contentService->assertManageAllowed(request()->user());
        $this->contentService->deleteModel($sectionSession, request()->user(), 'content.section-session.delete');

        return $this->success('Section session deleted successfully.');
    }

    public function storeSummary(StoreSummaryRequest $request, CourseOffering $courseOffering)
    {
        $this->contentService->assertManageAllowed($request->user());
        $summary = $this->contentService->createSummary($courseOffering, $request->validated(), $request->user());

        return $this->success('Summary created successfully.', SummaryResource::make($summary), 201);
    }

    public function deleteSummary(Summary $summary)
    {
        $this->contentService->assertManageAllowed(request()->user());
        $this->contentService->deleteModel($summary, request()->user(), 'content.summary.delete');

        return $this->success('Summary deleted successfully.');
    }

    public function storeAssessment(StoreAssessmentRequest $request, CourseOffering $courseOffering)
    {
        $this->contentService->assertManageAllowed($request->user());
        $assessment = $this->contentService->createAssessment($courseOffering, $request->validated(), $request->user());

        return $this->success('Assessment created successfully.', AssessmentResource::make($assessment), 201);
    }

    public function updateAssessment(UpdateAssessmentRequest $request, Assessment $assessment)
    {
        $this->contentService->assertManageAllowed($request->user());
        $assessment = $this->contentService->updateAssessment($assessment, $request->validated(), $request->user());

        return $this->success('Assessment updated successfully.', AssessmentResource::make($assessment));
    }

    public function deleteAssessment(Assessment $assessment)
    {
        $this->contentService->assertManageAllowed(request()->user());
        $this->contentService->deleteModel($assessment, request()->user(), 'content.assessment.delete');

        return $this->success('Assessment deleted successfully.');
    }

    public function storeExam(StoreExamRequest $request, CourseOffering $courseOffering)
    {
        $this->contentService->assertManageAllowed($request->user());
        $exam = $this->contentService->createExam($courseOffering, $request->validated(), $request->user());

        return $this->success('Exam created successfully.', ExamResource::make($exam), 201);
    }

    public function updateExam(UpdateExamRequest $request, Exam $exam)
    {
        $this->contentService->assertManageAllowed($request->user());
        $exam = $this->contentService->updateExam($exam, $request->validated(), $request->user());

        return $this->success('Exam updated successfully.', ExamResource::make($exam));
    }

    public function deleteExam(Exam $exam)
    {
        $this->contentService->assertManageAllowed(request()->user());
        $this->contentService->deleteModel($exam, request()->user(), 'content.exam.delete');

        return $this->success('Exam deleted successfully.');
    }

    public function storeCourseFile(StoreCourseFileRequest $request, CourseOffering $courseOffering)
    {
        $this->contentService->assertManageAllowed($request->user());
        $courseFile = $this->contentService->createCourseFile($courseOffering, $request->validated(), $request->user());

        return $this->success('Course file created successfully.', CourseFileResource::make($courseFile), 201);
    }

    public function deleteCourseFile(CourseFile $courseFile)
    {
        $this->contentService->assertManageAllowed(request()->user());
        $this->contentService->deleteModel($courseFile, request()->user(), 'content.file.delete');

        return $this->success('Course file deleted successfully.');
    }
}
