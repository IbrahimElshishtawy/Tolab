<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sections', function (Blueprint $table) {
            $table->id();
            $table->string('name', 150);
            $table->unsignedTinyInteger('grade_year');
            $table->foreignId('department_id')->constrained()->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['department_id', 'name', 'grade_year']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sections');
    }
};
