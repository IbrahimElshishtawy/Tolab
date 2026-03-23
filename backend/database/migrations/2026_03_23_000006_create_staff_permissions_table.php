<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('staff_permissions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->boolean('can_upload_content')->default(false);
            $table->boolean('can_manage_grades')->default(false);
            $table->boolean('can_manage_schedule')->default(false);
            $table->boolean('can_moderate_group')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('staff_permissions');
    }
};
