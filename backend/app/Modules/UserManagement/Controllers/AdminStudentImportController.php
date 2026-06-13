<?php

namespace App\Modules\UserManagement\Controllers;

use App\Core\Base\ApiController;
use App\Modules\UserManagement\Requests\ImportStudentsRequest;
use App\Modules\UserManagement\Services\StudentImportService;

class AdminStudentImportController extends ApiController
{
    public function __construct(
        protected StudentImportService $studentImportService,
    ) {}

        /**
     * @OA\Post(
     *     path="/api/admin/import/students",
     *     summary="__invoke action in AdminStudentImportController",
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
    public function __invoke(ImportStudentsRequest $request)
    {
        $report = $this->studentImportService->import($request->file('file'), $request->user());

        return $this->success('Students imported successfully.', $report);
    }
}
