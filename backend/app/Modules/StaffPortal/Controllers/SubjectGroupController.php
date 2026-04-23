<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Models\Subject;
use App\Modules\Group\Models\Post;
use App\Modules\StaffPortal\Requests\StoreSubjectGroupPostRequest;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class SubjectGroupController extends ApiController
{
    public function __construct(protected PortalService $service) {}

    public function show(Request $request, Subject $subject)
    {
        return $this->success('Subject group feed retrieved successfully.', $this->service->subjectGroup($request->user(), $subject));
    }

    public function store(StoreSubjectGroupPostRequest $request, Subject $subject)
    {
        return $this->success('Group post created successfully.', $this->service->saveSubjectPost($request->user(), $subject, $request->validated()), 201);
    }

    public function update(StoreSubjectGroupPostRequest $request, Post $post)
    {
        return $this->success('Group post updated successfully.', $this->service->updateSubjectPost($request->user(), $post, $request->validated()));
    }

    public function destroy(Request $request, Post $post)
    {
        $this->service->deleteSubjectPost($request->user(), $post);

        return $this->success('Group post deleted successfully.');
    }

    public function togglePin(Request $request, Post $post)
    {
        return $this->success('Group post pin state updated successfully.', $this->service->togglePinnedPost($request->user(), $post));
    }
}
