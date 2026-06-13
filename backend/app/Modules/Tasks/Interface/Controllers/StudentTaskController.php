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

    public function submit(Request $request, Task $task): JsonResponse
    {
        $validated = $request->validate([
            'attachments' => 'required|array',
            'attachments.*' => 'exists:file_uploads,id',
        ]);

        $submission = $this->submissionService->submit($task, $request->user(), $validated);

        return $this->success('Assignment submitted successfully.', $submission);
    }

    public function mySubmissions(Request $request): JsonResponse
    {
        $submissions = $request->user()->taskSubmissions()->with('task.subject')->latest()->get();
        return $this->success($submissions);
    }
}
