<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Infrastructure\Subject;
use App\Modules\Group\Models\Post;
use App\Modules\StaffPortal\Requests\StoreSubjectGroupPostRequest;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class SubjectGroupController extends ApiController
{
    public function __construct(protected PortalService $service) {}

        /**
     * @OA\Get(
     *     path="/api/staff-portal/subjects/{subject}/group",
     *     summary="show action in SubjectGroupController",
     *     tags={"StaffPortal"},
     *     @OA\Parameter(
     *         name="subject",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The subject parameter"
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
    public function show(Request $request, Subject $subject)
    {
        return $this->success('Subject group feed retrieved successfully.', $this->service->subjectGroup($request->user(), $subject));
    }

        /**
     * @OA\Post(
     *     path="/api/staff-portal/subjects/{subject}/posts",
     *     summary="store action in SubjectGroupController",
     *     tags={"StaffPortal"},
     *     @OA\Parameter(
     *         name="subject",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The subject parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"title", "content"},
     *             @OA\Property(property="title", type="string", description="Rules: required, string, max:180"),
     *             @OA\Property(property="content", type="string", description="Rules: required, string, max:5000"),
     *             @OA\Property(property="post_type", type="string", description="Rules: nullable, string, max:30"),
     *             @OA\Property(property="priority", type="string", description="Rules: nullable, string, max:20"),
     *             @OA\Property(property="is_pinned", type="boolean", description="Rules: nullable, boolean"),
     *             @OA\Property(property="attachment_label", type="string", description="Rules: nullable, string, max:180"),
     *             @OA\Property(property="attachment_url", type="string", description="Rules: nullable, url, max:255")
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
    public function store(StoreSubjectGroupPostRequest $request, Subject $subject)
    {
        return $this->success('Group post created successfully.', $this->service->saveSubjectPost($request->user(), $subject, $request->validated()), 201);
    }

        /**
     * @OA\Put(
     *     path="/api/staff-portal/posts/{post}",
     *     summary="update action in SubjectGroupController",
     *     tags={"StaffPortal"},
     *     @OA\Parameter(
     *         name="post",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The post parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"title", "content"},
     *             @OA\Property(property="title", type="string", description="Rules: required, string, max:180"),
     *             @OA\Property(property="content", type="string", description="Rules: required, string, max:5000"),
     *             @OA\Property(property="post_type", type="string", description="Rules: nullable, string, max:30"),
     *             @OA\Property(property="priority", type="string", description="Rules: nullable, string, max:20"),
     *             @OA\Property(property="is_pinned", type="boolean", description="Rules: nullable, boolean"),
     *             @OA\Property(property="attachment_label", type="string", description="Rules: nullable, string, max:180"),
     *             @OA\Property(property="attachment_url", type="string", description="Rules: nullable, url, max:255")
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
    public function update(StoreSubjectGroupPostRequest $request, Post $post)
    {
        return $this->success('Group post updated successfully.', $this->service->updateSubjectPost($request->user(), $post, $request->validated()));
    }

    public function destroy(Request $request, Post $post)
    {
        $this->service->deleteSubjectPost($request->user(), $post);

        return $this->success('Group post deleted successfully.');
    }

        /**
     * @OA\Patch(
     *     path="/api/staff-portal/posts/{post}/pin",
     *     summary="togglePin action in SubjectGroupController",
     *     tags={"StaffPortal"},
     *     @OA\Parameter(
     *         name="post",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The post parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"title", "content"},
     *             @OA\Property(property="title", type="string", description="Rules: required, string, max:180"),
     *             @OA\Property(property="content", type="string", description="Rules: required, string, max:5000"),
     *             @OA\Property(property="post_type", type="string", description="Rules: nullable, string, max:30"),
     *             @OA\Property(property="priority", type="string", description="Rules: nullable, string, max:20"),
     *             @OA\Property(property="is_pinned", type="boolean", description="Rules: nullable, boolean"),
     *             @OA\Property(property="attachment_label", type="string", description="Rules: nullable, string, max:180"),
     *             @OA\Property(property="attachment_url", type="string", description="Rules: nullable, url, max:255")
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
    public function togglePin(Request $request, Post $post)
    {
        return $this->success('Group post pin state updated successfully.', $this->service->togglePinnedPost($request->user(), $post));
    }
}
