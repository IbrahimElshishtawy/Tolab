<?php

namespace App\Modules\Shared\Traits;

use App\Modules\Content\Infrastructure\Attachment;
use Illuminate\Database\Eloquent\Relations\MorphMany;

trait HasAttachments
{
    public function attachments(): MorphMany
    {
        return $this->morphMany(Attachment::class, 'attachable');
    }
}
