<?php

use App\Modules\Notifications\Controllers\NotificationController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum', 'active', 'throttle:api'])->group(function () {
    Route::get('notifications', [NotificationController::class, 'index']);
    Route::patch('notifications/{notification}/read', [NotificationController::class, 'markRead'])->middleware('throttle:sensitive');

    Route::prefix('admin')->middleware('admin')->group(function () {
        Route::post('notifications/broadcast', [NotificationController::class, 'broadcast'])->middleware('throttle:sensitive');
    });
});
