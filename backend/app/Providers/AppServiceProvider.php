<?php

namespace App\Providers;

use App\Core\Enums\UserRole;
use App\Modules\Auth\Domain\Repositories\AuthRepositoryInterface;
use App\Modules\Auth\Infrastructure\Repositories\AuthRepository;
use App\Modules\Content\Infrastructure\Assessment;
use App\Modules\Content\Infrastructure\CourseFile;
use App\Modules\Content\Infrastructure\Exam;
use App\Modules\Content\Infrastructure\Lecture;
use App\Modules\Content\Infrastructure\SectionSession;
use App\Modules\Content\Infrastructure\Summary;
use App\Modules\Group\Models\Comment;
use App\Modules\Group\Models\Message;
use App\Modules\Group\Models\Post;
use App\Modules\UserManagement\Models\User;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Database\Eloquent\Relations\Relation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;
use SocialiteProviders\Manager\SocialiteWasCalled;
use SocialiteProviders\Microsoft\Provider as MicrosoftProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(AuthRepositoryInterface::class, AuthRepository::class);
    }

    public function boot(): void
    {
        Event::listen(function (SocialiteWasCalled $event): void {
            $event->extendSocialite('microsoft', MicrosoftProvider::class);
        });

        Relation::enforceMorphMap([
            'user' => User::class,
            'lecture' => Lecture::class,
            'section_session' => SectionSession::class,
            'summary' => Summary::class,
            'assessment' => Assessment::class,
            'exam' => Exam::class,
            'course_file' => CourseFile::class,
            'post' => Post::class,
            'comment' => Comment::class,
            'message' => Message::class,
            'grade_category' => \App\Modules\Grades\Models\GradeCategory::class,
            'student_grade' => \App\Modules\Grades\Models\StudentGrade::class,
            'uploaded_grade_sheet' => \App\Modules\Grades\Models\UploadedGradeSheet::class,
        ]);

        RateLimiter::for('login', function (Request $request) {
            return Limit::perMinute(5)->by(($request->ip() ?? 'unknown').'|'.$request->string('email'));
        });

        RateLimiter::for('sensitive', function (Request $request) {
            $key = $request->user()?->id ?: $request->ip();

            return Limit::perMinute(20)->by((string) $key);
        });

        RateLimiter::for('api', function (Request $request) {
            $role = $request->user()?->role?->value ?? UserRole::STUDENT->value;

            return Limit::perMinute(120)->by(($request->user()?->id ?? $request->ip()).'|'.$role);
        });

        RateLimiter::for('microsoft-link', function (Request $request) {
            return Limit::perMinute(5)->by(($request->ip() ?? 'unknown').'|'.$request->string('link_token'));
        });
    }
}
