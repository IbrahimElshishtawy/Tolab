<?php

use App\Modules\Auth\Controllers\AuthController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function () {
    Route::post('login', [AuthController::class, 'login'])->middleware('throttle:login');
    Route::post('refresh', [AuthController::class, 'refresh'])->middleware('throttle:sensitive');

    Route::middleware(['auth:sanctum', 'active', 'throttle:api'])->group(function () {
        Route::post('logout', [AuthController::class, 'logout'])->middleware('throttle:sensitive');
        Route::post('change-password', [AuthController::class, 'changePassword'])->middleware('throttle:sensitive');
    });
});
