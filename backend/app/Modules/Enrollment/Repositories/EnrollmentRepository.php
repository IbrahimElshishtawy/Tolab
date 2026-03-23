<?php

namespace App\Modules\Enrollment\Repositories;

use App\Core\Base\BaseRepository;
use App\Modules\Enrollment\Models\Enrollment;

class EnrollmentRepository extends BaseRepository
{
    public function __construct(Enrollment $model)
    {
        parent::__construct($model);
    }
}
