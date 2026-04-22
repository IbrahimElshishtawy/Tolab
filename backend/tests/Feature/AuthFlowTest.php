<?php

namespace Tests\Feature;

use App\Core\Enums\UserRole;
use App\Modules\UserManagement\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_login_and_refresh_tokens(): void
    {
        $user = User::factory()->create([
            'role' => UserRole::ADMIN,
            'email' => 'admin@example.com',
            'password_hash' => '123456',
        ]);

        $login = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => '123456',
            'device_name' => 'phpunit',
        ]);

        $login->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.token', $login->json('data.access_token'))
            ->assertJsonPath('data.user.name', $user->full_name)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'token',
                    'access_token',
                    'refresh_token',
                    'accessToken',
                    'refreshToken',
                    'user' => ['id', 'name', 'role', 'username', 'email'],
                ],
            ]);

        $refresh = $this->postJson('/api/auth/refresh', [
            'refresh_token' => $login->json('data.refreshToken'),
            'device_name' => 'phpunit',
        ]);

        $refresh->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'accessToken',
                    'refreshToken',
                ],
            ]);
    }
}
