<?php

namespace App\Modules\UserManagement\Models;

use App\Core\Enums\UserRole;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Content\Models\Assessment;
use App\Modules\Content\Models\Exam;
use App\Modules\Content\Models\Summary;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\Grades\Models\GradeItem;
use App\Modules\Group\Models\Comment;
use App\Modules\Group\Models\GroupMember;
use App\Modules\Group\Models\Message;
use App\Modules\Group\Models\Post;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\Shared\Models\AuditLog;
use App\Modules\Shared\Models\RefreshToken;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;
    use HasFactory;
    use Notifiable;

    protected $fillable = [
        'role',
        'username',
        'email',
        'password_hash',
        'national_id',
        'is_active',
    ];

    protected $hidden = [
        'password_hash',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'role' => UserRole::class,
            'is_active' => 'boolean',
            'password_hash' => 'hashed',
        ];
    }

    public function getAuthPassword(): string
    {
        return $this->password_hash;
    }

    public function studentProfile(): HasOne
    {
        return $this->hasOne(StudentProfile::class);
    }

    public function staffProfile(): HasOne
    {
        return $this->hasOne(StaffProfile::class);
    }

    public function staffPermission(): HasOne
    {
        return $this->hasOne(StaffPermission::class);
    }

    public function refreshTokens(): HasMany
    {
        return $this->hasMany(RefreshToken::class);
    }

    public function auditLogs(): HasMany
    {
        return $this->hasMany(AuditLog::class, 'actor_user_id');
    }

    public function enrollments(): HasMany
    {
        return $this->hasMany(Enrollment::class, 'student_user_id');
    }

    public function doctorCourseOfferings(): HasMany
    {
        return $this->hasMany(CourseOffering::class, 'doctor_user_id');
    }

    public function taCourseOfferings(): HasMany
    {
        return $this->hasMany(CourseOffering::class, 'ta_user_id');
    }

    public function createdSummaries(): HasMany
    {
        return $this->hasMany(Summary::class, 'created_by');
    }

    public function createdAssessments(): HasMany
    {
        return $this->hasMany(Assessment::class, 'created_by');
    }

    public function createdExams(): HasMany
    {
        return $this->hasMany(Exam::class, 'created_by');
    }

    public function groupMemberships(): HasMany
    {
        return $this->hasMany(GroupMember::class);
    }

    public function posts(): HasMany
    {
        return $this->hasMany(Post::class, 'author_user_id');
    }

    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class, 'author_user_id');
    }

    public function messages(): HasMany
    {
        return $this->hasMany(Message::class, 'sender_user_id');
    }

    public function gradeItems(): HasMany
    {
        return $this->hasMany(GradeItem::class, 'student_user_id');
    }

    public function notificationsFeed(): HasMany
    {
        return $this->hasMany(UserNotification::class, 'target_user_id');
    }

    public function isAdmin(): bool
    {
        return $this->role === UserRole::ADMIN;
    }

    public function isStudent(): bool
    {
        return $this->role === UserRole::STUDENT;
    }

    public function canManageContent(): bool
    {
        return $this->isAdmin() || (bool) $this->staffPermission?->can_upload_content;
    }

    public function canManageGrades(): bool
    {
        return $this->isAdmin() || (bool) $this->staffPermission?->can_manage_grades;
    }

    public function canManageSchedule(): bool
    {
        return $this->isAdmin() || (bool) $this->staffPermission?->can_manage_schedule;
    }
}
