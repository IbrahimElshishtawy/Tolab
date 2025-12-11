# # ================================
# # Auto-Generate Admin Panel Modules
# # ================================
# Write-Host "`n=== Generating missing admin modules ===" -ForegroundColor Cyan

# $base = "src"

# function New-FileSafe($path, $content) {
#     if (!(Test-Path $path)) {
#         New-Item -Path $path -ItemType File -Force | Out-Null
#         Set-Content -Path $path -Value $content -Encoding UTF8
#         Write-Host "Created file: $path" -ForegroundColor Green
#     } else {
#         Write-Host "Exists: $path" -ForegroundColor Yellow
#     }
# }

# function New-FolderSafe($path) {
#     if (!(Test-Path $path)) {
#         New-Item -Path $path -ItemType Directory -Force | Out-Null
#         Write-Host "Created folder: $path" -ForegroundColor Green
#     }
# }

# # ===============================
# # MODULES TO GENERATE
# # ===============================
# $modules = @{
#     "state/doctors" = @(
#         "doctors_state.dart",
#         "doctors_actions.dart",
#         "doctors_reducer.dart",
#         "doctors_middleware.dart",
#         "doctors_selectors.dart"
#     );

#     "state/assistants" = @(
#         "assistants_state.dart",
#         "assistants_actions.dart",
#         "assistants_reducer.dart",
#         "assistants_middleware.dart",
#         "assistants_selectors.dart"
#     );

#     "state/academic_structure" = @(
#         "structure_state.dart",
#         "structure_actions.dart",
#         "structure_reducer.dart",
#         "structure_middleware.dart",
#         "structure_selectors.dart"
#     );

#     "state/permissions" = @(
#         "permissions_state.dart",
#         "permissions_actions.dart",
#         "permissions_reducer.dart",
#         "permissions_selectors.dart"
#     );

#     "presentation/features/doctors_management/pages" = @(
#         "doctors_page.dart"
#     );

#     "presentation/features/doctors_management/widgets" = @(
#         "doctor_card.dart"
#     );

#     "presentation/features/assistants_management/pages" = @(
#         "assistants_page.dart"
#     );

#     "presentation/features/assistants_management/widgets" = @(
#         "assistant_card.dart"
#     );

#     "presentation/features/academic_structure/pages" = @(
#         "academic_structure_page.dart"
#     );

#     "presentation/features/academic_structure/widgets" = @(
#         "structure_card.dart"
#     );
# }

# # =====================================
# # DEFAULT FILE CONTENT GENERATORS
# # =====================================

# function Get-StateContent($name) {
# @"
# class ${name}State {
#   final bool isLoading;
#   final dynamic data;
#   final String? error;

#   ${name}State({
#     required this.isLoading,
#     required this.data,
#     this.error,
#   });

#   factory ${name}State.initial() =>
#       ${name}State(isLoading: false, data: null);

#   ${name}State copyWith({bool? isLoading, dynamic data, String? error}) {
#     return ${name}State(
#       isLoading: isLoading ?? this.isLoading,
#       data: data ?? this.data,
#       error: error,
#     );
#   }
# }
# "@
# }

# function Get-ActionsContent($name) {
# @"
# class Load${name}Action {}

# class ${name}LoadedAction {
#   final dynamic data;
#   ${name}LoadedAction(this.data);
# }

# class ${name}FailedAction {
#   final String error;
#   ${name}FailedAction(this.error);
# }
# "@
# }

# function Get-ReducerContent($name) {
# @"
# import '${name}_actions.dart';
# import '${name}_state.dart';

# ${name}State ${name}Reducer(${name}State state, dynamic action) {
#   if (action is Load${name}Action) {
#     return state.copyWith(isLoading: true, error: null);
#   }

#   if (action is ${name}LoadedAction) {
#     return state.copyWith(isLoading: false, data: action.data);
#   }

#   if (action is ${name}FailedAction) {
#     return state.copyWith(isLoading: false, error: action.error);
#   }

#   return state;
# }
# "@
# }

# function Get-MiddlewareContent($name) {
# @"
# import 'package:redux/redux.dart';
# import '../app_state.dart';
# import '${name}_actions.dart';
# import '../../../fake_data/data.dart';

# List<Middleware<AppState>> create${name}Middleware() {
#   return [
#     TypedMiddleware<AppState, Load${name}Action>(_load$name()),
#   ];
# }

# Middleware<AppState> _load$name() {
#   return (Store<AppState> store, action, NextDispatcher next) async {
#     next(action);
#     try {
#       store.dispatch(${name}LoadedAction(fakeData));
#     } catch (e) {
#       store.dispatch(${name}FailedAction(e.toString()));
#     }
#   };
# }
# "@
# }

# function Get-SelectorsContent($name) {
# @"
# import '../app_state.dart';
# import '${name}_state.dart';

# ${name}State select${name}State(AppState state) => state.${name};
# "@
# }

# function Get-PageContent($title) {
# @"
# import 'package:flutter/material.dart';

# class ${title}Page extends StatelessWidget {
#   const ${title}Page({super.key});

#   @override
#   Widget build(BuildContext context) {
#     return Scaffold(
#       backgroundColor: const Color(0xFF0F172A),
#       appBar: AppBar(
#         backgroundColor: const Color(0xFF1E293B),
#         title: const Text('$title', style: TextStyle(color: Colors.white)),
#       ),
#       body: const Center(
#         child: Text('$title Page', style: TextStyle(color: Colors.white)),
#       ),
#     );
#   }
# }
# "@
# }

# # =====================================
# # GENERATE FILES
# # =====================================
# foreach ($module in $modules.Keys) {

#     $path = "$base/$module"
#     New-FolderSafe $path

#     foreach ($file in $modules[$module]) {

#         $full = "$path/$file"

#         # detect type
#         if ($file -match "_state") {
#             $name = ($file -replace "_state.dart","")
#             $content = Get-StateContent $name
#         }
#         elseif ($file -match "_actions") {
#             $name = ($file -replace "_actions.dart","")
#             $content = Get-ActionsContent $name
#         }
#         elseif ($file -match "_reducer") {
#             $name = ($file -replace "_reducer.dart","")
#             $content = Get-ReducerContent $name
#         }
#         elseif ($file -match "_middleware") {
#             $name = ($file -replace "_middleware.dart","")
#             $content = Get-MiddlewareContent $name
#         }
#         elseif ($file -match "_selectors") {
#             $name = ($file -replace "_selectors.dart","")
#             $content = Get-SelectorsContent $name
#         }
#         elseif ($file -match "_page") {
#             $title = ($file -replace ".dart","")
#             $content = Get-PageContent $title
#         }
#         else {
#             $content = "// TODO: implement $file"
#         }

#         New-FileSafe $full $content
#     }
# }

# Write-Host "`n=== Admin modules created successfully ===" -ForegroundColor Cyan
