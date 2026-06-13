<?php

namespace App\Modules\Content\Interface\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Infrastructure\CourseOffering;
use App\Modules\Content\Infrastructure\Assessment;
use App\Modules\Content\Infrastructure\CourseFile;
use App\Modules\Content\Infrastructure\Exam;
use App\Modules\Content\Infrastructure\Lecture;
use App\Modules\Content\Infrastructure\SectionSession;
use App\Modules\Content\Infrastructure\Summary;
use App\Modules\Content\Interface\Requests\StoreAssessmentRequest;
use App\Modules\Content\Interface\Requests\StoreCourseFileRequest;
use App\Modules\Content\Interface\Requests\StoreExamRequest;
use App\Modules\Content\Interface\Requests\StoreLectureRequest;
use App\Modules\Content\Interface\Requests\StoreSectionSessionRequest;
use App\Modules\Content\Interface\Requests\StoreSummaryRequest;
use App\Modules\Content\Interface\Requests\UpdateAssessmentRequest;
use App\Modules\Content\Interface\Requests\UpdateExamRequest;
use App\Modules\Content\Interface\Requests\UpdateLectureRequest;
use App\Modules\Content\Interface\Requests\UpdateSectionSessionRequest;
use App\Modules\Content\Interface\Resources\AssessmentResource;
use App\Modules\Content\Interface\Resources\CourseFileResource;
use App\Modules\Content\Interface\Resources\ExamResource;
use App\Modules\Content\Interface\Resources\LectureResource;
use App\Modules\Content\Interface\Resources\SectionSessionResource;
use App\Modules\Content\Interface\Resources\SummaryResource;
use App\Modules\Content\Application\ContentService;

class AdminContentController extends ApiController
{
    public function __construct(protected ContentService $contentService) {}

