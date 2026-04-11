<?php

namespace Tests\Feature;

use App\Core\Enums\UserRole;
use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Models\Section;
use App\Modules\UserManagement\Models\StudentProfile;
use App\Modules\UserManagement\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Cache;
use Laravel\Sanctum\Sanctum;
use Laravel\Socialite\Facades\Socialite;
use SocialiteProviders\Manager\OAuth2\User as SocialiteUser;
use Tests\TestCase;

class StudentRegistrationMicrosoftAuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_import_students_excel(): void
    {
        $admin = User::factory()->admin()->create();

        Sanctum::actingAs($admin);

        $response = $this->post('/api/admin/import/students', [
            'file' => $this->makeStudentCsv([
                [
                    'student_name' => 'Ali Hassan',
                    'university_email' => 'ali.hassan@tolab.edu',
                    'national_id' => '29801011234567',
                    'department_name' => 'Computer Science',
                    'section_name' => 'General',
                    'grade_year' => '3',
                    'student_code' => 'STD1001',
                    'gpa' => '3.45',
                ],
            ]),
        ], ['Accept' => 'application/json']);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.total_rows', 1)
            ->assertJsonPath('data.imported_rows', 1)
            ->assertJsonPath('data.updated_rows', 0)
            ->assertJsonPath('data.failed_rows', 0);

        $this->assertDatabaseHas('users', [
            'university_email' => 'ali.hassan@tolab.edu',
            'role' => UserRole::STUDENT->value,
            'national_id' => '29801011234567',
        ]);

        $this->assertDatabaseHas('student_profiles', [
            'student_code' => 'STD1001',
            'grade_year' => 3,
        ]);
    }

    public function test_duplicate_students_are_handled_without_creating_duplicate_accounts(): void
    {
        $admin = User::factory()->admin()->create();

        Sanctum::actingAs($admin);

        $response = $this->post('/api/admin/import/students', [
            'file' => $this->makeStudentCsv([
                [
                    'student_name' => 'Mona Adel',
                    'university_email' => 'mona.adel@tolab.edu',
                    'national_id' => '29801011234561',
                    'department_name' => 'Information Systems',
                    'section_name' => 'A',
                    'grade_year' => '2',
                    'student_code' => 'STD2002',
                    'gpa' => '3.10',
                ],
                [
                    'student_name' => 'Mona Adel',
                    'university_email' => 'mona.adel@tolab.edu',
                    'national_id' => '29801011234561',
                    'department_name' => 'Information Systems',
                    'section_name' => 'A',
                    'grade_year' => '2',
                    'student_code' => 'STD2002',
                    'gpa' => '3.60',
                ],
            ]),
        ], ['Accept' => 'application/json']);

        $response->assertOk()
            ->assertJsonPath('data.total_rows', 2)
            ->assertJsonPath('data.imported_rows', 1)
            ->assertJsonPath('data.updated_rows', 1)
            ->assertJsonPath('data.failed_rows', 0);

        $this->assertSame(1, User::query()->where('university_email', 'mona.adel@tolab.edu')->count());
        $this->assertDatabaseHas('student_profiles', [
            'student_code' => 'STD2002',
            'gpa' => 3.60,
        ]);
    }

    public function test_microsoft_redirect_works(): void
    {
        Socialite::fake('microsoft');

        $response = $this->get('/api/auth/microsoft/redirect');

        $response->assertRedirect('https://socialite.fake/microsoft/authorize');
    }

    public function test_microsoft_callback_with_unknown_email_is_rejected(): void
    {
        Socialite::fake('microsoft', $this->fakeMicrosoftUser(
            microsoftId: 'ms-unknown',
            email: 'unknown.student@tolab.edu',
        ));

        $response = $this->getJson('/api/auth/microsoft/callback?code=test-code&state=fake-state');

        $response->assertForbidden()
            ->assertJsonPath('success', false);
    }

    public function test_microsoft_callback_with_known_email_requires_linking_when_student_is_not_linked(): void
    {
        $student = $this->createImportedStudent([
            'email' => 'known.student@tolab.edu',
            'national_id' => '29801011234562',
        ]);

        Socialite::fake('microsoft', $this->fakeMicrosoftUser(
            microsoftId: 'ms-link-required',
            email: $student->university_email,
            name: 'Known Student',
        ));

        $response = $this->getJson('/api/auth/microsoft/callback?code=test-code&state=fake-state');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'link_required')
            ->assertJsonPath('data.user.id', $student->id);

        $this->assertNotEmpty($response->json('data.link_token'));
    }

    public function test_complete_link_with_correct_national_id_succeeds(): void
    {
        $student = $this->createImportedStudent([
            'email' => 'link.success@tolab.edu',
            'national_id' => '29801011234563',
        ]);

        $linkToken = $this->requestLinkTokenFor($student, 'ms-link-success');

        $response = $this->postJson('/api/auth/microsoft/complete-link', [
            'link_token' => $linkToken,
            'national_id' => '29801011234563',
            'device_name' => 'phpunit',
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.id', $student->id)
            ->assertJsonPath('data.user.is_microsoft_linked', true);

        $this->assertDatabaseHas('users', [
            'id' => $student->id,
            'microsoft_id' => 'ms-link-success',
            'is_microsoft_linked' => true,
        ]);
    }

    public function test_complete_link_with_wrong_national_id_fails(): void
    {
        $student = $this->createImportedStudent([
            'email' => 'link.failure@tolab.edu',
            'national_id' => '29801011234564',
        ]);

        $linkToken = $this->requestLinkTokenFor($student, 'ms-link-failure');

        $response = $this->postJson('/api/auth/microsoft/complete-link', [
            'link_token' => $linkToken,
            'national_id' => '29801011230000',
        ]);

        $response->assertUnprocessable()
            ->assertJsonPath('success', false);

        $this->assertDatabaseHas('users', [
            'id' => $student->id,
            'is_microsoft_linked' => false,
        ]);
    }

    public function test_linked_student_can_login_directly_with_microsoft(): void
    {
        $student = $this->createImportedStudent([
            'email' => 'linked.student@tolab.edu',
            'national_id' => '29801011234565',
            'microsoft_id' => 'ms-linked-student',
            'microsoft_email' => 'linked.student@tolab.edu',
            'microsoft_name' => 'Linked Student',
            'is_microsoft_linked' => true,
        ]);

        Socialite::fake('microsoft', $this->fakeMicrosoftUser(
            microsoftId: 'ms-linked-student',
            email: $student->university_email,
            name: 'Linked Student',
        ));

        $response = $this->getJson('/api/auth/microsoft/callback?code=test-code&state=fake-state');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.id', $student->id)
            ->assertJsonPath('data.user.is_microsoft_linked', true);
    }

    public function test_inactive_student_cannot_login_with_microsoft(): void
    {
        $student = $this->createImportedStudent([
            'email' => 'inactive.student@tolab.edu',
            'national_id' => '29801011234566',
            'microsoft_id' => 'ms-inactive-student',
            'is_microsoft_linked' => true,
            'is_active' => false,
        ]);

        Socialite::fake('microsoft', $this->fakeMicrosoftUser(
            microsoftId: 'ms-inactive-student',
            email: $student->university_email,
        ));

        $response = $this->getJson('/api/auth/microsoft/callback?code=test-code&state=fake-state');

        $response->assertForbidden()
            ->assertJsonPath('success', false);
    }

    public function test_microsoft_account_already_linked_to_another_student_is_rejected(): void
    {
        $linkedStudent = $this->createImportedStudent([
            'email' => 'first.student@tolab.edu',
            'national_id' => '29801011234567',
            'microsoft_id' => 'ms-shared-account',
            'is_microsoft_linked' => true,
        ]);

        $otherStudent = $this->createImportedStudent([
            'email' => 'second.student@tolab.edu',
            'national_id' => '29801011234568',
        ]);

        Socialite::fake('microsoft', $this->fakeMicrosoftUser(
            microsoftId: 'ms-shared-account',
            email: $otherStudent->university_email,
        ));

        $response = $this->getJson('/api/auth/microsoft/callback?code=test-code&state=fake-state');

        $response->assertConflict()
            ->assertJsonPath('success', false);

        $this->assertDatabaseHas('users', [
            'id' => $linkedStudent->id,
            'microsoft_id' => 'ms-shared-account',
        ]);
    }

    protected function createImportedStudent(array $attributes = []): User
    {
        $department = Department::query()->firstOrCreate([
            'name' => $attributes['department_name'] ?? 'Computer Science',
        ]);

        $section = Section::query()->firstOrCreate([
            'department_id' => $department->id,
            'name' => $attributes['section_name'] ?? 'General',
            'grade_year' => $attributes['grade_year'] ?? 3,
        ]);

        $student = User::factory()->create([
            'role' => UserRole::STUDENT,
            'role_type' => 'student',
            'full_name' => $attributes['full_name'] ?? 'Student Example',
            'username' => $attributes['full_name'] ?? 'Student Example',
            'email' => $attributes['email'] ?? 'student.example@tolab.edu',
            'university_email' => $attributes['email'] ?? 'student.example@tolab.edu',
            'national_id' => $attributes['national_id'] ?? '29801011234560',
            'microsoft_id' => $attributes['microsoft_id'] ?? null,
            'microsoft_email' => $attributes['microsoft_email'] ?? null,
            'microsoft_name' => $attributes['microsoft_name'] ?? null,
            'is_microsoft_linked' => $attributes['is_microsoft_linked'] ?? false,
            'is_active' => $attributes['is_active'] ?? true,
        ]);

        StudentProfile::query()->create([
            'user_id' => $student->id,
            'student_code' => $attributes['student_code'] ?? 'STD'.str_pad((string) $student->id, 4, '0', STR_PAD_LEFT),
            'gpa' => $attributes['gpa'] ?? 3.20,
            'grade_year' => $attributes['grade_year'] ?? 3,
            'department_id' => $department->id,
            'section_id' => $section->id,
        ]);

        return $student;
    }

    protected function requestLinkTokenFor(User $student, string $microsoftId): string
    {
        Socialite::fake('microsoft', $this->fakeMicrosoftUser(
            microsoftId: $microsoftId,
            email: $student->university_email,
            name: $student->full_name,
        ));

        $response = $this->getJson('/api/auth/microsoft/callback?code=test-code&state=fake-state');
        $response->assertOk()->assertJsonPath('data.status', 'link_required');

        $linkToken = $response->json('data.link_token');

        $this->assertIsString($linkToken);
        $this->assertNotNull(Cache::get('microsoft-link:'.$linkToken));

        return $linkToken;
    }

    protected function fakeMicrosoftUser(string $microsoftId, string $email, ?string $name = 'Microsoft Student'): SocialiteUser
    {
        $claims = [
            'oid' => $microsoftId,
            'sub' => $microsoftId,
            'email' => $email,
        ];

        $raw = [
            'id' => $microsoftId,
            'displayName' => $name,
            'mail' => $email,
            'userPrincipalName' => $email,
        ];

        return (new SocialiteUser())
            ->setRaw($raw)
            ->map([
                'id' => $microsoftId,
                'nickname' => null,
                'name' => $name,
                'email' => $email,
                'avatar' => null,
            ])
            ->setAccessTokenResponseBody([
                'id_token' => $this->fakeJwt($claims),
            ]);
    }

    protected function fakeJwt(array $claims): string
    {
        $header = rtrim(strtr(base64_encode(json_encode(['alg' => 'none', 'typ' => 'JWT'])), '+/', '-_'), '=');
        $payload = rtrim(strtr(base64_encode(json_encode($claims)), '+/', '-_'), '=');

        return $header.'.'.$payload.'.signature';
    }

    protected function makeStudentCsv(array $rows): UploadedFile
    {
        $headers = [
            'student_name',
            'university_email',
            'national_id',
            'department_name',
            'section_name',
            'grade_year',
            'student_code',
            'gpa',
        ];

        $content = implode(',', $headers).PHP_EOL;

        foreach ($rows as $row) {
            $content .= implode(',', [
                $row['student_name'],
                $row['university_email'],
                $row['national_id'],
                $row['department_name'],
                $row['section_name'],
                $row['grade_year'],
                $row['student_code'] ?? '',
                $row['gpa'] ?? '',
            ]).PHP_EOL;
        }

        return UploadedFile::fake()->createWithContent('students.csv', $content);
    }
}
