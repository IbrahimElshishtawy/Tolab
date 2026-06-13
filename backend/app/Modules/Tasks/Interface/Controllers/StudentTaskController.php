<?php

namespace App\Modules\Tasks\Interface\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Tasks\Application\TaskSubmissionService;
use App\Modules\Tasks\Infrastructure\Task;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class StudentTaskController extends ApiController
{
    public function __construct(protected TaskSubmissionService $submissionService) {}

        /**
     * @OA\Post(
     *     path="/api/student/tasks/{task}/submit",
     *     summary="submit action in StudentTaskController",
     *     tags={"Tasks"},
     *     @OA\Parameter(
     *         name="task",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The task parameter"
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
    public function submit(Request $request, Task $task): JsonResponse
    {
        $validated = $request->validate([
            'attachments' => 'required|array',
            'attachments.*' => 'exists:file_uploads,id',
        ]);

        $submission = $this->submissionService->submit($task, $request->user(), $validated);

        return $this->success('Assignment submitted successfully.', $submission);
    }

        /**
     * @OA\Get(
     *     path="/api/student/my-submissions",
     *     summary="mySubmissions action in StudentTaskController",
     *     tags={"Tasks"},
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
    public function mySubmissions(Request $request): JsonResponse
    {
        $submissions = $request->user()->taskSubmissions()->with('task.subject')->latest()->get();
        return $this->success($submissions);
    }
}
