<?php

use App\Modules\Content\Controllers\AdminContentController;
use App\Modules\Content\Controllers\FileUploadController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum', 'active', 'throttle:api'])->group(function () {
    Route::post('files/upload', [FileUploadController::class, 'upload'])->middleware('throttle:sensitive');

    Route::prefix('admin')->middleware('admin')->group(function () {
        Route::post('courses/{courseOffering}/lectures', [AdminContentController::class, 'storeLecture'])->middleware('throttle:sensitive');
        Route::put('lectures/{lecture}', [AdminContentController::class, 'updateLecture'])->middleware('throttle:sensitive');
        Route::delete('lectures/{lecture}', [AdminContentController::class, 'deleteLecture'])->middleware('throttle:sensitive');

        Route::post('courses/{courseOffering}/sections', [AdminContentController::class, 'storeSectionSession'])->middleware('throttle:sensitive');
        Route::put('sections-sessions/{sectionSession}', [AdminContentController::class, 'updateSectionSession'])->middleware('throttle:sensitive');
        Route::delete('sections-sessions/{sectionSession}', [AdminContentController::class, 'deleteSectionSession'])->middleware('throttle:sensitive');

        Route::post('courses/{courseOffering}/summaries', [AdminContentController::class, 'storeSummary'])->middleware('throttle:sensitive');
        Route::delete('summaries/{summary}', [AdminContentController::class, 'deleteSummary'])->middleware('throttle:sensitive');

        Route::post('courses/{courseOffering}/assessments', [AdminContentController::class, 'storeAssessment'])->middleware('throttle:sensitive');
        Route::put('assessments/{assessment}', [AdminContentController::class, 'updateAssessment'])->middleware('throttle:sensitive');
        Route::delete('assessments/{assessment}', [AdminContentController::class, 'deleteAssessment'])->middleware('throttle:sensitive');

        Route::post('courses/{courseOffering}/exams', [AdminContentController::class, 'storeExam'])->middleware('throttle:sensitive');
        Route::put('exams/{exam}', [AdminContentController::class, 'updateExam'])->middleware('throttle:sensitive');
        Route::delete('exams/{exam}', [AdminContentController::class, 'deleteExam'])->middleware('throttle:sensitive');

        Route::post('courses/{courseOffering}/files', [AdminContentController::class, 'storeCourseFile'])->middleware('throttle:sensitive');
        Route::delete('course-files/{courseFile}', [AdminContentController::class, 'deleteCourseFile'])->middleware('throttle:sensitive');
    });
});
