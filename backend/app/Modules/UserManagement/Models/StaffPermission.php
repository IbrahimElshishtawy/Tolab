<?php

namespace App\Modules\UserManagement\Models;

use Database\Factories\StaffPermissionFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StaffPermission extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'can_upload_content',
        'can_manage_grades',
        'can_manage_schedule',
        'can_moderate_group',
    ];

    protected function casts(): array
    {
        return [
            'can_upload_content' => 'boolean',
            'can_manage_grades' => 'boolean',
            'can_manage_schedule' => 'boolean',
            'can_moderate_group' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    protected static function newFactory(): StaffPermissionFactory
    {
        return StaffPermissionFactory::new();
    }
}
