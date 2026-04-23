<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Models\Subject;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class ResultsController extends ApiController
{
    public function __construct(protected PortalService $service) {}

    public function index(Request $request)
    {
        return $this->success('Results overview retrieved successfully.', $this->service->resultsOverview($request->user()));
    }

    public function show(Request $request, Subject $subject)
    {
        return $this->success('Subject results retrieved successfully.', $this->service->subjectResults($request->user(), $subject));
    }

    public function students(Request $request, Subject $subject)
    {
        return $this->success('Subject students retrieved successfully.', $this->service->subjectStudents($request->user(), $subject));
    }

    public function categories(Request $request, Subject $subject)
    {
        return $this->success('Role-based grading categories retrieved successfully.', $this->service->gradingCategories($request->user(), $subject));
    }
}
