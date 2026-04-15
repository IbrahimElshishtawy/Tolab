<?php

namespace App\Modules\Group\Models;

use App\Core\Enums\GroupMemberRole;
use App\Modules\UserManagement\Models\User;
use Database\Factories\GroupMemberFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GroupMember extends Model
{
    use HasFactory;

    protected $fillable = [
        'group_id',
        'user_id',
        'role_in_group',
    ];

    protected function casts(): array
    {
        return [
            'role_in_group' => GroupMemberRole::class,
        ];
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(GroupChat::class, 'group_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    protected static function newFactory(): GroupMemberFactory
    {
        return GroupMemberFactory::new();
    }
}
