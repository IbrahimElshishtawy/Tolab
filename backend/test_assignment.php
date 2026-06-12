<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\Schema;

$tables = ['staff_assignments', 'tasks', 'quizzes', 'academic_section_contents'];

foreach ($tables as $table) {
    if (Schema::hasTable($table)) {
        echo "Table: {$table}\nColumns: " . json_encode(Schema::getColumnListing($table)) . "\n\n";
    } else {
        echo "Table: {$table} does not exist!\n\n";
    }
}
