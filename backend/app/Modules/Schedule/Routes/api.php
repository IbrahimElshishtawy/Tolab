<?php

use App\Modules\Schedule\Controllers\ScheduleController;
use App\Modules\Schedule\Controllers\StudentScheduleController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum', 'active', 'throttle:api'])->group(function () {
    Route::get('student/timetable', [StudentScheduleController::class, 'index']);

    Route::prefix('admin')->middleware('admin')->group(function () {
        Route::post('courses/{courseOffering}/schedule-events', [ScheduleController::class, 'store'])->middleware('throttle:sensitive');
        Route::post('schedule-events/bulk', [ScheduleController::class, 'bulk'])->middleware('throttle:sensitive');
        Route::put('schedule-events/{scheduleEvent}', [ScheduleController::class, 'update'])->middleware('throttle:sensitive');
        Route::delete('schedule-events/{scheduleEvent}', [ScheduleController::class, 'destroy'])->middleware('throttle:sensitive');
    });
});
