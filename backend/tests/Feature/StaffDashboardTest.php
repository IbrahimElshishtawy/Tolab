<?php

namespace Tests\Feature;

use App\Modules\StaffPortal\Models\Permission;
use App\Modules\UserManagement\Models\StaffPermission;
use App\Modules\UserManagement\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class StaffAuthFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_doctor_can_login_and_access_staff_dashboard(): void
    {
        $doctor = User::factory()->doctor()->create([
            'full_name' => 'Dr. Ahmed Hassan',
            'university_email' => 'doctor@tolab.edu',
            'password_hash' => Hash::make('123456'),
        ]);

        $this->grantPermissions($doctor, [
            'tasks.view',
            'lectures.create',
            'quizzes.create',
        ], canManageGrades: true);

        $login = $this->postJson('/api/staff-portal/auth/login', [
            'university_email' => 'doctor@tolab.edu',
            'password' => '123456',
            'device_name' => 'phpunit-doctor',
        ]);

        $login->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.token', $login->json('data.access_token'))
            ->assertJsonPath('data.role', 'doctor')
            ->assertJsonPath('data.user.name', 'Dr. Ahmed Hassan')
            ->assertJsonPath('data.user.role', 'doctor')
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'token',
                    'access_token',
                    'refresh_token',
                    'role',
                    'user',
                    'tokens' => ['access_token', 'refresh_token'],
                ],
            ]);

        $dashboard = $this
            ->withHeader('Authorization', 'Bearer '.$login->json('data.tokens.access_token'))
            ->getJson('/api/staff/dashboard');

        $dashboard->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.header.user.role', 'DOCTOR')
            ->assertJsonPath('data.header.user.name', 'Dr. Ahmed Hassan');
    }

    public function test_assistant_can_login_and_access_staff_dashboard(): void
    {
        $assistant = User::factory()->teachingAssistant()->create([
            'full_name' => 'Mona Assistant',
            'university_email' => 'assistant@tolab.edu',
            'password_hash' => Hash::make('123456'),
        ]);

        $this->grantPermissions($assistant, [
            'tasks.view',
            'community.post',
        ], canManageGrades: false);

        $login = $this->postJson('/api/staff-portal/auth/login', [
            'university_email' => 'assistant@tolab.edu',
            'password' => '123456',
            'device_name' => 'phpunit-assistant',
        ]);

        $login->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.token', $login->json('data.access_token'))
            ->assertJsonPath('data.role', 'assistant')
            ->assertJsonPath('data.user.name', 'Mona Assistant')
            ->assertJsonPath('data.user.role', 'assistant')
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'token',
                    'access_token',
                    'refresh_token',
                    'role',
                    'user',
                    'tokens' => ['access_token', 'refresh_token'],
                ],
            ]);

        $dashboard = $this
            ->withHeader('Authorization', 'Bearer '.$login->json('data.tokens.access_token'))
            ->getJson('/api/staff/dashboard');

        $dashboard->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.header.user.role', 'ASSISTANT')
            ->assertJsonPath('data.header.user.name', 'Mona Assistant');
    }

    public function test_doctor_and_assistant_can_refresh_tokens(): void
    {
        $doctor = User::factory()->doctor()->create([
            'full_name' => 'Dr. Refresh',
            'university_email' => 'doctor.refresh@tolab.edu',
            'password_hash' => Hash::make('123456'),
        ]);

        $assistant = User::factory()->teachingAssistant()->create([
            'full_name' => 'Assistant Refresh',
            'university_email' => 'assistant.refresh@tolab.edu',
            'password_hash' => Hash::make('123456'),
        ]);

        $this->grantPermissions($doctor, ['tasks.view'], canManageGrades: true);
        $this->grantPermissions($assistant, ['tasks.view'], canManageGrades: false);

        $doctorLogin = $this->postJson('/api/staff-portal/auth/login', [
            'university_email' => 'doctor.refresh@tolab.edu',
            'password' => '123456',
            'device_name' => 'phpunit-doctor-refresh',
        ]);

        $doctorLogin->assertOk()
            ->assertJsonPath('success', true);

        $assistantLogin = $this->postJson('/api/staff-portal/auth/login', [
            'university_email' => 'assistant.refresh@tolab.edu',
            'password' => '123456',
            'device_name' => 'phpunit-assistant-refresh',
        ]);

        $assistantLogin->assertOk()
            ->assertJsonPath('success', true);

        $doctorRefresh = $this->postJson('/api/staff-portal/auth/refresh', [
            'refresh_token' => $doctorLogin->json('data.tokens.refresh_token'),
            'device_name' => 'phpunit-doctor-refresh',
        ]);

        $doctorRefresh->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.token', $doctorRefresh->json('data.access_token'))
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'token',
                    'access_token',
                    'refresh_token',
                ],
            ]);

        $assistantRefresh = $this->postJson('/api/staff-portal/auth/refresh', [
            'refresh_token' => $assistantLogin->json('data.tokens.refresh_token'),
            'device_name' => 'phpunit-assistant-refresh',
        ]);

        $assistantRefresh->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.token', $assistantRefresh->json('data.access_token'))
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'token',
                    'access_token',
                    'refresh_token',
                ],
            ]);
    }

    public function test_staff_dashboard_returns_unauthorized_without_token(): void
    {
        $this->getJson('/api/staff/dashboard')
            ->assertUnauthorized()
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Session expired, please login again.');
    }

    private function grantPermissions(
        User $user,
        array $permissions,
        bool $canManageGrades = false,
    ): void {
        $permissionIds = collect($permissions)
            ->map(fn (string $name) => Permission::query()->firstOrCreate(
                ['name' => $name],
                [
                    'group_name' => 'testing',
                    'label' => $name,
                ]
            )->id)
            ->all();

        $user->permissions()->sync($permissionIds);

        StaffPermission::query()->updateOrCreate(
            ['user_id' => $user->id],
            [
                'can_upload_content' => true,
                'can_manage_grades' => $canManageGrades,
                'can_manage_schedule' => true,
                'can_moderate_group' => true,
            ],
        );
    }
}
