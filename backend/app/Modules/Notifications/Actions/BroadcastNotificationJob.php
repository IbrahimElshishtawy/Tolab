<?php

namespace App\Modules\Notifications\Actions;

use App\Core\Enums\NotificationType;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\UserManagement\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class BroadcastNotificationJob implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public function __construct(protected array $payload) {}

    public function handle(): void
    {
        $type = $this->payload['type'] ?? NotificationType::BROADCAST;
        $typeValue = $type instanceof NotificationType ? $type->value : (string) $type;

        User::query()
            ->where('is_active', true)
            ->select('id')
            ->chunkById(500, function ($users) use ($typeValue) {
                $rows = [];

                foreach ($users as $user) {
                    $rows[] = [
                        'target_user_id' => $user->id,
                        'title' => $this->payload['title'],
                        'body' => $this->payload['body'],
                        'type' => $typeValue,
                        'ref_type' => $this->payload['ref_type'] ?? null,
                        'ref_id' => $this->payload['ref_id'] ?? null,
                        'is_read' => false,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ];
                }

                if ($rows !== []) {
                    UserNotification::query()->insert($rows);
                }
            });
    }
}
