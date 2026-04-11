<?php

namespace App\Modules\Notifications\Repositories;

use App\Core\Base\BaseRepository;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Builder;

class NotificationRepository extends BaseRepository
{
    public function __construct(UserNotification $model)
    {
        parent::__construct($model);
    }

    public function forUser(User $user): Builder
    {
        return $this->query()
            ->where(function (Builder $query) use ($user) {
                $query->where('target_user_id', $user->id)
                    ->orWhere(function (Builder $inner) {
                        $inner->whereNull('target_user_id')
                            ->where('is_global', true);
                    });
            })
            ->latest();
    }
}
