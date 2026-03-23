<?php

namespace App\Modules\Group\Models;

use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Message extends Model
{
    use HasFactory;
    use SoftDeletes;

    protected $fillable = [
        'group_id',
        'sender_user_id',
        'text',
    ];

    public function group(): BelongsTo
    {
        return $this->belongsTo(GroupChat::class, 'group_id');
    }

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_user_id');
    }
}
