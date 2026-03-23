<?php

namespace App\Modules\Notifications\Services;

use App\Core\Enums\NotificationType;
use App\Core\Exceptions\ApiException;
use App\Modules\Notifications\Actions\BroadcastNotificationJob;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\Notifications\Repositories\NotificationRepository;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\UserManagement\Models\User;
use Symfony\Component\HttpFoundation\Response;

class NotificationService
{
    public function __construct(
        protected NotificationRepository $repository,
        protected AuditLogService $auditLogService,
    ) {
    }

    public function list(User $user, int $perPage = 15)
    {
        return $this->repository->paginate($this->repository->forUser($user), $perPage);
    }

    public function markRead(UserNotification $notification, User $user): UserNotification
    {
        if ($notification->target_user_id !== null && $notification->target_user_id !== $user->id && ! $user->isAdmin()) {
            throw new ApiException('You are not allowed to access this notification.', [], Response::HTTP_FORBIDDEN);
        }

        $notification->update(['is_read' => true]);

        return $notification->refresh();
    }

    public function broadcast(array $payload, User $actor): void
    {
        $payload['type'] = $payload['type'] ?? NotificationType::BROADCAST;
        BroadcastNotificationJob::dispatch($payload);
        $this->auditLogService->log($actor, 'notifications.broadcast', null, [
            'title' => $payload['title'],
            'type' => $payload['type'] instanceof NotificationType ? $payload['type']->value : $payload['type'],
        ], request());
    }
}
