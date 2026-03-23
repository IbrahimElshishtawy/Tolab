<?php

use App\Modules\Grades\Controllers\GradeController;
use App\Modules\Grades\Controllers\StudentGradeController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum', 'active', 'throttle:api'])->group(function () {
    Route::get('student/courses/{courseOffering}/grades', [StudentGradeController::class, 'index']);

    Route::prefix('admin')->middleware('admin')->group(function () {
        Route::get('courses/{courseOffering}/grades', [GradeController::class, 'index']);
        Route::post('courses/{courseOffering}/grades', [GradeController::class, 'store'])->middleware('throttle:sensitive');
        Route::put('grades/{grade}', [GradeController::class, 'update'])->middleware('throttle:sensitive');
        Route::delete('grades/{grade}', [GradeController::class, 'destroy'])->middleware('throttle:sensitive');
    });
});