        /**
     * @OA\Post(
     *     path="/api/admin/courses/{courseOffering}/lectures",
     *     summary="storeLecture action in AdminContentController",
     *     tags={"Content"},
     *     @OA\Parameter(
     *         name="courseOffering",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The courseOffering parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"title"},
     *             @OA\Property(property="title", type="string", description="Rules: required, string, max:180"),
     *             @OA\Property(property="description", type="string", description="Rules: nullable, string"),
     *             @OA\Property(property="date", type="string", description="Rules: nullable, date"),
     *             @OA\Property(property="files", type="array", description="Rules: nullable, array"),
     *             @OA\Property(property="files.*", type="string", description="Rules: file, max:10240, mimes:pdf,doc,docx,ppt,pptx,jpg,jpeg,png,zip,rar")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function storeLecture(StoreLectureRequest $request, CourseOffering $courseOffering)
    {
        $this->contentService->assertManageAllowed($request->user());
        $lecture = $this->contentService->createLecture($courseOffering, $request->validated(), $request->user());

        return $this->success('Lecture created successfully.', LectureResource::make($lecture), 201);
    }

        /**
     * @OA\Put(
     *     path="/api/admin/lectures/{lecture}",
     *     summary="updateLecture action in AdminContentController",
     *     tags={"Content"},
     *     @OA\Parameter(
     *         name="lecture",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The lecture parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="title", type="string", description="Rules: sometimes, string, max:180"),
     *             @OA\Property(property="description", type="string", description="Rules: nullable, string"),
     *             @OA\Property(property="date", type="string", description="Rules: nullable, date"),
     *             @OA\Property(property="files", type="array", description="Rules: nullable, array"),
     *             @OA\Property(property="files.*", type="string", description="Rules: file, max:10240, mimes:pdf,doc,docx,ppt,pptx,jpg,jpeg,png,zip,rar")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
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

        /**
     * @OA\Post(
     *     path="/api/admin/courses/{courseOffering}/sections",
     *     summary="storeSectionSession action in AdminContentController",
     *     tags={"Content"},
     *     @OA\Parameter(
     *         name="courseOffering",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The courseOffering parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"title"},
     *             @OA\Property(property="title", type="string", description="Rules: required, string, max:180"),
     *             @OA\Property(property="date", type="string", description="Rules: nullable, date"),
     *             @OA\Property(property="files", type="array", description="Rules: nullable, array"),
     *             @OA\Property(property="files.*", type="string", description="Rules: file, max:10240, mimes:pdf,doc,docx,ppt,pptx,jpg,jpeg,png,zip,rar")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function storeSectionSession(StoreSectionSessionRequest $request, CourseOffering $courseOffering)
    {
        $this->contentService->assertManageAllowed($request->user());
        $session = $this->contentService->createSectionSession($courseOffering, $request->validated(), $request->user());

        return $this->success('Section session created successfully.', SectionSessionResource::make($session), 201);
    }

        /**
     * @OA\Put(
     *     path="/api/admin/sections-sessions/{sectionSession}",
     *     summary="updateSectionSession action in AdminContentController",
     *     tags={"Content"},
     *     @OA\Parameter(
     *         name="sectionSession",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The sectionSession parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="title", type="string", description="Rules: sometimes, string, max:180"),
     *             @OA\Property(property="date", type="string", description="Rules: nullable, date"),
     *             @OA\Property(property="files", type="array", description="Rules: nullable, array"),
     *             @OA\Property(property="files.*", type="string", description="Rules: file, max:10240, mimes:pdf,doc,docx,ppt,pptx,jpg,jpeg,png,zip,rar")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
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

        /**
     * @OA\Post(
     *     path="/api/admin/courses/{courseOffering}/summaries",
     *     summary="storeSummary action in AdminContentController",
     *     tags={"Content"},
     *     @OA\Parameter(
     *         name="courseOffering",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The courseOffering parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"title", "file"},
     *             @OA\Property(property="title", type="string", description="Rules: required, string, max:180"),
     *             @OA\Property(property="file", type="string", description="Rules: required, file, max:10240, mimes:pdf,doc,docx,ppt,pptx")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function storeSummary(StoreSummaryRequest $request, CourseOffering $courseOffering)
    {
        $this->contentService->assertManageAllowed($request->user());
        $summary = $this->contentService->createSummary($courseOffering, $request->validated(), $request->user());

        return $this->success('Summary created successfully.', SummaryResource::make($summary), 201);
    }

        /**
     * @OA\Delete(
     *     path="/api/admin/summaries/{summary}",
     *     summary="deleteSummary action in AdminContentController",
     *     tags={"Content"},
     *     @OA\Parameter(
     *         name="summary",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The summary parameter"
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function deleteSummary(Summary $summary)
    {
        $this->contentService->assertManageAllowed(request()->user());
        $this->contentService->deleteModel($summary, request()->user(), 'content.summary.delete');

        return $this->success('Summary deleted successfully.');
    }

        /**
     * @OA\Post(
     *     path="/api/admin/courses/{courseOffering}/assessments",
     *     summary="storeAssessment action in AdminContentController",
     *     tags={"Content"},
     *     @OA\Parameter(
     *         name="courseOffering",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The courseOffering parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"type", "title"},
     *             @OA\Property(property="type", type="string", description="Rules: required, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="title", type="string", description="Rules: required, string, max:180"),
     *             @OA\Property(property="description", type="string", description="Rules: nullable, string"),
     *             @OA\Property(property="due_at", type="string", description="Rules: nullable, date"),
     *             @OA\Property(property="files", type="array", description="Rules: nullable, array"),
     *             @OA\Property(property="files.*", type="string", description="Rules: file, max:10240, mimes:pdf,doc,docx,xls,xlsx,csv,jpg,jpeg,png,zip,rar")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function storeAssessment(StoreAssessmentRequest $request, CourseOffering $courseOffering)
    {
        $this->contentService->assertManageAllowed($request->user());
        $assessment = $this->contentService->createAssessment($courseOffering, $request->validated(), $request->user());

        return $this->success('Assessment created successfully.', AssessmentResource::make($assessment), 201);
    }

        /**
     * @OA\Put(
     *     path="/api/admin/assessments/{assessment}",
     *     summary="updateAssessment action in AdminContentController",
     *     tags={"Content"},
     *     @OA\Parameter(
     *         name="assessment",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The assessment parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="type", type="string", description="Rules: sometimes, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="title", type="string", description="Rules: sometimes, string, max:180"),
     *             @OA\Property(property="description", type="string", description="Rules: nullable, string"),
     *             @OA\Property(property="due_at", type="string", description="Rules: nullable, date"),
     *             @OA\Property(property="files", type="array", description="Rules: nullable, array"),
     *             @OA\Property(property="files.*", type="string", description="Rules: file, max:10240, mimes:pdf,doc,docx,xls,xlsx,csv,jpg,jpeg,png,zip,rar")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
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

        /**
     * @OA\Post(
     *     path="/api/admin/courses/{courseOffering}/exams",
     *     summary="storeExam action in AdminContentController",
     *     tags={"Content"},
     *     @OA\Parameter(
     *         name="courseOffering",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The courseOffering parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"title", "exam_at"},
     *             @OA\Property(property="title", type="string", description="Rules: required, string, max:180"),
     *             @OA\Property(property="exam_at", type="string", description="Rules: required, date"),
     *             @OA\Property(property="files", type="array", description="Rules: nullable, array"),
     *             @OA\Property(property="files.*", type="string", description="Rules: file, max:10240, mimes:pdf,doc,docx,jpg,jpeg,png,zip,rar")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function storeExam(StoreExamRequest $request, CourseOffering $courseOffering)
    {
        $this->contentService->assertManageAllowed($request->user());
        $exam = $this->contentService->createExam($courseOffering, $request->validated(), $request->user());

        return $this->success('Exam created successfully.', ExamResource::make($exam), 201);
    }

        /**
     * @OA\Put(
     *     path="/api/admin/exams/{exam}",
     *     summary="updateExam action in AdminContentController",
     *     tags={"Content"},
     *     @OA\Parameter(
     *         name="exam",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The exam parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="title", type="string", description="Rules: sometimes, string, max:180"),
     *             @OA\Property(property="exam_at", type="string", description="Rules: sometimes, date"),
     *             @OA\Property(property="files", type="array", description="Rules: nullable, array"),
     *             @OA\Property(property="files.*", type="string", description="Rules: file, max:10240, mimes:pdf,doc,docx,jpg,jpeg,png,zip,rar")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
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

        /**
     * @OA\Post(
     *     path="/api/admin/courses/{courseOffering}/files",
     *     summary="storeCourseFile action in AdminContentController",
     *     tags={"Content"},
     *     @OA\Parameter(
     *         name="courseOffering",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The courseOffering parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"title", "file"},
     *             @OA\Property(property="title", type="string", description="Rules: required, string, max:180"),
     *             @OA\Property(property="category", type="string", description="Rules: nullable, string, max:80"),
     *             @OA\Property(property="file", type="string", description="Rules: required, file, max:10240, mimes:pdf,doc,docx,ppt,pptx,xls,xlsx,csv,jpg,jpeg,png,zip,rar")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function storeCourseFile(StoreCourseFileRequest $request, CourseOffering $courseOffering)
    {
        $this->contentService->assertManageAllowed($request->user());
        $courseFile = $this->contentService->createCourseFile($courseOffering, $request->validated(), $request->user());

        return $this->success('Course file created successfully.', CourseFileResource::make($courseFile), 201);
    }

        /**
     * @OA\Delete(
     *     path="/api/admin/course-files/{courseFile}",
     *     summary="deleteCourseFile action in AdminContentController",
     *     tags={"Content"},
     *     @OA\Parameter(
     *         name="courseFile",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The courseFile parameter"
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function deleteCourseFile(CourseFile $courseFile)
    {
        $this->contentService->assertManageAllowed(request()->user());
        $this->contentService->deleteModel($courseFile, request()->user(), 'content.file.delete');

        return $this->success('Course file deleted successfully.');
    }
}
