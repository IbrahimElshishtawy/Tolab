<?php

namespace App\Providers;

use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Policies\CourseOfferingPolicy;
use App\Modules\Grades\Models\GradeItem;
use App\Modules\Grades\Policies\GradePolicy;
use App\Modules\Group\Models\Comment;
use App\Modules\Group\Models\GroupChat;
use App\Modules\Group\Models\Message;
use App\Modules\Group\Models\Post;
use App\Modules\Group\Policies\CommentPolicy;
use App\Modules\Group\Policies\GroupPolicy;
use App\Modules\Group\Policies\MessagePolicy;
use App\Modules\Group\Policies\PostPolicy;
use App\Modules\Schedule\Models\ScheduleEvent;
use App\Modules\Schedule\Policies\SchedulePolicy;
use App\Modules\UserManagement\Models\User;
use App\Modules\UserManagement\Policies\UserPolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    protected $policies = [
        User::class => UserPolicy::class,
        CourseOffering::class => CourseOfferingPolicy::class,
        GroupChat::class => GroupPolicy::class,
        Post::class => PostPolicy::class,
        Comment::class => CommentPolicy::class,
        Message::class => MessagePolicy::class,
        GradeItem::class => GradePolicy::class,
        ScheduleEvent::class => SchedulePolicy::class,
    ];

    public function boot(): void
    {
        $this->registerPolicies();
    }
}
