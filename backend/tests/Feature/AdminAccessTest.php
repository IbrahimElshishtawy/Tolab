<?php

namespace Tests\Feature;

use App\Core\Enums\UserRole;
use App\Modules\UserManagement\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminAccessTest extends TestCase
{
    use RefreshDatabase;

    public function test_student_cannot_access_admin_routes(): void
    {
        $student = User::factory()->create([
            'role' => UserRole::STUDENT,
        ]);

        Sanctum::actingAs($student);

        $response = $this->postJson('/api/admin/departments', [
            'name' => 'Engineering',
        ]);

        $response->assertForbidden()
            ->assertJsonPath('success', false);
    }
}
