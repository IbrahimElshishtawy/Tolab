<?php

namespace App\Modules\Tasks\Application;

use App\Core\Exceptions\ApiException;
use App\Modules\Tasks\Infrastructure\Task;
use App\Modules\Tasks\Infrastructure\TaskSubmission;
use App\Modules\UserManagement\Models\User;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

class TaskSubmissionService
{
    public function submit(Task $task, User $student, array $data): TaskSubmission
    {
        if ($task->due_at && $task->due_at->isPast()) {
             throw new ApiException('The due date for this task has passed.', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        return DB::transaction(function () use ($task, $student, $data) {
            $submission = TaskSubmission::query()->updateOrCreate(
                [
                    'task_id' => $task->id,
                    'student_user_id' => $student->id,
                ],
                [
                    'status' => 'submitted',
                    'submitted_at' => now(),
                ]
            );

            if (!empty($data['attachments'])) {
                $submission->attachments()->delete();
                foreach ($data['attachments'] as $attachmentId) {
                     $submission->attachments()->create(['file_upload_id' => $attachmentId]);
                }
            }

            return $submission->load('attachments.fileUpload');
        });
    }
}
