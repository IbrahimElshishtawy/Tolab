    param(
    [string]$ProjectRoot = "."
)

# Helper to create folders
function Ensure-Folder {
    param ([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Ensure-File {
    param ([string]$Path)
    if (-not (Test-Path $Path)) {
        Ensure-Folder (Split-Path $Path -Parent)
        New-Item -ItemType File -Path $Path | Out-Null
    }
}

# ========== FOLDERS ==========

$folders = @(
    "lib",
    "lib/app",
    "lib/app/routes",
    "lib/app/di",
    "lib/app/config",

    "lib/core",
    "lib/core/constants",
    "lib/core/errors",
    "lib/core/utils",
    "lib/core/theme",
    "lib/core/widgets",
    "lib/core/network",
    "lib/core/storage",
    "lib/core/storage/local_db",
    "lib/core/storage/cache",
    "lib/core/platform",

    "lib/l10n",

    "lib/features",
    "lib/features/auth",
    "lib/features/auth/data",
    "lib/features/auth/data/datasources",
    "lib/features/auth/data/models",
    "lib/features/auth/data/repositories",
    "lib/features/auth/domain",
    "lib/features/auth/domain/entities",
    "lib/features/auth/domain/repositories",
    "lib/features/auth/domain/usecases",
    "lib/features/auth/presentation",
    "lib/features/auth/presentation/bloc",
    "lib/features/auth/presentation/pages",
    "lib/features/auth/presentation/widgets",

    "lib/features/students",
    "lib/features/students/data",
    "lib/features/students/data/datasources",
    "lib/features/students/data/models",
    "lib/features/students/data/repositories",
    "lib/features/students/domain",
    "lib/features/students/domain/entities",
    "lib/features/students/domain/repositories",
    "lib/features/students/domain/usecases",
    "lib/features/students/presentation",
    "lib/features/students/presentation/bloc",
    "lib/features/students/presentation/pages",
    "lib/features/students/presentation/widgets",

    "lib/features/groups",
    "lib/features/groups/data",
    "lib/features/groups/data/datasources",
    "lib/features/groups/data/models",
    "lib/features/groups/data/repositories",
    "lib/features/groups/domain",
    "lib/features/groups/domain/entities",
    "lib/features/groups/domain/repositories",
    "lib/features/groups/domain/usecases",
    "lib/features/groups/presentation",
    "lib/features/groups/presentation/bloc",
    "lib/features/groups/presentation/pages",
    "lib/features/groups/presentation/widgets",

    "lib/features/attendance",
    "lib/features/attendance/data",
    "lib/features/attendance/data/datasources",
    "lib/features/attendance/data/models",
    "lib/features/attendance/data/repositories",
    "lib/features/attendance/domain",
    "lib/features/attendance/domain/entities",
    "lib/features/attendance/domain/repositories",
    "lib/features/attendance/domain/usecases",
    "lib/features/attendance/presentation",
    "lib/features/attendance/presentation/bloc",
    "lib/features/attendance/presentation/pages",
    "lib/features/attendance/presentation/widgets",

    "lib/features/content",
    "lib/features/content/data",
    "lib/features/content/data/datasources",
    "lib/features/content/data/models",
    "lib/features/content/data/repositories",
    "lib/features/content/domain",
    "lib/features/content/domain/entities",
    "lib/features/content/domain/repositories",
    "lib/features/content/domain/usecases",
    "lib/features/content/presentation",
    "lib/features/content/presentation/bloc",
    "lib/features/content/presentation/pages",
    "lib/features/content/presentation/widgets",

    "lib/features/homework",
    "lib/features/homework/data",
    "lib/features/homework/data/datasources",
    "lib/features/homework/data/models",
    "lib/features/homework/data/repositories",
    "lib/features/homework/domain",
    "lib/features/homework/domain/entities",
    "lib/features/homework/domain/repositories",
    "lib/features/homework/domain/usecases",
    "lib/features/homework/presentation",
    "lib/features/homework/presentation/bloc",
    "lib/features/homework/presentation/pages",
    "lib/features/homework/presentation/widgets",

    "lib/features/exams",
    "lib/features/exams/data",
    "lib/features/exams/data/datasources",
    "lib/features/exams/data/models",
    "lib/features/exams/data/repositories",
    "lib/features/exams/domain",
    "lib/features/exams/domain/entities",
    "lib/features/exams/domain/repositories",
    "lib/features/exams/domain/usecases",
    "lib/features/exams/presentation",
    "lib/features/exams/presentation/bloc",
    "lib/features/exams/presentation/pages",
    "lib/features/exams/presentation/widgets",

    "lib/features/messaging",
    "lib/features/messaging/data",
    "lib/features/messaging/data/datasources",
    "lib/features/messaging/data/models",
    "lib/features/messaging/data/repositories",
    "lib/features/messaging/domain",
    "lib/features/messaging/domain/entities",
    "lib/features/messaging/domain/repositories",
    "lib/features/messaging/domain/usecases",
    "lib/features/messaging/presentation",
    "lib/features/messaging/presentation/bloc",
    "lib/features/messaging/presentation/pages",
    "lib/features/messaging/presentation/widgets",

    "lib/features/notifications",
    "lib/features/notifications/data",
    "lib/features/notifications/data/datasources",
    "lib/features/notifications/data/models",
    "lib/features/notifications/data/repositories",
    "lib/features/notifications/domain",
    "lib/features/notifications/domain/entities",
    "lib/features/notifications/domain/repositories",
    "lib/features/notifications/domain/usecases",
    "lib/features/notifications/presentation",
    "lib/features/notifications/presentation/bloc",
    "lib/features/notifications/presentation/pages",
    "lib/features/notifications/presentation/widgets",

    "lib/features/parents",
    "lib/features/parents/data",
    "lib/features/parents/data/datasources",
    "lib/features/parents/data/models",
    "lib/features/parents/data/repositories",
    "lib/features/parents/domain",
    "lib/features/parents/domain/entities",
    "lib/features/parents/domain/repositories",
    "lib/features/parents/domain/usecases",
    "lib/features/parents/presentation",
    "lib/features/parents/presentation/bloc",
    "lib/features/parents/presentation/pages"
)

foreach ($folder in $folders) {
    $fullPath = Join-Path $ProjectRoot $folder
    Ensure-Folder -Path $fullPath
}

# ========== FILES ==========

$files = @(
    # root
    "lib/main.dart",

    # app
    "lib/app/app.dart",
    "lib/app/app_bloc_observer.dart",
    "lib/app/routes/app_router.dart",
    "lib/app/routes/route_names.dart",
    "lib/app/di/service_locator.dart",
    "lib/app/config/env.dart",
    "lib/app/config/app_config.dart",

    # core/constants
    "lib/core/constants/api_endpoints.dart",
    "lib/core/constants/app_keys.dart",
    "lib/core/constants/app_strings.dart",
    "lib/core/constants/app_assets.dart",

    # core/errors
    "lib/core/errors/exceptions.dart",
    "lib/core/errors/failures.dart",

    # core/utils
    "lib/core/utils/validators.dart",
    "lib/core/utils/formatters.dart",
    "lib/core/utils/logger.dart",
    "lib/core/utils/date_time_utils.dart",

    # core/theme
    "lib/core/theme/app_theme.dart",
    "lib/core/theme/app_colors.dart",
    "lib/core/theme/app_text_styles.dart",

    # core/widgets
    "lib/core/widgets/app_button.dart",
    "lib/core/widgets/app_text_field.dart",
    "lib/core/widgets/loading_indicator.dart",
    "lib/core/widgets/empty_state.dart",
    "lib/core/widgets/error_state.dart",

    # core/network
    "lib/core/network/api_client.dart",
    "lib/core/network/connectivity_service.dart",
    "lib/core/network/network_info.dart",

    # core/storage/local_db
    "lib/core/storage/local_db/hive_manager.dart",
    "lib/core/storage/local_db/local_storage_keys.dart",

    # core/storage/cache
    "lib/core/storage/cache/cache_policy.dart",

    # core/platform
    "lib/core/platform/device_info.dart",

    # auth feature
    "lib/features/auth/data/datasources/auth_remote_datasource.dart",
    "lib/features/auth/data/datasources/auth_local_datasource.dart",
    "lib/features/auth/data/models/login_request_model.dart",
    "lib/features/auth/data/models/user_model.dart",
    "lib/features/auth/data/repositories/auth_repository_impl.dart",
    "lib/features/auth/domain/entities/user.dart",
    "lib/features/auth/domain/repositories/auth_repository.dart",
    "lib/features/auth/domain/usecases/login_usecase.dart",
    "lib/features/auth/domain/usecases/logout_usecase.dart",
    "lib/features/auth/domain/usecases/get_current_user_usecase.dart",
    "lib/features/auth/presentation/bloc/auth_bloc.dart",
    "lib/features/auth/presentation/bloc/auth_event.dart",
    "lib/features/auth/presentation/bloc/auth_state.dart",
    "lib/features/auth/presentation/pages/login_page.dart",
    "lib/features/auth/presentation/pages/splash_page.dart",
    "lib/features/auth/presentation/widgets/login_form.dart",

    # students feature
    "lib/features/students/data/datasources/students_remote_datasource.dart",
    "lib/features/students/data/datasources/students_local_datasource.dart",
    "lib/features/students/data/models/student_model.dart",
    "lib/features/students/data/repositories/students_repository_impl.dart",
    "lib/features/students/domain/entities/student.dart",
    "lib/features/students/domain/repositories/students_repository.dart",
    "lib/features/students/domain/usecases/get_students_for_group.dart",
    "lib/features/students/domain/usecases/get_student_profile.dart",
    "lib/features/students/presentation/bloc/students_bloc.dart",
    "lib/features/students/presentation/bloc/students_event.dart",
    "lib/features/students/presentation/bloc/students_state.dart",
    "lib/features/students/presentation/pages/students_list_page.dart",
    "lib/features/students/presentation/pages/student_profile_page.dart",
    "lib/features/students/presentation/widgets/student_card.dart",

    # groups feature
    "lib/features/groups/data/datasources/groups_remote_datasource.dart",
    "lib/features/groups/data/datasources/groups_local_datasource.dart",
    "lib/features/groups/data/models/group_model.dart",
    "lib/features/groups/data/repositories/groups_repository_impl.dart",
    "lib/features/groups/domain/entities/group.dart",
    "lib/features/groups/domain/repositories/groups_repository.dart",
    "lib/features/groups/domain/usecases/get_groups_for_teacher.dart",
    "lib/features/groups/domain/usecases/create_group.dart",
    "lib/features/groups/presentation/bloc/groups_bloc.dart",
    "lib/features/groups/presentation/bloc/groups_event.dart",
    "lib/features/groups/presentation/bloc/groups_state.dart",
    "lib/features/groups/presentation/pages/groups_page.dart",
    "lib/features/groups/presentation/pages/group_details_page.dart",
    "lib/features/groups/presentation/widgets/group_item.dart",

    # attendance feature
    "lib/features/attendance/data/datasources/attendance_remote_datasource.dart",
    "lib/features/attendance/data/datasources/attendance_local_datasource.dart",
    "lib/features/attendance/data/models/attendance_record_model.dart",
    "lib/features/attendance/data/models/session_model.dart",
    "lib/features/attendance/data/repositories/attendance_repository_impl.dart",
    "lib/features/attendance/domain/entities/attendance_record.dart",
    "lib/features/attendance/domain/entities/session.dart",
    "lib/features/attendance/domain/repositories/attendance_repository.dart",
    "lib/features/attendance/domain/usecases/mark_attendance_usecase.dart",
    "lib/features/attendance/domain/usecases/get_attendance_for_student.dart",
    "lib/features/attendance/presentation/bloc/attendance_bloc.dart",
    "lib/features/attendance/presentation/bloc/attendance_event.dart",
    "lib/features/attendance/presentation/bloc/attendance_state.dart",
    "lib/features/attendance/presentation/pages/attendance_scan_page.dart",
    "lib/features/attendance/presentation/pages/attendance_list_page.dart",
    "lib/features/attendance/presentation/widgets/attendance_row.dart",

    # content feature
    "lib/features/content/data/datasources/lessons_remote_datasource.dart",
    "lib/features/content/data/datasources/lessons_local_datasource.dart",
    "lib/features/content/data/models/lesson_model.dart",
    "lib/features/content/data/models/lesson_content_model.dart",
    "lib/features/content/data/repositories/lessons_repository_impl.dart",
    "lib/features/content/domain/entities/lesson.dart",
    "lib/features/content/domain/entities/lesson_content.dart",
    "lib/features/content/domain/repositories/lessons_repository.dart",
    "lib/features/content/domain/usecases/get_lessons_for_group.dart",
    "lib/features/content/domain/usecases/get_lesson_content.dart",
    "lib/features/content/presentation/bloc/lessons_bloc.dart",
    "lib/features/content/presentation/bloc/lessons_event.dart",
    "lib/features/content/presentation/bloc/lessons_state.dart",
    "lib/features/content/presentation/pages/lessons_page.dart",
    "lib/features/content/presentation/pages/lesson_details_page.dart",
    "lib/features/content/presentation/widgets/lesson_card.dart",

    # homework feature
    "lib/features/homework/data/datasources/homework_remote_datasource.dart",
    "lib/features/homework/data/datasources/homework_local_datasource.dart",
    "lib/features/homework/data/models/homework_model.dart",
    "lib/features/homework/data/models/homework_submission_model.dart",
    "lib/features/homework/data/repositories/homework_repository_impl.dart",
    "lib/features/homework/domain/entities/homework.dart",
    "lib/features/homework/domain/entities/homework_submission.dart",
    "lib/features/homework/domain/repositories/homework_repository.dart",
    "lib/features/homework/domain/usecases/create_homework_usecase.dart",
    "lib/features/homework/domain/usecases/submit_homework_usecase.dart",
    "lib/features/homework/domain/usecases/get_homeworks_for_student.dart",
    "lib/features/homework/presentation/bloc/homework_bloc.dart",
    "lib/features/homework/presentation/bloc/homework_event.dart",
    "lib/features/homework/presentation/bloc/homework_state.dart",
    "lib/features/homework/presentation/pages/homework_list_page.dart",
    "lib/features/homework/presentation/pages/homework_details_page.dart",
    "lib/features/homework/presentation/pages/homework_submission_page.dart",
    "lib/features/homework/presentation/widgets/homework_card.dart",

    # exams feature
    "lib/features/exams/data/datasources/exams_remote_datasource.dart",
    "lib/features/exams/data/datasources/exams_local_datasource.dart",
    "lib/features/exams/data/models/exam_model.dart",
    "lib/features/exams/data/models/question_model.dart",
    "lib/features/exams/data/models/student_answer_model.dart",
    "lib/features/exams/data/repositories/exams_repository_impl.dart",
    "lib/features/exams/domain/entities/exam.dart",
    "lib/features/exams/domain/entities/question.dart",
    "lib/features/exams/domain/entities/student_answer.dart",
    "lib/features/exams/domain/repositories/exams_repository.dart",
    "lib/features/exams/domain/usecases/create_exam_usecase.dart",
    "lib/features/exams/domain/usecases/start_exam_usecase.dart",
    "lib/features/exams/domain/usecases/submit_exam_answers_usecase.dart",
    "lib/features/exams/presentation/bloc/exams_bloc.dart",
    "lib/features/exams/presentation/bloc/exams_event.dart",
    "lib/features/exams/presentation/bloc/exams_state.dart",
    "lib/features/exams/presentation/pages/exams_list_page.dart",
    "lib/features/exams/presentation/pages/exam_details_page.dart",
    "lib/features/exams/presentation/pages/exam_take_page.dart",
    "lib/features/exams/presentation/widgets/question_widget.dart",

    # messaging feature
    "lib/features/messaging/data/datasources/messaging_remote_datasource.dart",
    "lib/features/messaging/data/datasources/messaging_local_datasource.dart",
    "lib/features/messaging/data/models/question_thread_model.dart",
    "lib/features/messaging/data/models/message_model.dart",
    "lib/features/messaging/data/repositories/messaging_repository_impl.dart",
    "lib/features/messaging/domain/entities/question_thread.dart",
    "lib/features/messaging/domain/entities/message.dart",
    "lib/features/messaging/domain/repositories/messaging_repository.dart",
    "lib/features/messaging/domain/usecases/send_question_usecase.dart",
    "lib/features/messaging/domain/usecases/reply_to_question_usecase.dart",
    "lib/features/messaging/domain/usecases/get_threads_for_student.dart",
    "lib/features/messaging/presentation/bloc/messaging_bloc.dart",
    "lib/features/messaging/presentation/bloc/messaging_event.dart",
    "lib/features/messaging/presentation/bloc/messaging_state.dart",
    "lib/features/messaging/presentation/pages/questions_page.dart",
    "lib/features/messaging/presentation/pages/question_thread_page.dart",
    "lib/features/messaging/presentation/widgets/question_thread_widget.dart",

    # notifications feature
    "lib/features/notifications/data/datasources/notifications_remote_datasource.dart",
    "lib/features/notifications/data/datasources/notifications_local_datasource.dart",
    "lib/features/notifications/data/models/notification_model.dart",
    "lib/features/notifications/data/repositories/notifications_repository_impl.dart",
    "lib/features/notifications/domain/entities/app_notification.dart",
    "lib/features/notifications/domain/repositories/notifications_repository.dart",
    "lib/features/notifications/domain/usecases/get_notifications_usecase.dart",
    "lib/features/notifications/domain/usecases/mark_notification_read_usecase.dart",
    "lib/features/notifications/presentation/bloc/notifications_bloc.dart",
    "lib/features/notifications/presentation/bloc/notifications_event.dart",
    "lib/features/notifications/presentation/bloc/notifications_state.dart",
    "lib/features/notifications/presentation/pages/notifications_page.dart",
    "lib/features/notifications/presentation/widgets/notification_tile.dart",

    # parents feature
    "lib/features/parents/data/datasources/parents_remote_datasource.dart",
    "lib/features/parents/data/datasources/parents_local_datasource.dart",
    "lib/features/parents/data/models/parent_overview_model.dart",
    "lib/features/parents/data/repositories/parents_repository_impl.dart",
    "lib/features/parents/domain/entities/parent_overview.dart",
    "lib/features/parents/domain/repositories/parents_repository.dart",
    "lib/features/parents/domain/usecases/get_parent_dashboard_usecase.dart",
    "lib/features/parents/presentation/bloc/parents_bloc.dart",
    "lib/features/parents/presentation/bloc/parents_event.dart",
    "lib/features/parents/presentation/bloc/parents_state.dart",
    "lib/features/parents/presentation/pages/parent_dashboard_page.dart"
)

foreach ($file in $files) {
    $fullPath = Join-Path $ProjectRoot $file
    Ensure-File -Path $fullPath
}

Write-Host "Project Flutter folder & file structure created successfully."
