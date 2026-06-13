<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Content\Infrastructure\Lecture;
use App\Modules\StaffPortal\Requests\StoreLecturePortalRequest;
use App\Modules\StaffPortal\Resources\LecturePortalResource;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class LectureController extends ApiController
{
    public function __construct(protected PortalService $service) {}

        /**
     * @OA\Get(
     *     path="/api/staff-portal/lectures",
     *     summary="index action in LectureController",
     *     tags={"StaffPortal"},
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
    public function index(Request $request)
    {
        return $this->success('Lectures retrieved successfully.', LecturePortalResource::collection($this->service->lectures($request->user())));
    }

    public function store(StoreLecturePortalRequest $request)
    {
        return $this->success('Lecture created successfully.', LecturePortalResource::make($this->service->createLecture($request->user(), $request->validated())), 201);
    }

        /**
     * @OA\Delete(
     *     path="/api/staff-portal/lectures/{lecture}",
     *     summary="destroy action in LectureController",
     *     tags={"StaffPortal"},
     *     @OA\Parameter(
     *         name="lecture",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The lecture parameter"
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
    public function destroy(Request $request, Lecture $lecture)
    {
        $this->service->deleteLecture($request->user(), $lecture);

        return $this->success('Lecture deleted successfully.');
    }

        /**
     * @OA\Patch(
     *     path="/api/staff-portal/lectures/{lecture}/publish",
     *     summary="publish action in LectureController",
     *     tags={"StaffPortal"},
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
     *             required={"title"},
     *             @OA\Property(property="subject_id", type="integer", description="Rules: nullable, integer, exists:subjects,id"),
     *             @OA\Property(property="title", type="string", description="Rules: required, string, max:180"),
     *             @OA\Property(property="description", type="string", description="Rules: nullable, string, max:5000"),
     *             @OA\Property(property="instructor_name", type="string", description="Rules: nullable, string, max:180"),
     *             @OA\Property(property="week_number", type="integer", description="Rules: nullable, integer, between:1,20"),
     *             @OA\Property(property="video_url", type="string", description="Rules: nullable, url"),
     *             @OA\Property(property="meeting_url", type="string", description="Rules: nullable, url"),
     *             @OA\Property(property="delivery_mode", type="string", description="Rules: nullable, string, max:20"),
     *             @OA\Property(property="location_label", type="string", description="Rules: nullable, string, max:180"),
     *             @OA\Property(property="attachment_label", type="string", description="Rules: nullable, string, max:180"),
     *             @OA\Property(property="publish_date", type="string", description="Rules: nullable, date"),
     *             @OA\Property(property="publish_time", type="string", description="Rules: nullable, date_format:H:i"),
     *             @OA\Property(property="publish_now", type="boolean", description="Rules: nullable, boolean"),
     *             @OA\Property(property="save_as_draft", type="boolean", description="Rules: nullable, boolean")
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
    public function publish(Request $request, Lecture $lecture)
    {
        return $this->success('Lecture published successfully.', LecturePortalResource::make($this->service->publishLecture($request->user(), $lecture)));
    }
}
