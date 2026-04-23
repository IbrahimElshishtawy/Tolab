<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Content\Models\Lecture;
use App\Modules\StaffPortal\Requests\StoreLecturePortalRequest;
use App\Modules\StaffPortal\Resources\LecturePortalResource;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class LectureController extends ApiController
{
    public function __construct(protected PortalService $service) {}

    public function index(Request $request)
    {
        return $this->success('Lectures retrieved successfully.', LecturePortalResource::collection($this->service->lectures($request->user())));
    }

    public function store(StoreLecturePortalRequest $request)
    {
        return $this->success('Lecture created successfully.', LecturePortalResource::make($this->service->createLecture($request->user(), $request->validated())), 201);
    }

    public function destroy(Request $request, Lecture $lecture)
    {
        $this->service->deleteLecture($request->user(), $lecture);

        return $this->success('Lecture deleted successfully.');
    }

    public function publish(Request $request, Lecture $lecture)
    {
        return $this->success('Lecture published successfully.', LecturePortalResource::make($this->service->publishLecture($request->user(), $lecture)));
    }
}
