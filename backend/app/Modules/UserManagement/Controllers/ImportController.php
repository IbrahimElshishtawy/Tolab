<?php

namespace App\Modules\UserManagement\Controllers;

use App\Core\Base\ApiController;
use App\Modules\UserManagement\Requests\ImportUsersRequest;
use App\Modules\UserManagement\Services\UserService;

class ImportController extends ApiController
{
    public function __construct(protected UserService $userService) {}

    public function students(ImportUsersRequest $request)
    {
        $result = $this->userService->importStudents($request->file('file'), $request->user());

        return $this->success('Students imported successfully.', $result);
    }

        /**
     * @OA\Post(
     *     path="/api/admin/import/staff",
     *     summary="staff action in ImportController",
     *     tags={"UserManagement"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"file"},
     *             @OA\Property(property="file", type="string", description="Rules: required, file, mimes:csv,txt,xlsx,xls, max:10240")
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
    public function staff(ImportUsersRequest $request)
    {
        $result = $this->userService->importStaff($request->file('file'), $request->user());

        return $this->success('Staff imported successfully.', $result);
    }
}
