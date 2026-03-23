<?php

namespace App\Modules\Group\Repositories;

use App\Core\Base\BaseRepository;
use App\Modules\Group\Models\GroupChat;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Builder;

class GroupRepository extends BaseRepository
{
    public function __construct(GroupChat $model)
    {
        parent::__construct($model);
    }

    public function memberGroups(User $user): Builder
    {
        return $this->query()
            ->with(['courseOffering.subject', 'members.user'])
            ->whereHas('members', fn (Builder $query) => $query->where('user_id', $user->id));
    }
}
