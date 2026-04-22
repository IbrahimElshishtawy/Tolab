<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Models\Subject;
use App\Modules\StaffPortal\Resources\SubjectPortalResource;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class SubjectController extends ApiController
{
    public function __construct(protected PortalService $service) {}

    public function index(Request $request)
    {
        return $this->success('Subjects retrieved successfully.', SubjectPortalResource::collection($this->service->subjects($request->user())));
    }

    public function show(Request $request, Subject $subject)
    {
        return $this->success('Subject retrieved successfully.', SubjectPortalResource::make($this->service->subject($request->user(), $subject)));
    }
}
