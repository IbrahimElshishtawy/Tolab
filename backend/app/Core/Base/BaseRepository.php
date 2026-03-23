<?php

namespace App\Core\Base;

use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

abstract class BaseRepository
{
    public function __construct(protected Model $model)
    {
    }

    public function query(): Builder
    {
        return $this->model->newQuery();
    }

    public function paginate(Builder $query, int $perPage = 15): LengthAwarePaginator
    {
        return $query->paginate($perPage);
    }
}
