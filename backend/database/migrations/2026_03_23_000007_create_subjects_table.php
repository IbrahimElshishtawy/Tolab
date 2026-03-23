<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subjects', function (Blueprint $table) {
            $table->id();
            $table->string('name', 150);
            $table->string('code', 40)->unique();
            $table->foreignId('department_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('grade_year');
            $table->string('semester', 20);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index(['department_id', 'grade_year', 'semester']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subjects');
    }
};
