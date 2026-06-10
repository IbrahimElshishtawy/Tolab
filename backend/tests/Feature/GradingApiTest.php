<?php

namespace Tests\Feature;

use App\Core\Enums\Semester;
use App\Core\Enums\UserRole;
use App\Modules\Academic\Infrastructure\CourseOffering;
use App\Modules\Academic\Infrastructure\Department;
use App\Modules\Academic\Infrastructure\Section;
use App\Modules\Academic\Infrastructure\Subject;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\Grades\Models\GradeCategory;
use App\Modules\Grades\Models\StudentGrade;
use App\Modules\Grades\Models\UploadedGradeSheet;
use App\Modules\UserManagement\Models\StudentProfile;
use App\Modules\UserManagement\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class GradingApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');
    }

    public function test_results_endpoint_retrieves_correct_data_for_staff()
    {
        [$student, $doctor, $subject] = $this->createScenario();

        Sanctum::actingAs($doctor);

        $response = $this->getJson("/api/v1/subjects/{$subject->id}/results");

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.subject_id', $subject->id)
            ->assertJsonPath('data.subject_name', $subject->name)
            ->assertJsonCount(4, 'data.categories');
    }

    public function test_non_staff_cannot_access_results_endpoint()
    {
        [$student, $doctor, $subject] = $this->createScenario();

        Sanctum::actingAs($student);

        $response = $this->getJson("/api/v1/subjects/{$subject->id}/results");

        $response->assertForbidden();
    }

    public function test_grades_draft_can_be_saved()
    {
        [$student, $doctor, $subject] = $this->createScenario();
        $studentProfile = $student->studentProfile;

        Sanctum::actingAs($doctor);

        $response = $this->postJson("/api/v1/subjects/{$subject->id}/grades/draft", [
            'category_key' => 'midterm',
            'max_score' => 20.0,
            'entries' => [
                [
                    'student_code' => $studentProfile->student_code,
                    'score' => 18.5,
                    'note' => 'Excellent performance',
                ]
            ]
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('message', 'Draft grades saved successfully.');

        $this->assertDatabaseHas('student_grades', [
            'student_id' => $studentProfile->id,
            'score' => 18.5,
            'status' => 'draft',
            'note' => 'Excellent performance',
        ]);
    }

    public function test_score_bounds_validation_throws_bad_request()
    {
        [$student, $doctor, $subject] = $this->createScenario();
        $studentProfile = $student->studentProfile;

        Sanctum::actingAs($doctor);

        $response = $this->postJson("/api/v1/subjects/{$subject->id}/grades/draft", [
            'category_key' => 'midterm',
            'max_score' => 20.0,
            'entries' => [
                [
                    'student_code' => $studentProfile->student_code,
                    'score' => 25.0, // exceeding max_score
                ]
            ]
        ]);

        $response->assertStatus(400)
            ->assertJsonPath('success', false);
    }

    public function test_grades_can_be_published_and_sends_notification()
    {
        [$student, $doctor, $subject] = $this->createScenario();
        $studentProfile = $student->studentProfile;

        Sanctum::actingAs($doctor);

        $response = $this->postJson("/api/v1/subjects/{$subject->id}/grades/publish", [
            'category_key' => 'midterm',
            'max_score' => 20.0,
            'entries' => [
                [
                    'student_code' => $studentProfile->student_code,
                    'score' => 18.5,
                ]
            ]
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true);

        $this->assertDatabaseHas('student_grades', [
            'student_id' => $studentProfile->id,
            'score' => 18.5,
            'status' => 'published',
        ]);

        $this->assertDatabaseHas('user_notifications', [
            'target_user_id' => $student->id,
            'title' => 'Grades Published',
        ]);
    }

    public function test_csv_upload_auto_grades_and_returns_warnings_for_unrecognized_codes()
    {
        [$student, $doctor, $subject] = $this->createScenario();
        $studentProfile = $student->studentProfile;

        Sanctum::actingAs($doctor);

        $csvContent = "{$studentProfile->student_code},19.0\n20239999,15.5\n";
        $file = UploadedFile::fake()->createWithContent('grades.csv', $csvContent);

        $response = $this->postJson("/api/v1/subjects/{$subject->id}/grades/upload-sheet", [
            'category_key' => 'midterm',
            'file' => $file,
        ]);

        $response->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'warnings');

        $this->assertDatabaseHas('student_grades', [
            'student_id' => $studentProfile->id,
            'score' => 19.0,
            'status' => 'published',
        ]);
    }

    public function test_pdf_upload_saves_as_shared_grade_sheet()
    {
        [$student, $doctor, $subject] = $this->createScenario();

        Sanctum::actingAs($doctor);

        $file = UploadedFile::fake()->create('official_grades.pdf', 142);

        $response = $this->postJson("/api/v1/subjects/{$subject->id}/grades/upload-sheet", [
            'category_key' => 'midterm',
            'file' => $file,
        ]);

        $response->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.mimeType', 'PDF');

        $this->assertDatabaseHas('uploaded_grade_sheets', [
            'subject_id' => $subject->id,
            'file_name' => 'official_grades.pdf',
        ]);
    }

    public function test_student_dashboard_returns_published_grades_and_masks_drafts()
    {
        [$student, $doctor, $subject] = $this->createScenario();
        $studentProfile = $student->studentProfile;

        $catPub = GradeCategory::create([
            'subject_id' => $subject->id,
            'key_name' => 'midterm',
            'label' => 'Midterm Exam',
            'max_score' => 20.0,
            'status' => 'published',
        ]);

        $catDraft = GradeCategory::create([
            'subject_id' => $subject->id,
            'key_name' => 'coursework',
            'label' => 'Assignments / coursework',
            'max_score' => 30.0,
            'status' => 'draft',
        ]);

        StudentGrade::create([
            'student_id' => $studentProfile->id,
            'grade_category_id' => $catPub->id,
            'score' => 18.5,
            'status' => 'published',
            'graded_by' => $doctor->id,
        ]);

        StudentGrade::create([
            'student_id' => $studentProfile->id,
            'grade_category_id' => $catDraft->id,
            'score' => 28.0,
            'status' => 'draft',
            'graded_by' => $doctor->id,
        ]);

        Sanctum::actingAs($student);

        $response = $this->getJson('/api/v1/student/dashboard');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.student_code', $studentProfile->student_code)
            ->assertJsonPath('data.subjects.0.grades.0.category_label', 'Midterm Exam')
            ->assertJsonPath('data.subjects.0.grades.0.score', 18.5)
            ->assertJsonPath('data.subjects.0.grades.0.status', 'Published')
            ->assertJsonPath('data.subjects.0.grades.1.category_label', 'Assignments / coursework')
            ->assertJsonPath('data.subjects.0.grades.1.score', null)
            ->assertJsonPath('data.subjects.0.grades.1.status', 'Draft');
    }

    private function createScenario(): array
    {
        $department = Department::factory()->create();
        $section = Section::factory()->create([
            'department_id' => $department->id,
            'grade_year' => 3,
        ]);

        $subject = Subject::factory()->create([
            'department_id' => $department->id,
            'grade_year' => 3,
            'semester' => Semester::FIRST,
        ]);

        $doctor = User::factory()->doctor()->create();

        $offering = CourseOffering::factory()->create([
            'subject_id' => $subject->id,
            'section_id' => $section->id,
            'doctor_user_id' => $doctor->id,
            'semester' => Semester::FIRST,
        ]);

        $student = User::factory()->create([
            'role' => UserRole::STUDENT,
        ]);

        StudentProfile::factory()->create([
            'user_id' => $student->id,
            'department_id' => $department->id,
            'section_id' => $section->id,
            'grade_year' => 3,
            'student_code' => '20230041',
            'gpa' => 3.9,
        ]);

        Enrollment::factory()->create([
            'student_user_id' => $student->id,
            'course_offering_id' => $offering->id,
            'status' => Enrollment::STATUS_ENROLLED,
        ]);

        return [$student, $doctor, $subject];
    }
}
