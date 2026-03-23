<?php

namespace App\Modules\Notifications\Models;

use App\Core\Enums\NotificationType;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserNotification extends Model
{
    use HasFactory;

    protected $table = 'user_notifications';

    protected $fillable = [
        'target_user_id',
        'title',
        'body',
        'type',
        'ref_type',
        'ref_id',
        'is_read',
    ];

    protected function casts(): array
    {
        return [
            'type' => NotificationType::class,
            'is_read' => 'boolean',
        ];
    }

    public function targetUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'target_user_id');
    }
}
