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
        'category',
        'ref_type',
        'ref_id',
        'target_type',
        'target_id',
        'is_global',
        'is_read',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'type' => NotificationType::class,
            'is_read' => 'boolean',
            'is_global' => 'boolean',
            'created_at' => 'datetime',
            'updated_at' => 'datetime',
        ];
    }

    public function targetUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'target_user_id');
    }
}
