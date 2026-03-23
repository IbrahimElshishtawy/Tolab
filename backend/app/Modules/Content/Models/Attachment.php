<?php

namespace App\Modules\Content\Models;

use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphTo;

class Attachment extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'attachable_type',
        'attachable_id',
        'file_url',
        'file_name',
        'mime_type',
        'size',
        'uploaded_by',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'size' => 'integer',
            'created_at' => 'datetime',
        ];
    }

    public function attachable(): MorphTo
    {
        return $this->morphTo();
    }

    public function uploader(): BelongsTo
    {
        return $this->belongsTo(User::class, 'uploaded_by');
    }
}
