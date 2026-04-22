<?php

namespace App\Modules\UserManagement\Models;

use App\Core\Enums\UserRole;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Models\Section;
use App\Modules\Academic\Models\Subject;
use App\Modules\Content\Models\Assessment;
use App\Modules\Content\Models\Exam;
use App\Modules\Content\Models\Summary;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\Grades\Models\GradeItem;
use App\Modules\Group\Models\Comment;
use App\Modules\Group\Models\GroupChat;
use App\Modules\Group\Models\GroupMember;
use App\Modules\Group\Models\Message;
use App\Modules\Group\Models\Post;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\Shared\Models\AuditLog;
use App\Modules\Shared\Models\RefreshToken;
use App\Modules\StaffPortal\Models\Permission;
use App\Modules\StaffPortal\Models\Role;
use App\Modules\StaffPortal\Models\StaffAssignment;
use App\Modules\StaffPortal\Models\TaskSubmission;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
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
        'role_type',
        'username',
        'full_name',
        'email',
        'university_email',
        'microsoft_id',
        'microsoft_email',
        'microsoft_name',
        'microsoft_avatar',
        'is_microsoft_linked',
        'password_hash',
        'national_id',
        'is_active',
        'avatar',
        'phone',
        'last_login_at',
        'notification_enabled',
        'language',
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
            'is_microsoft_linked' => 'boolean',
            'password_hash' => 'hashed',
            'last_login_at' => 'datetime',
            'notification_enabled' => 'boolean',
        ];
    }

    protected static function newFactory(): UserFactory
    {
        return UserFactory::new();
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

    public function enrolledCourseOfferings(): BelongsToMany
    {
        return $this->belongsToMany(CourseOffering::class, 'enrollments', 'student_user_id', 'course_offering_id')
            ->withPivot(['status'])
            ->withTimestamps();
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

    public function groups(): BelongsToMany
    {
        return $this->belongsToMany(GroupChat::class, 'group_members', 'user_id', 'group_id')
            ->withPivot(['role_in_group'])
            ->withTimestamps();
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

    public function roles()
    {
        return $this->belongsToMany(Role::class, 'portal_role_user');
    }

    public function permissions()
    {
        return $this->belongsToMany(Permission::class, 'portal_permission_user');
    }

    public function staffAssignments(): HasMany
    {
        return $this->hasMany(StaffAssignment::class);
    }

    public function taskSubmissions(): HasMany
    {
        return $this->hasMany(TaskSubmission::class, 'student_user_id');
    }

    public function managedSubjects()
    {
        return $this->belongsToMany(Subject::class, 'staff_assignments')
            ->withPivot(['section_id', 'department_id', 'academic_year_id', 'assignment_type'])
            ->withTimestamps();
    }

    public function assignedSections()
    {
        return $this->hasMany(Section::class, 'assistant_id');
    }

    public function isAdmin(): bool
    {
        return $this->role === UserRole::ADMIN || $this->role_type === 'admin';
    }

    public function isStudent(): bool
    {
        return $this->role === UserRole::STUDENT;
    }

    public function isStaff(): bool
    {
        return in_array($this->role, [UserRole::DOCTOR, UserRole::TA], true);
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

    public function effectivePermissions(): array
    {
        $rolePermissions = $this->roles()
            ->with('permissions:id,name')
            ->get()
            ->flatMap(fn (Role $role) => $role->permissions->pluck('name'));

        $directPermissions = $this->permissions()->pluck('name');

        return $rolePermissions
            ->merge($directPermissions)
            ->unique()
            ->values()
            ->all();
    }

    public function hasPermission(string $permission): bool
    {
        return $this->isAdmin() || in_array($permission, $this->effectivePermissions(), true);
    }
}
