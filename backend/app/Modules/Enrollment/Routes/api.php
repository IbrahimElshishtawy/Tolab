<?php

use App\Modules\Enrollment\Controllers\EnrollmentController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum', 'active', 'admin', 'throttle:api'])->prefix('admin')->group(function () {
    Route::post('enrollments', [EnrollmentController::class, 'store'])->middleware('throttle:sensitive');
    Route::post('enrollments/bulk', [EnrollmentController::class, 'bulk'])->middleware('throttle:sensitive');
    Route::delete('enrollments/{enrollment}', [EnrollmentController::class, 'destroy'])->middleware('throttle:sensitive');
});
