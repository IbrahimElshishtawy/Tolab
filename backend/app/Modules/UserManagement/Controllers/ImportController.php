<?php

namespace App\Modules\UserManagement\Controllers;

use App\Core\Base\ApiController;
use App\Modules\UserManagement\Requests\ImportUsersRequest;
use App\Modules\UserManagement\Services\UserService;

class ImportController extends ApiController
{
    public function __construct(protected UserService $userService)
    {
    }

    public function students(ImportUsersRequest $request)
    {
        $result = $this->userService->importStudents($request->file('file'), $request->user());

        return $this->success('Students imported successfully.', $result);
    }

    public function staff(ImportUsersRequest $request)
    {
        $result = $this->userService->importStaff($request->file('file'), $request->user());

        return $this->success('Staff imported successfully.', $result);
    }
}
