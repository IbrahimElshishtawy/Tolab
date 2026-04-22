<?php

namespace App\Providers;

use App\Core\Enums\UserRole;
use App\Modules\Content\Models\Assessment;
use App\Modules\Content\Models\CourseFile;
use App\Modules\Content\Models\Exam;
use App\Modules\Content\Models\Lecture;
use App\Modules\Content\Models\SectionSession;
use App\Modules\Content\Models\Summary;
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
    public function register(): void {}

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
