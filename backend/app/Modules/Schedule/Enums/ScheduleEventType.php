<?php

namespace App\Modules\Schedule\Enums;

enum ScheduleEventType: string
{
    case LECTURE = 'LECTURE';
    case SECTION = 'SECTION';
    case QUIZ = 'QUIZ';
    case TASK_DUE = 'TASK_DUE';
    case EXAM = 'EXAM';
    case OTHER = 'OTHER';
}
