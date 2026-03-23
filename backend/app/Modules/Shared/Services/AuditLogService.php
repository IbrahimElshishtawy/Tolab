<?php

namespace App\Modules\Shared\Services;

use App\Modules\Shared\Models\AuditLog;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;

class AuditLogService
{
    public function log(
        ?User $actor,
        string $action,
        ?Model $target = null,
        array $meta = [],
        ?Request $request = null
    ): void {
        AuditLog::query()->create([
            'actor_user_id' => $actor?->id,
            'action' => $action,
            'target_type' => $target?->getMorphClass(),
            'target_id' => $target?->getKey(),
            'meta' => $meta,
            'ip_address' => $request?->ip(),
            'created_at' => now(),
        ]);
    }
}
