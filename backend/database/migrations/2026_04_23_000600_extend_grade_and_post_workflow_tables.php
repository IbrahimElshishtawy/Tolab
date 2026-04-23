<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('grade_items', function (Blueprint $table) {
            if (! Schema::hasColumn('grade_items', 'status')) {
                $table->string('status', 20)->default('draft')->after('max_score');
            }
            if (! Schema::hasColumn('grade_items', 'published_at')) {
                $table->timestamp('published_at')->nullable()->after('status');
            }
            if (! Schema::hasColumn('grade_items', 'entered_by_role')) {
                $table->string('entered_by_role', 20)->nullable()->after('published_at');
            }
        });

        Schema::table('posts', function (Blueprint $table) {
            if (! Schema::hasColumn('posts', 'is_pinned')) {
                $table->boolean('is_pinned')->default(false)->after('published_at');
            }
            if (! Schema::hasColumn('posts', 'attachment_label')) {
                $table->string('attachment_label', 180)->nullable()->after('is_pinned');
            }
            if (! Schema::hasColumn('posts', 'attachment_url')) {
                $table->string('attachment_url', 255)->nullable()->after('attachment_label');
            }
        });
    }

    public function down(): void {}
};
