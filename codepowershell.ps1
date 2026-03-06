# # ===============================
# # Flutter Redux Project Structure
# # ===============================

# $paths = @(
# # root
# "lib",
# "assets/images",
# "assets/icons",
# "assets/fonts",

# # app
# "lib/app",
# "lib/app/app.dart",
# "lib/app/store.dart",
# "lib/app/router.dart",
# "lib/app/reducers.dart",
# "lib/app/middlewares.dart",

# # core
# "lib/core/network/interceptors",
# "lib/core/storage/secure_storage",
# "lib/core/storage/shared_prefs",
# "lib/core/localization",
# "lib/core/errors",
# "lib/core/theme",
# "lib/core/utils",

# "lib/core/network/api_client.dart",
# "lib/core/network/endpoints.dart",
# "lib/core/localization/ar.json",
# "lib/core/localization/en.json",
# "lib/core/localization/localization_manager.dart",
# "lib/core/errors/exceptions.dart",
# "lib/core/errors/failures.dart",
# "lib/core/theme/app_theme.dart",
# "lib/core/utils/validators.dart",
# "lib/core/utils/constants.dart",
# "lib/core/utils/helpers.dart",

# # redux
# "lib/redux/state",
# "lib/redux/actions",
# "lib/redux/reducers",
# "lib/redux/middlewares",
# "lib/redux/selectors",

# "lib/redux/state/app_state.dart",
# "lib/redux/state/auth_state.dart",
# "lib/redux/state/home_state.dart",
# "lib/redux/state/subjects_state.dart",
# "lib/redux/state/notifications_state.dart",
# "lib/redux/state/settings_state.dart",

# "lib/redux/actions/auth_actions.dart",
# "lib/redux/actions/home_actions.dart",
# "lib/redux/actions/subjects_actions.dart",
# "lib/redux/actions/notifications_actions.dart",
# "lib/redux/actions/settings_actions.dart",

# "lib/redux/reducers/auth_reducer.dart",
# "lib/redux/reducers/home_reducer.dart",
# "lib/redux/reducers/subjects_reducer.dart",
# "lib/redux/reducers/notifications_reducer.dart",
# "lib/redux/reducers/settings_reducer.dart",
# "lib/redux/reducers/root_reducer.dart",

# "lib/redux/middlewares/auth_middleware.dart",
# "lib/redux/middlewares/subjects_middleware.dart",
# "lib/redux/middlewares/notifications_middleware.dart",
# "lib/redux/middlewares/settings_middleware.dart",

# "lib/redux/selectors/auth_selectors.dart",
# "lib/redux/selectors/subjects_selectors.dart",
# "lib/redux/selectors/notifications_selectors.dart",

# # features/auth
# "lib/features/auth/presentation/screens",
# "lib/features/auth/presentation/widgets",
# "lib/features/auth/data/models",
# "lib/features/auth/data/datasources",
# "lib/features/auth/data/repositories",
# "lib/features/auth/domain/entities",
# "lib/features/auth/domain/repositories",

# "lib/features/auth/presentation/screens/login_screen.dart",
# "lib/features/auth/presentation/screens/forget_password_screen.dart",
# "lib/features/auth/presentation/screens/otp_screen.dart",
# "lib/features/auth/presentation/screens/reset_password_screen.dart",
# "lib/features/auth/data/datasources/auth_remote_ds.dart",
# "lib/features/auth/data/datasources/auth_local_ds.dart",

# # features/home
# "lib/features/home/presentation/screens",
# "lib/features/home/presentation/widgets",
# "lib/features/home/data/repositories",
# "lib/features/home/domain/entities",
# "lib/features/home/presentation/screens/home_screen.dart",

# # features/subjects
# "lib/features/subjects/presentation/screens",
# "lib/features/subjects/presentation/widgets",
# "lib/features/subjects/data/models",
# "lib/features/subjects/data/datasources",
# "lib/features/subjects/data/repositories",
# "lib/features/subjects/domain/entities",
# "lib/features/subjects/domain/repositories",

# "lib/features/subjects/presentation/screens/subjects_screen.dart",
# "lib/features/subjects/presentation/screens/subject_details_screen.dart",
# "lib/features/subjects/presentation/screens/lectures_screen.dart",
# "lib/features/subjects/presentation/screens/sections_screen.dart",
# "lib/features/subjects/presentation/screens/quizzes_screen.dart",
# "lib/features/subjects/presentation/screens/tasks_screen.dart",
# "lib/features/subjects/presentation/screens/summaries_screen.dart",

# # features/notifications
# "lib/features/notifications/presentation/screens",
# "lib/features/notifications/presentation/widgets",
# "lib/features/notifications/data/datasources",
# "lib/features/notifications/data/repositories",
# "lib/features/notifications/domain/entities",
# "lib/features/notifications/presentation/screens/notifications_screen.dart",

# # features/community
# "lib/features/community/presentation/screens",
# "lib/features/community/presentation/widgets",
# "lib/features/community/data/repositories",
# "lib/features/community/domain/entities",
# "lib/features/community/presentation/screens/community_screen.dart",

# # features/more
# "lib/features/more/presentation/screens",
# "lib/features/more/presentation/widgets",
# "lib/features/more/data/repositories",
# "lib/features/more/domain/entities",

# "lib/features/more/presentation/screens/profile_screen.dart",
# "lib/features/more/presentation/screens/academic_results_screen.dart",
# "lib/features/more/presentation/screens/language_screen.dart",
# "lib/features/more/presentation/screens/notification_settings_screen.dart",
# "lib/features/more/presentation/screens/about_screen.dart"
# )

# foreach ($path in $paths) {
#     if ($path.Contains(".")) {
#         New-Item -ItemType File -Path $path -Force | Out-Null
#     } else {
#         New-Item -ItemType Directory -Path $path -Force | Out-Null
#     }
# }

# Write-Host "✅ Flutter Redux project structure created successfully!"
