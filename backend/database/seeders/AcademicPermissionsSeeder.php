<?php

namespace Database\Seeders;

use App\Modules\StaffPortal\Models\Permission;
use App\Modules\StaffPortal\Models\Role;
use Illuminate\Database\Seeder;

class AcademicPermissionsSeeder extends Seeder
{
    public function run(): void
    {
        $permissions = [
            'staff.view', 'staff.create', 'staff.update', 'staff.activate', 'staff.deactivate',
            'permissions.manage', 'departments.view', 'departments.create', 'departments.update',
            'subjects.view', 'subjects.create', 'subjects.update', 'sections.view', 'sections.create', 'sections.update',
            'lectures.view', 'lectures.create', 'lectures.update', 'lectures.delete',
            'section_content.view', 'section_content.create', 'section_content.update', 'section_content.delete',
            'quizzes.view', 'quizzes.create', 'quizzes.update', 'quizzes.delete',
            'tasks.view', 'tasks.create', 'tasks.update', 'tasks.delete',
            'results.view', 'students.view', 'grades.manage',
            'schedule.view', 'schedule.manage',
            'notifications.view', 'notifications.send',
            'community.view', 'community.post', 'community.comment',
            'uploads.view', 'uploads.create', 'uploads.delete',
        ];

        foreach ($permissions as $permission) {
            Permission::query()->updateOrCreate(
                ['name' => $permission],
                [
                    'group_name' => str($permission)->before('.')->toString(),
                    'label' => str($permission)->replace('.', ' ')->headline()->toString(),
                ],
            );
        }

        $adminRole = Role::query()->updateOrCreate(['name' => 'admin'], ['label' => 'Admin']);
        $doctorRole = Role::query()->updateOrCreate(['name' => 'doctor'], ['label' => 'Doctor']);
        $assistantRole = Role::query()->updateOrCreate(['name' => 'assistant'], ['label' => 'Assistant']);

        $adminRole->permissions()->sync(Permission::query()->pluck('id'));
        $doctorRole->permissions()->sync(Permission::query()->whereIn('name', [
            'staff.view', 'subjects.view', 'lectures.view', 'lectures.create', 'lectures.update', 'lectures.delete',
            'quizzes.view', 'quizzes.create', 'quizzes.update', 'tasks.view', 'tasks.create', 'tasks.update',
            'results.view', 'students.view', 'grades.manage', 'community.view', 'community.post',
            'schedule.view', 'notifications.view', 'uploads.view', 'uploads.create',
        ])->pluck('id'));
        $assistantRole->permissions()->sync(Permission::query()->whereIn('name', [
            'subjects.view', 'section_content.view', 'section_content.create', 'section_content.update',
            'quizzes.view', 'quizzes.create', 'quizzes.update', 'tasks.view', 'tasks.create', 'tasks.update',
            'results.view', 'students.view', 'grades.manage', 'community.view', 'community.post',
            'schedule.view', 'notifications.view', 'uploads.view', 'uploads.create',
        ])->pluck('id'));
    }
}
