<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'microsoft_id')) {
                $table->string('microsoft_id', 191)->nullable()->after('university_email')->unique();
            }

            if (! Schema::hasColumn('users', 'microsoft_email')) {
                $table->string('microsoft_email', 180)->nullable()->after('microsoft_id');
            }

            if (! Schema::hasColumn('users', 'microsoft_name')) {
                $table->string('microsoft_name', 180)->nullable()->after('microsoft_email');
            }

            if (! Schema::hasColumn('users', 'microsoft_avatar')) {
                $table->string('microsoft_avatar', 255)->nullable()->after('microsoft_name');
            }

            if (! Schema::hasColumn('users', 'is_microsoft_linked')) {
                $table->boolean('is_microsoft_linked')->default(false)->after('microsoft_avatar');
            }

            if (! Schema::hasColumn('users', 'is_active')) {
                $table->boolean('is_active')->default(true)->after('national_id');
            }

            if (! Schema::hasColumn('users', 'last_login_at')) {
                $table->timestamp('last_login_at')->nullable()->after('phone');
            }

            if (! Schema::hasColumn('users', 'national_id')) {
                $table->string('national_id', 40)->nullable()->unique()->after('password_hash');
            }
        });

        Schema::table('student_profiles', function (Blueprint $table) {
            if (! Schema::hasColumn('student_profiles', 'student_code')) {
                $table->string('student_code', 50)->nullable()->after('user_id')->unique();
            }
        });
    }

    public function down(): void
    {
        Schema::table('student_profiles', function (Blueprint $table) {
            if (Schema::hasColumn('student_profiles', 'student_code')) {
                $table->dropUnique(['student_code']);
                $table->dropColumn('student_code');
            }
        });

        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'microsoft_id')) {
                $table->dropUnique(['microsoft_id']);
            }

            $columns = [
                'microsoft_id',
                'microsoft_email',
                'microsoft_name',
                'microsoft_avatar',
                'is_microsoft_linked',
            ];

            $existingColumns = array_values(array_filter($columns, fn (string $column) => Schema::hasColumn('users', $column)));

            if ($existingColumns !== []) {
                $table->dropColumn($existingColumns);
            }
        });
    }
};
