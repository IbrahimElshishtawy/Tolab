<?php

namespace Database\Seeders;

use App\Core\Enums\GroupMemberRole;
use App\Core\Enums\NotificationType;
use App\Core\Enums\Semester;
use App\Core\Enums\StaffTitle;
use App\Core\Enums\UserRole;
use App\Core\Enums\WeekPattern;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Models\Section;
use App\Modules\Academic\Models\Subject;
use App\Modules\Content\Models\Lecture;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\Grades\Enums\GradeType;
use App\Modules\Grades\Models\GradeItem;
use App\Modules\Group\Models\Comment;
use App\Modules\Group\Models\GroupChat;
use App\Modules\Group\Models\GroupMember;
use App\Modules\Group\Models\Message;
use App\Modules\Group\Models\Post;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\Schedule\Enums\ScheduleEventType;
use App\Modules\Schedule\Models\ScheduleEvent;
use App\Modules\StaffPortal\Models\AcademicSectionContent;
use App\Modules\StaffPortal\Models\AcademicYear;
use App\Modules\StaffPortal\Models\Permission;
use App\Modules\StaffPortal\Models\Quiz;
use App\Modules\StaffPortal\Models\Role;
use App\Modules\StaffPortal\Models\StaffAssignment;
use App\Modules\StaffPortal\Models\Task;
use App\Modules\StaffPortal\Models\TaskSubmission;
use App\Modules\UserManagement\Models\StaffPermission;
use App\Modules\UserManagement\Models\StaffProfile;
use App\Modules\UserManagement\Models\StudentProfile;
use App\Modules\UserManagement\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Database\Seeder;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DoctorAssistantDashboardSeeder extends Seeder
{
    public function run(): void
    {
        $this->call(AcademicPermissionsSeeder::class);

        DB::transaction(function (): void {
            $now = CarbonImmutable::now(config('app.timezone'));
            $password = (string) env('DEFAULT_STAFF_PASSWORD', env('DEFAULT_ACADEMY_PASSWORD', '123456'));

            $academicYear = AcademicYear::factory()->create([
                'name' => 'Level 3 - 2025/2026',
                'level' => 3,
                'is_active' => true,
            ]);

            $department = Department::factory()->create([
                'name' => 'Computer Science',
                'code' => 'CS',
                'description' => 'Department of Computer Science',
                'is_active' => true,
            ]);

            $doctor = User::factory()->doctor()->create([
                'username' => 'dr.ahmed.hassan',
                'full_name' => 'Dr. Ahmed Hassan',
                'email' => 'doctor@tolab.edu',
                'university_email' => 'doctor@tolab.edu',
                'password_hash' => Hash::make($password),
                'phone' => '+20 100 000 1001',
                'last_login_at' => $now->subMinutes(25),
            ]);

            $assistant = User::factory()->teachingAssistant()->create([
                'username' => 'ta.sara.ali',
                'full_name' => 'Sara Ali',
                'email' => 'assistant@tolab.edu',
                'university_email' => 'assistant@tolab.edu',
                'password_hash' => Hash::make($password),
                'phone' => '+20 100 000 1002',
                'last_login_at' => $now->subHour(),
            ]);

            StaffProfile::factory()->create([
                'user_id' => $doctor->id,
                'department_id' => $department->id,
                'title' => StaffTitle::DOCTOR,
            ]);

            StaffProfile::factory()->create([
                'user_id' => $assistant->id,
                'department_id' => $department->id,
                'title' => StaffTitle::TA,
            ]);

            StaffPermission::factory()->create([
                'user_id' => $doctor->id,
                'can_upload_content' => true,
                'can_manage_grades' => true,
                'can_manage_schedule' => true,
                'can_moderate_group' => true,
            ]);

            StaffPermission::factory()->create([
                'user_id' => $assistant->id,
                'can_upload_content' => true,
                'can_manage_grades' => false,
                'can_manage_schedule' => false,
                'can_moderate_group' => true,
            ]);

            $this->applyRolesAndPermissions($doctor, $assistant);

            $subjects = collect($this->subjectBlueprints($now))
                ->map(fn (array $subjectData) => $this->seedSubjectWorkspace(
                    $subjectData,
                    $department,
                    $academicYear,
                    $doctor,
                    $assistant,
                    $now,
                ));

            $allStudents = $subjects->pluck('students')->flatten(1)->pluck('user');
            $this->seedNotifications($doctor, $assistant, $allStudents, $subjects->pluck('subject'), $now);
        });
    }

    protected function subjectBlueprints(CarbonImmutable $now): array
    {
        return [
            [
                'name' => 'Software Engineering II',
                'code' => 'CS402',
                'description' => 'Agile delivery, architecture, and testing.',
                'section_name' => 'Section A',
                'section_code' => 'SE-A',
                'group' => 'Software Engineering II - Section A',
                'lecture_room' => 'Hall 3',
                'lab_room' => 'Lab 2',
                'students' => [
                    ['username' => 'mahmoud.amin', 'full_name' => 'Mahmoud Amin', 'email' => 'mahmoud.amin@tolab.edu', 'student_code' => '20253001', 'gpa' => 3.58, 'last_login_at' => $now->subHours(2), 'midterm' => 42, 'task' => 22],
                    ['username' => 'omnia.sayed', 'full_name' => 'Omnia Sayed', 'email' => 'omnia.sayed@tolab.edu', 'student_code' => '20253002', 'gpa' => 3.31, 'last_login_at' => $now->subDays(3), 'midterm' => 35, 'task' => 18],
                    ['username' => 'youssef.kamal', 'full_name' => 'Youssef Kamal', 'email' => 'youssef.kamal@tolab.edu', 'student_code' => '20253003', 'gpa' => 2.87, 'last_login_at' => $now->subDays(15), 'midterm' => 24, 'task' => 11],
                    ['username' => 'nourhan.fawzy', 'full_name' => 'Nourhan Fawzy', 'email' => 'nourhan.fawzy@tolab.edu', 'student_code' => '20253004', 'gpa' => 3.72, 'last_login_at' => null, 'midterm' => 45, 'task' => 24],
                ],
                'tasks' => [
                    ['title' => 'Sprint Architecture Review', 'week' => 7, 'owner' => 'doctor', 'section_label' => 'Lecture 7', 'published' => true, 'due_date' => $now->subDays(2)->toDateString(), 'file_path' => 'tasks/software-engineering/sprint-architecture-review.pdf'],
                    ['title' => 'Service Contract Refactor', 'week' => 8, 'owner' => 'doctor', 'section_label' => 'Lecture 8', 'published' => false, 'due_date' => $now->addDay()->toDateString(), 'file_path' => 'tasks/software-engineering/service-contract-refactor.pdf'],
                ],
                'quizzes' => [
                    ['title' => 'Sprint Planning Quiz', 'owner' => 'doctor', 'published' => true, 'quiz_date' => $now->toDateString(), 'opens_at' => $now->setTime(9, 0), 'closes_at' => $now->setTime(9, 20), 'status' => 'published'],
                    ['title' => 'Retrospective Readiness Quiz', 'owner' => 'doctor', 'published' => false, 'quiz_date' => $now->addDays(4)->toDateString(), 'opens_at' => $now->addDays(4)->setTime(11, 0), 'closes_at' => $now->addDays(4)->setTime(11, 20), 'status' => 'draft'],
                ],
            ],
            [
                'name' => 'Database Administration',
                'code' => 'CS404',
                'description' => 'Query tuning, recovery, and replication.',
                'section_name' => 'Section B',
                'section_code' => 'DB-B',
                'group' => 'Database Administration - Section B',
                'lecture_room' => 'Hall 5',
                'lab_room' => 'Database Lab',
                'students' => [
                    ['username' => 'salma.hamed', 'full_name' => 'Salma Hamed', 'email' => 'salma.hamed@tolab.edu', 'student_code' => '20253005', 'gpa' => 3.47, 'last_login_at' => $now->subMinutes(50), 'midterm' => 38, 'task' => 21],
                    ['username' => 'karim.adel', 'full_name' => 'Karim Adel', 'email' => 'karim.adel@tolab.edu', 'student_code' => '20253006', 'gpa' => 2.41, 'last_login_at' => $now->subDays(12), 'midterm' => 22, 'task' => 9],
                    ['username' => 'mariam.tarek', 'full_name' => 'Mariam Tarek', 'email' => 'mariam.tarek@tolab.edu', 'student_code' => '20253007', 'gpa' => 3.19, 'last_login_at' => $now->subDays(6), 'midterm' => 31, 'task' => 17],
                    ['username' => 'ziad.gaber', 'full_name' => 'Ziad Gaber', 'email' => 'ziad.gaber@tolab.edu', 'student_code' => '20253008', 'gpa' => 2.15, 'last_login_at' => null, 'midterm' => 18, 'task' => 7],
                ],
                'tasks' => [
                    ['title' => 'Normalization Worksheet', 'week' => 7, 'owner' => 'assistant', 'section_label' => 'Lab 7', 'published' => true, 'due_date' => $now->subDay()->toDateString(), 'file_path' => 'tasks/database-administration/normalization-worksheet.pdf'],
                    ['title' => 'Index Tuning Lab', 'week' => 8, 'owner' => 'assistant', 'section_label' => 'Lab 8', 'published' => false, 'due_date' => $now->addDays(3)->toDateString(), 'file_path' => 'tasks/database-administration/index-tuning-lab.pdf'],
                ],
                'quizzes' => [
                    ['title' => 'Transaction Recovery Quiz', 'owner' => 'assistant', 'published' => true, 'quiz_date' => $now->addDay()->toDateString(), 'opens_at' => $now->addDay()->setTime(12, 0), 'closes_at' => $now->addDay()->setTime(12, 25), 'status' => 'published'],
                    ['title' => 'Replication Readiness Quiz', 'owner' => 'assistant', 'published' => false, 'quiz_date' => $now->addDays(5)->toDateString(), 'opens_at' => $now->addDays(5)->setTime(10, 30), 'closes_at' => $now->addDays(5)->setTime(10, 50), 'status' => 'draft'],
                ],
            ],
        ];
    }

    protected function seedSubjectWorkspace(
        array $subjectData,
        Department $department,
        AcademicYear $academicYear,
        User $doctor,
        User $assistant,
        CarbonImmutable $now,
    ): array {
        $subject = Subject::factory()->create([
            'name' => $subjectData['name'],
            'code' => $subjectData['code'],
            'description' => $subjectData['description'],
            'department_id' => $department->id,
            'academic_year_id' => $academicYear->id,
            'grade_year' => 3,
            'semester' => Semester::SECOND,
            'is_active' => true,
        ]);

        $section = Section::factory()->create([
            'name' => $subjectData['section_name'],
            'code' => $subjectData['section_code'],
            'subject_id' => $subject->id,
            'grade_year' => 3,
            'department_id' => $department->id,
            'academic_year_id' => $academicYear->id,
            'assistant_id' => $assistant->id,
            'is_active' => true,
        ]);

        $offering = CourseOffering::factory()->create([
            'subject_id' => $subject->id,
            'section_id' => $section->id,
            'academic_year' => '2025/2026',
            'semester' => Semester::SECOND,
            'doctor_user_id' => $doctor->id,
            'ta_user_id' => $assistant->id,
        ]);

        $group = GroupChat::factory()->create([
            'course_offering_id' => $offering->id,
            'name' => $subjectData['group'],
            'description' => $subjectData['description'],
            'created_by' => $doctor->id,
            'created_at' => $now->subWeeks(5),
            'updated_at' => $now->subDay(),
        ]);

        $offering->forceFill(['group_id' => $group->id])->save();

        StaffAssignment::factory()->create([
            'user_id' => $doctor->id,
            'subject_id' => $subject->id,
            'section_id' => $section->id,
            'department_id' => $department->id,
            'academic_year_id' => $academicYear->id,
            'assignment_type' => 'doctor',
        ]);

        StaffAssignment::factory()->create([
            'user_id' => $assistant->id,
            'subject_id' => $subject->id,
            'section_id' => $section->id,
            'department_id' => $department->id,
            'academic_year_id' => $academicYear->id,
            'assignment_type' => 'assistant',
        ]);

        GroupMember::factory()->create([
            'group_id' => $group->id,
            'user_id' => $doctor->id,
            'role_in_group' => GroupMemberRole::OWNER,
            'created_at' => $now->subWeeks(5),
            'updated_at' => $now->subDays(2),
        ]);

        GroupMember::factory()->create([
            'group_id' => $group->id,
            'user_id' => $assistant->id,
            'role_in_group' => GroupMemberRole::MOD,
            'created_at' => $now->subWeeks(5),
            'updated_at' => $now->subDays(2),
        ]);

        $students = collect($subjectData['students'])->values()->map(function (array $studentData, int $index) use ($department, $section, $offering, $group, $now): array {
            $student = User::factory()->create([
                'role' => UserRole::STUDENT,
                'role_type' => 'student',
                'username' => $studentData['username'],
                'full_name' => $studentData['full_name'],
                'email' => $studentData['email'],
                'university_email' => $studentData['email'],
                'national_id' => (string) (29901010000000 + ($section->id * 100) + $index),
                'password_hash' => Hash::make('Student@123'),
                'last_login_at' => $studentData['last_login_at'],
            ]);

            StudentProfile::factory()->create([
                'user_id' => $student->id,
                'student_code' => $studentData['student_code'],
                'gpa' => $studentData['gpa'],
                'grade_year' => 3,
                'department_id' => $department->id,
                'section_id' => $section->id,
            ]);

            Enrollment::factory()->create([
                'student_user_id' => $student->id,
                'course_offering_id' => $offering->id,
                'status' => Enrollment::STATUS_ENROLLED,
                'created_at' => $now->subWeeks(4),
                'updated_at' => $now->subDay(),
            ]);

            GroupMember::factory()->create([
                'group_id' => $group->id,
                'user_id' => $student->id,
                'role_in_group' => GroupMemberRole::MEMBER,
                'created_at' => $now->subWeeks(4),
                'updated_at' => $now->subDay(),
            ]);

            return [
                'user' => $student,
                'midterm' => $studentData['midterm'],
                'task' => $studentData['task'],
            ];
        });

        Lecture::factory()->create([
            'course_offering_id' => $offering->id,
            'subject_id' => $subject->id,
            'created_by' => $doctor->id,
            'week_number' => 6,
            'title' => $subject->name.' Lecture Pack',
            'description' => 'Published lecture resources and recording.',
            'instructor_name' => $doctor->full_name,
            'video_url' => 'https://example.com/lectures/'.strtolower($subject->code),
            'file_path' => 'lectures/'.strtolower($subject->code).'/week-6.pdf',
            'is_published' => true,
            'published_at' => $now->subDays(6),
            'date' => $now->subDays(6)->toDateString(),
            'created_at' => $now->subDays(6),
            'updated_at' => $now->subDays(5),
        ]);

        AcademicSectionContent::factory()->create([
            'subject_id' => $subject->id,
            'created_by' => $assistant->id,
            'week_number' => 6,
            'title' => $subject->name.' Lab Notes',
            'description' => 'Assistant section notes and starter material.',
            'assistant_name' => $assistant->full_name,
            'meeting_url' => 'https://example.com/sections/'.strtolower($subject->code),
            'delivery_mode' => 'onsite',
            'starts_at' => $now->subDays(4)->setTime(13, 0),
            'ends_at' => $now->subDays(4)->setTime(14, 30),
            'location_label' => $subjectData['lab_room'],
            'attachment_label' => 'Lab handout',
            'file_path' => 'sections/'.strtolower($subject->code).'/week-6.pdf',
            'is_published' => true,
            'published_at' => $now->subDays(4),
            'created_at' => $now->subDays(4),
            'updated_at' => $now->subDays(3),
        ]);

        $this->seedSchedule($subject, $offering, $department, $academicYear, $doctor, $assistant, $subjectData, $now);
        $tasks = $this->seedTasks($subject, $doctor, $assistant, $subjectData['tasks'], $now);
        $this->seedQuizzes($subject, $doctor, $assistant, $subjectData['quizzes'], $now);
        $this->seedTaskSubmissions($tasks, $students, $subject->code, $now);
        $this->seedGrades($offering, $doctor, $students, $now);
        $this->seedGroupActivity($group, $doctor, $assistant, $students, $subject->name, $now);

        return compact('subject', 'section', 'offering', 'group', 'students');
    }

    protected function applyRolesAndPermissions(User $doctor, User $assistant): void
    {
        $doctorRole = Role::query()->firstWhere('name', 'doctor');
        $assistantRole = Role::query()->firstWhere('name', 'assistant');

        $doctor->roles()->sync(array_filter([$doctorRole?->id]));
        $doctor->permissions()->sync(Permission::query()->pluck('id'));

        $assistant->roles()->sync(array_filter([$assistantRole?->id]));
        $assistant->permissions()->sync(
            Permission::query()
                ->whereIn('name', ['community.view', 'community.post', 'community.comment'])
                ->pluck('id'),
        );
    }

    protected function seedSchedule(
        Subject $subject,
        CourseOffering $offering,
        Department $department,
        AcademicYear $academicYear,
        User $doctor,
        User $assistant,
        array $subjectData,
        CarbonImmutable $now,
    ): void {
        foreach ([
            $now->subDays(2)->setTime(10, 0),
            $now->setTime(10, 0),
            $now->addDays(3)->setTime(10, 0),
        ] as $date) {
            ScheduleEvent::factory()->create([
                'course_offering_id' => $offering->id,
                'subject_id' => $subject->id,
                'department_id' => $department->id,
                'academic_year_id' => $academicYear->id,
                'staff_user_id' => $doctor->id,
                'type' => ScheduleEventType::LECTURE,
                'event_type' => ScheduleEventType::LECTURE->value,
                'title' => $subject->name.' Lecture',
                'description' => 'Weekly lecture session',
                'event_date' => $date->toDateString(),
                'day_of_week' => $date->dayOfWeek,
                'start_time' => $date->format('H:i:s'),
                'end_time' => $date->addHours(2)->format('H:i:s'),
                'location' => $subjectData['lecture_room'],
                'week_pattern' => WeekPattern::ALL,
                'color_key' => 'doctor-lecture',
                'is_completed' => $date->isPast(),
                'note' => 'Doctor-led lecture',
                'created_at' => $date->subWeek(),
                'updated_at' => $date->subDay(),
            ]);
        }

        foreach ([
            $now->subDay()->setTime(13, 0),
            $now->addDay()->setTime(13, 0),
        ] as $date) {
            ScheduleEvent::factory()->create([
                'course_offering_id' => $offering->id,
                'subject_id' => $subject->id,
                'department_id' => $department->id,
                'academic_year_id' => $academicYear->id,
                'staff_user_id' => $assistant->id,
                'type' => ScheduleEventType::SECTION,
                'event_type' => ScheduleEventType::SECTION->value,
                'title' => $subject->name.' Lab',
                'description' => 'Assistant-led section/lab session',
                'event_date' => $date->toDateString(),
                'day_of_week' => $date->dayOfWeek,
                'start_time' => $date->format('H:i:s'),
                'end_time' => $date->addMinutes(90)->format('H:i:s'),
                'location' => $subjectData['lab_room'],
                'week_pattern' => WeekPattern::ALL,
                'color_key' => 'assistant-section',
                'is_completed' => $date->isPast(),
                'note' => 'Hands-on section session',
                'created_at' => $date->subWeek(),
                'updated_at' => $date->subDay(),
            ]);
        }
    }

    protected function seedTasks(Subject $subject, User $doctor, User $assistant, array $taskData, CarbonImmutable $now): Collection
    {
        return collect($taskData)->map(function (array $task, int $index) use ($subject, $doctor, $assistant, $now): Task {
            $owner = $task['owner'] === 'assistant' ? $assistant : $doctor;

            return Task::factory()->create([
                'subject_id' => $subject->id,
                'created_by' => $owner->id,
                'week_number' => $task['week'],
                'title' => $task['title'],
                'lecture_or_section_name' => $task['section_label'],
                'owner_name' => $owner->full_name,
                'file_path' => $task['file_path'],
                'due_date' => $task['due_date'],
                'is_published' => $task['published'],
                'created_at' => $now->subDays(8 - $index),
                'updated_at' => $now->subDays(6 - $index),
            ]);
        })->values();
    }

    protected function seedQuizzes(Subject $subject, User $doctor, User $assistant, array $quizData, CarbonImmutable $now): void
    {
        collect($quizData)->each(function (array $quiz, int $index) use ($subject, $doctor, $assistant, $now): void {
            $owner = $quiz['owner'] === 'assistant' ? $assistant : $doctor;

            Quiz::factory()->create([
                'subject_id' => $subject->id,
                'created_by' => $owner->id,
                'week_number' => 8 + $index,
                'title' => $quiz['title'],
                'description' => 'Timed assessment window for the current module.',
                'owner_name' => $owner->full_name,
                'quiz_type' => 'online',
                'quiz_link' => 'https://example.com/quizzes/'.strtolower($subject->code).'/'.str($quiz['title'])->slug(),
                'quiz_date' => $quiz['quiz_date'],
                'opens_at' => $quiz['opens_at'],
                'closes_at' => $quiz['closes_at'],
                'duration_minutes' => 20,
                'status' => $quiz['status'],
                'is_graded' => true,
                'is_practice' => false,
                'total_marks' => 10,
                'questions_json' => [
                    ['type' => 'mcq', 'prompt' => 'Question 1', 'marks' => 2],
                    ['type' => 'true_false', 'prompt' => 'Question 2', 'marks' => 1],
                ],
                'is_published' => $quiz['published'],
                'created_at' => $now->subDays(5 - $index),
                'updated_at' => $now->subDays(3 - $index),
            ]);
        });
    }

    protected function seedTaskSubmissions(Collection $tasks, Collection $students, string $subjectCode, CarbonImmutable $now): void
    {
        $publishedTask = $tasks->firstWhere('is_published', true);

        if (! $publishedTask instanceof Task) {
            return;
        }

        $submissionMap = $subjectCode === 'CS402'
            ? [
                ['student_index' => 0, 'submitted_at' => $now->subDays(3), 'graded_at' => $now->subDays(2), 'score' => 18.5, 'feedback' => 'Excellent structure and clean diagrams.'],
                ['student_index' => 1, 'submitted_at' => $now->subDays(2)->subHours(3), 'graded_at' => $now->subDay(), 'score' => 13.0, 'feedback' => 'Good attempt, but sequence flow needs work.'],
                ['student_index' => 2, 'submitted_at' => $now->subDays(2)->subHour(), 'graded_at' => null, 'score' => null, 'feedback' => 'Waiting for grading.'],
            ]
            : [
                ['student_index' => 0, 'submitted_at' => $now->subDays(2), 'graded_at' => $now->subDay(), 'score' => 16.5, 'feedback' => 'Solid submission with minor SQL issues.'],
                ['student_index' => 2, 'submitted_at' => $now->subDay()->subHours(5), 'graded_at' => null, 'score' => null, 'feedback' => 'Queued for review.'],
            ];

        foreach ($submissionMap as $submission) {
            $student = $students[$submission['student_index']]['user'] ?? null;

            if (! $student instanceof User) {
                continue;
            }

            TaskSubmission::factory()->create([
                'task_id' => $publishedTask->id,
                'student_user_id' => $student->id,
                'status' => $submission['graded_at'] ? 'graded' : 'submitted',
                'submitted_at' => $submission['submitted_at'],
                'graded_at' => $submission['graded_at'],
                'score' => $submission['score'],
                'feedback' => $submission['feedback'],
                'created_at' => $submission['submitted_at'],
                'updated_at' => $submission['graded_at'] ?? $now->subHours(2),
            ]);
        }
    }

    protected function seedGrades(CourseOffering $offering, User $doctor, Collection $students, CarbonImmutable $now): void
    {
        foreach ($students as $studentMeta) {
            $student = $studentMeta['user'];

            GradeItem::factory()->create([
                'course_offering_id' => $offering->id,
                'student_user_id' => $student->id,
                'type' => GradeType::MIDTERM,
                'score' => $studentMeta['midterm'],
                'max_score' => 50,
                'note' => $studentMeta['midterm'] < 25 ? 'Midterm needs intervention.' : 'Midterm performance on track.',
                'updated_by' => $doctor->id,
                'created_at' => $now->subDays(10),
                'updated_at' => $now->subDays(2),
            ]);

            GradeItem::factory()->create([
                'course_offering_id' => $offering->id,
                'student_user_id' => $student->id,
                'type' => GradeType::TASK,
                'score' => $studentMeta['task'],
                'max_score' => 25,
                'note' => $studentMeta['task'] < 10 ? 'Low task score recorded.' : 'Task score recorded.',
                'updated_by' => $doctor->id,
                'created_at' => $now->subDays(4),
                'updated_at' => $now->subDay(),
            ]);
        }
    }

    protected function seedGroupActivity(
        GroupChat $group,
        User $doctor,
        User $assistant,
        Collection $students,
        string $subjectName,
        CarbonImmutable $now,
    ): void {
        $leadStudent = $students[0]['user'];
        $riskStudent = $students[2]['user'];

        $announcement = Post::factory()->create([
            'group_id' => $group->id,
            'author_user_id' => $doctor->id,
            'content_text' => sprintf("Lecture slides for %s are uploaded. Review the design notes before today's session.", $subjectName),
            'created_at' => $now->subDays(2),
            'updated_at' => $now->subDays(2),
        ]);

        $question = Post::factory()->create([
            'group_id' => $group->id,
            'author_user_id' => $leadStudent->id,
            'content_text' => 'Could you confirm whether the upcoming task needs individual diagrams or a shared submission?',
            'created_at' => $now->subHours(5),
            'updated_at' => $now->subHours(5),
        ]);

        Comment::factory()->create([
            'post_id' => $announcement->id,
            'author_user_id' => $assistant->id,
            'text' => 'Lab notes are attached as well, and I will walk through the starter files in section.',
            'created_at' => $now->subDay(),
            'updated_at' => $now->subDay(),
        ]);

        Comment::factory()->create([
            'post_id' => $question->id,
            'author_user_id' => $doctor->id,
            'text' => 'Submit individually, but you may discuss the approach together before drafting.',
            'created_at' => $now->subHours(3),
            'updated_at' => $now->subHours(3),
        ]);

        Message::factory()->create([
            'group_id' => $group->id,
            'sender_user_id' => $assistant->id,
            'text' => 'I will stay online for an extra 15 minutes after lab for questions.',
            'created_at' => $now->subHours(4),
            'updated_at' => $now->subHours(4),
        ]);

        Message::factory()->create([
            'group_id' => $group->id,
            'sender_user_id' => $leadStudent->id,
            'text' => 'Thank you, I will join after the session.',
            'created_at' => $now->subHours(2),
            'updated_at' => $now->subHours(2),
        ]);

        Message::factory()->create([
            'group_id' => $group->id,
            'sender_user_id' => $riskStudent->id,
            'text' => 'I am behind on the previous task and need clarification on the main deliverable.',
            'created_at' => $now->subMinutes(45),
            'updated_at' => $now->subMinutes(45),
        ]);
    }

    protected function seedNotifications(
        User $doctor,
        User $assistant,
        Collection $students,
        Collection $subjects,
        CarbonImmutable $now,
    ): void {
        UserNotification::factory()->create([
            'target_user_id' => $doctor->id,
            'title' => 'Unreviewed submissions detected',
            'body' => 'Two published tasks still have submissions waiting for grading.',
            'type' => NotificationType::GRADE,
            'category' => 'grading',
            'ref_type' => TaskSubmission::class,
            'ref_id' => TaskSubmission::query()->latest('id')->value('id'),
            'target_type' => 'dashboard',
            'target_id' => $doctor->id,
            'is_global' => false,
            'is_read' => false,
            'created_by' => $doctor->id,
            'created_at' => $now->subHour(),
            'updated_at' => $now->subHour(),
        ]);

        UserNotification::factory()->create([
            'target_user_id' => $doctor->id,
            'title' => 'Today schedule confirmed',
            'body' => 'Lecture rooms and attendance windows are synced for today.',
            'type' => NotificationType::SYSTEM,
            'category' => 'schedule',
            'is_global' => false,
            'is_read' => true,
            'created_by' => $assistant->id,
            'created_at' => $now->subDay(),
            'updated_at' => $now->subHours(12),
        ]);

        UserNotification::factory()->create([
            'target_user_id' => $assistant->id,
            'title' => 'Upcoming lab draft is unpublished',
            'body' => 'One section task is due soon and still hidden from students.',
            'type' => NotificationType::CONTENT,
            'category' => 'tasks',
            'ref_type' => Task::class,
            'ref_id' => Task::query()->where('is_published', false)->latest('id')->value('id'),
            'target_type' => 'dashboard',
            'target_id' => $assistant->id,
            'is_global' => false,
            'is_read' => false,
            'created_by' => $doctor->id,
            'created_at' => $now->subMinutes(35),
            'updated_at' => $now->subMinutes(35),
        ]);

        UserNotification::factory()->create([
            'target_user_id' => $assistant->id,
            'title' => 'Section resources published',
            'body' => 'Latest lab notes are visible to students.',
            'type' => NotificationType::CONTENT,
            'category' => 'sections',
            'is_global' => false,
            'is_read' => true,
            'created_by' => $assistant->id,
            'created_at' => $now->subDays(2),
            'updated_at' => $now->subDays(2),
        ]);

        UserNotification::factory()->create([
            'target_user_id' => null,
            'title' => 'Campus network maintenance',
            'body' => 'The LMS may be briefly unavailable after 11:00 PM.',
            'type' => NotificationType::BROADCAST,
            'category' => 'system',
            'target_type' => 'global',
            'target_id' => null,
            'is_global' => true,
            'is_read' => false,
            'created_by' => $doctor->id,
            'created_at' => $now->subMinutes(20),
            'updated_at' => $now->subMinutes(20),
        ]);

        foreach ($students->take(3) as $student) {
            UserNotification::factory()->create([
                'target_user_id' => $student->id,
                'title' => 'Grade updated',
                'body' => sprintf('A new grade has been posted in %s.', $subjects->first()?->name ?? 'your course'),
                'type' => NotificationType::GRADE,
                'category' => 'grades',
                'is_global' => false,
                'is_read' => false,
                'created_by' => $doctor->id,
                'created_at' => $now->subHours(6),
                'updated_at' => $now->subHours(6),
            ]);
        }
    }
}
