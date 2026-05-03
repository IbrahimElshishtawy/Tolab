<?php

use App\Modules\Tasks\Interface\Controllers\StudentTaskController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum', 'active', 'throttle:api'])->group(function () {
    Route::post('student/tasks/{task}/submit', [StudentTaskController::class, 'submit']);
    Route::get('student/my-submissions', [StudentTaskController::class, 'mySubmissions']);
});
