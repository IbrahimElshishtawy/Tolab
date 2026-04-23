<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Models\Subject;
use App\Modules\StaffPortal\Requests\SaveSubjectGradesRequest;
use App\Modules\StaffPortal\Services\PortalService;

class GradeManagementController extends ApiController
{
    public function __construct(protected PortalService $service) {}

    public function saveDraft(SaveSubjectGradesRequest $request, Subject $subject)
    {
        return $this->success('Grades draft saved successfully.', $this->service->saveSubjectGrades($request->user(), $subject, $request->validated(), false));
    }

    public function publish(SaveSubjectGradesRequest $request, Subject $subject)
    {
        return $this->success('Grades published successfully.', $this->service->saveSubjectGrades($request->user(), $subject, $request->validated(), true));
    }
}
