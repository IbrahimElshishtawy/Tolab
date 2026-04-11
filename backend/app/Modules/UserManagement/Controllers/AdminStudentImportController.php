<?php

namespace App\Modules\UserManagement\Controllers;

use App\Core\Base\ApiController;
use App\Modules\UserManagement\Requests\ImportStudentsRequest;
use App\Modules\UserManagement\Services\StudentImportService;

class AdminStudentImportController extends ApiController
{
    public function __construct(
        protected StudentImportService $studentImportService,
    ) {
    }

    public function __invoke(ImportStudentsRequest $request)
    {
        $report = $this->studentImportService->import($request->file('file'), $request->user());

        return $this->success('Students imported successfully.', $report);
    }
}
