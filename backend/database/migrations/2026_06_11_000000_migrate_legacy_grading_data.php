<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

return new class extends Migration
{
    public $command;

    public function up(): void
    {
        if (!Schema::hasTable('grade_items')) {
            $this->logMessage('grade_items table does not exist. Skipping data migration.');
            $this->outputReport(0, 0, 0, 0);
            return;
        }

        $legacyCount = DB::table('grade_items')->count();
        if ($legacyCount === 0) {
            $this->logMessage('grade_items table is empty. Skipping data migration.');
            $this->outputReport(0, 0, 0, 0);
            return;
        }

        $migratedCount = 0;
        $skippedCount = 0;
        $failedCount = 0;

        DB::beginTransaction();

        try {
            // Retrieve all legacy grade items
            $gradeItems = DB::table('grade_items')->get();

            // Fetch default admin user to fallback for graded_by
            $defaultGraderId = DB::table('users')->where('role', 'admin')->value('id') 
                ?? DB::table('users')->value('id') 
                ?? 1;

            foreach ($gradeItems as $item) {
                // 1. Resolve student_profile ID from student_user_id
                $studentId = DB::table('student_profiles')
                    ->where('user_id', $item->student_user_id)
                    ->value('id');

                if (!$studentId) {
                    $this->logWarning("Orphaned grade item ID {$item->id}: No student profile found for user ID {$item->student_user_id}");
                    $skippedCount++;
                    continue;
                }

                // 2. Resolve subject ID from course_offering_id
                $subjectId = DB::table('course_offerings')
                    ->where('id', $item->course_offering_id)
                    ->value('subject_id');

                if (!$subjectId) {
                    $this->logWarning("Orphaned grade item ID {$item->id}: No subject found for course offering ID {$item->course_offering_id}");
                    $skippedCount++;
                    continue;
                }

                // 3. Find or create the grade category
                $type = $item->type;
                $categoryId = DB::table('grade_categories')
                    ->where('subject_id', $subjectId)
                    ->where('key_name', $type)
                    ->value('id');

                if (!$categoryId) {
                    $categoryId = DB::table('grade_categories')->insertGetId([
                        'subject_id' => $subjectId,
                        'key_name' => $type,
                        'label' => ucfirst($type),
                        'max_score' => $item->max_score,
                        'status' => $item->status ?? 'draft',
                        'created_at' => $item->created_at ?? now(),
                        'updated_at' => $item->updated_at ?? now(),
                    ]);
                } else {
                    // Update max score on category if current item's max score is higher
                    $currentMax = DB::table('grade_categories')->where('id', $categoryId)->value('max_score');
                    if ($item->max_score > $currentMax) {
                        DB::table('grade_categories')->where('id', $categoryId)->update([
                            'max_score' => $item->max_score,
                            'updated_at' => now(),
                        ]);
                    }
                }

                // 4. Insert student grade if it doesn't already exist (supporting safe re-runs)
                $exists = DB::table('student_grades')
                    ->where('student_id', $studentId)
                    ->where('grade_category_id', $categoryId)
                    ->exists();

                if ($exists) {
                    $skippedCount++;
                    continue;
                }

                DB::table('student_grades')->insert([
                    'student_id' => $studentId,
                    'grade_category_id' => $categoryId,
                    'score' => $item->score,
                    'status' => $item->status ?? 'draft',
                    'note' => $item->note,
                    'graded_by' => $item->updated_by ?? $defaultGraderId,
                    'created_at' => $item->created_at ?? now(),
                    'updated_at' => $item->updated_at ?? now(),
                ]);

                $migratedCount++;
            }

            DB::commit();
            $this->logMessage('Legacy grading data migrated successfully.');

        } catch (\Exception $e) {
            DB::rollBack();
            $this->logError("Failed to migrate legacy grading data: " . $e->getMessage());
            $failedCount = $legacyCount - $migratedCount - $skippedCount;
        }

        $this->outputReport($legacyCount, $migratedCount, $skippedCount, $failedCount);
    }

    public function down(): void
    {
        // Rollback data migration by deleting student grades and categories associated with migrated subject types
        DB::transaction(function () {
            DB::table('student_grades')->truncate();
            DB::table('grade_categories')->truncate();
        });
    }

    protected function logMessage(string $message): void
    {
        Log::info($message);
        if ($this->command) {
            $this->command->info($message);
        }
    }

    protected function logWarning(string $message): void
    {
        Log::warning($message);
        if ($this->command) {
            $this->command->warn($message);
        }
    }

    protected function logError(string $message): void
    {
        Log::error($message);
        if ($this->command) {
            $this->command->error($message);
        }
    }

    protected function outputReport(int $legacy, int $migrated, int $skipped, int $failed): void
    {
        $report = "\n" .
            "Legacy Count: {$legacy}\n" .
            "Migrated Count: {$migrated}\n" .
            "Skipped Count: {$skipped}\n" .
            "Failed Count: {$failed}\n";

        Log::info("Grading Migration Report: " . $report);

        if ($this->command) {
            $this->command->line($report);
        } else {
            echo $report;
        }
    }
};
