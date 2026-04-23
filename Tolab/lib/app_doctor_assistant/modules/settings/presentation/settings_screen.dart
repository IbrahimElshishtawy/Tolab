import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../presentation/widgets/workspace/faculty_quick_actions_bar.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../state/settings_actions.dart';
import 'models/settings_workspace_models.dart';
import 'widgets/academic_controls_section.dart';
import 'widgets/appearance_settings_section.dart';
import 'widgets/assistant_permissions_section.dart';
import 'widgets/course_settings_section.dart';
import 'widgets/notification_settings_panel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  FacultySettingsDraft? _draft;
  int? _hydratedUserId;

  void _hydrate(SessionUser user) {
    if (_hydratedUserId == user.id && _draft != null) {
      return;
    }
    _hydratedUserId = user.id;
    _draft = FacultySettingsDraft.fromUser(user);
  }

  void _setDraft(FacultySettingsDraft next) {
    setState(() => _draft = next);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _SettingsVm>(
      converter: (store) => _SettingsVm.fromStore(store),
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) {
          return const SizedBox.shrink();
        }
        _hydrate(user);
        final draft = _draft!;

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.settings,
          unreadNotifications: DoctorAssistantMockRepository.instance
              .unreadNotificationsFor(user),
          child: DoctorAssistantPageScaffold(
            title: 'Settings',
            subtitle:
                'Operational control panel for course rules, assistant permissions, notification policy, and academic publication behavior.',
            breadcrumbs: const ['Workspace', 'Settings'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FacultyQuickActionsBar(user: user),
                const SizedBox(height: AppSpacing.md),
                CourseSettingsSection(
                  publishBehavior: draft.coursePublishBehavior,
                  attendancePolicy: draft.attendancePolicy,
                  quizRule: draft.quizRule,
                  onPublishBehaviorChanged: (value) => _setDraft(
                    FacultySettingsDraft(
                      languageCode: draft.languageCode,
                      phone: draft.phone,
                      pushEnabled: draft.pushEnabled,
                      emailEnabled: draft.emailEnabled,
                      remindersEnabled: draft.remindersEnabled,
                      quizAlertsEnabled: draft.quizAlertsEnabled,
                      lectureAlertsEnabled: draft.lectureAlertsEnabled,
                      themeMode: draft.themeMode,
                      compactMode: draft.compactMode,
                      coursePublishBehavior: value,
                      attendancePolicy: draft.attendancePolicy,
                      quizRule: draft.quizRule,
                      assistantCanEditContent: draft.assistantCanEditContent,
                      assistantCanPublishPosts: draft.assistantCanPublishPosts,
                      assistantCanManageGrades: draft.assistantCanManageGrades,
                      assistantScopeLabel: draft.assistantScopeLabel,
                      assignmentWeight: draft.assignmentWeight,
                      midtermWeight: draft.midtermWeight,
                      oralWeight: draft.oralWeight,
                      attendanceWeight: draft.attendanceWeight,
                      finalWeight: draft.finalWeight,
                    ),
                  ),
                  onAttendancePolicyChanged: (value) => _setDraft(
                    FacultySettingsDraft(
                      languageCode: draft.languageCode,
                      phone: draft.phone,
                      pushEnabled: draft.pushEnabled,
                      emailEnabled: draft.emailEnabled,
                      remindersEnabled: draft.remindersEnabled,
                      quizAlertsEnabled: draft.quizAlertsEnabled,
                      lectureAlertsEnabled: draft.lectureAlertsEnabled,
                      themeMode: draft.themeMode,
                      compactMode: draft.compactMode,
                      coursePublishBehavior: draft.coursePublishBehavior,
                      attendancePolicy: value,
                      quizRule: draft.quizRule,
                      assistantCanEditContent: draft.assistantCanEditContent,
                      assistantCanPublishPosts: draft.assistantCanPublishPosts,
                      assistantCanManageGrades: draft.assistantCanManageGrades,
                      assistantScopeLabel: draft.assistantScopeLabel,
                      assignmentWeight: draft.assignmentWeight,
                      midtermWeight: draft.midtermWeight,
                      oralWeight: draft.oralWeight,
                      attendanceWeight: draft.attendanceWeight,
                      finalWeight: draft.finalWeight,
                    ),
                  ),
                  onQuizRuleChanged: (value) => _setDraft(
                    FacultySettingsDraft(
                      languageCode: draft.languageCode,
                      phone: draft.phone,
                      pushEnabled: draft.pushEnabled,
                      emailEnabled: draft.emailEnabled,
                      remindersEnabled: draft.remindersEnabled,
                      quizAlertsEnabled: draft.quizAlertsEnabled,
                      lectureAlertsEnabled: draft.lectureAlertsEnabled,
                      themeMode: draft.themeMode,
                      compactMode: draft.compactMode,
                      coursePublishBehavior: draft.coursePublishBehavior,
                      attendancePolicy: draft.attendancePolicy,
                      quizRule: value,
                      assistantCanEditContent: draft.assistantCanEditContent,
                      assistantCanPublishPosts: draft.assistantCanPublishPosts,
                      assistantCanManageGrades: draft.assistantCanManageGrades,
                      assistantScopeLabel: draft.assistantScopeLabel,
                      assignmentWeight: draft.assignmentWeight,
                      midtermWeight: draft.midtermWeight,
                      oralWeight: draft.oralWeight,
                      attendanceWeight: draft.attendanceWeight,
                      finalWeight: draft.finalWeight,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                NotificationSettingsPanel(
                  pushEnabled: draft.pushEnabled,
                  emailEnabled: draft.emailEnabled,
                  remindersEnabled: draft.remindersEnabled,
                  quizAlertsEnabled: draft.quizAlertsEnabled,
                  lectureAlertsEnabled: draft.lectureAlertsEnabled,
                  onPushChanged: (value) => _setDraft(_copyDraft(draft, pushEnabled: value)),
                  onEmailChanged: (value) => _setDraft(_copyDraft(draft, emailEnabled: value)),
                  onRemindersChanged: (value) => _setDraft(_copyDraft(draft, remindersEnabled: value)),
                  onQuizAlertsChanged: (value) => _setDraft(_copyDraft(draft, quizAlertsEnabled: value)),
                  onLectureAlertsChanged: (value) => _setDraft(_copyDraft(draft, lectureAlertsEnabled: value)),
                ),
                const SizedBox(height: AppSpacing.md),
                AssistantPermissionsSection(
                  canEditContent: draft.assistantCanEditContent,
                  canPublishPosts: draft.assistantCanPublishPosts,
                  canManageGrades: draft.assistantCanManageGrades,
                  scopeLabel: draft.assistantScopeLabel,
                  onEditContentChanged: (value) => _setDraft(_copyDraft(draft, assistantCanEditContent: value)),
                  onPublishPostsChanged: (value) => _setDraft(_copyDraft(draft, assistantCanPublishPosts: value)),
                  onManageGradesChanged: (value) => _setDraft(_copyDraft(draft, assistantCanManageGrades: value)),
                  onScopeLabelChanged: (value) => _setDraft(_copyDraft(draft, assistantScopeLabel: value)),
                ),
                const SizedBox(height: AppSpacing.md),
                AppearanceSettingsSection(
                  languageCode: draft.languageCode,
                  themeMode: draft.themeMode,
                  compactMode: draft.compactMode,
                  phone: draft.phone,
                  onLanguageChanged: (value) => _setDraft(_copyDraft(draft, languageCode: value)),
                  onThemeModeChanged: (value) => _setDraft(_copyDraft(draft, themeMode: value)),
                  onCompactModeChanged: (value) => _setDraft(_copyDraft(draft, compactMode: value)),
                  onPhoneChanged: (value) => _setDraft(_copyDraft(draft, phone: value)),
                ),
                const SizedBox(height: AppSpacing.md),
                AcademicControlsSection(
                  assignmentWeight: draft.assignmentWeight,
                  midtermWeight: draft.midtermWeight,
                  oralWeight: draft.oralWeight,
                  attendanceWeight: draft.attendanceWeight,
                  finalWeight: draft.finalWeight,
                  totalWeight: draft.totalWeight,
                  onAssignmentChanged: (value) => _setDraft(_copyDraft(draft, assignmentWeight: value)),
                  onMidtermChanged: (value) => _setDraft(_copyDraft(draft, midtermWeight: value)),
                  onOralChanged: (value) => _setDraft(_copyDraft(draft, oralWeight: value)),
                  onAttendanceChanged: (value) => _setDraft(_copyDraft(draft, attendanceWeight: value)),
                  onFinalChanged: (value) => _setDraft(_copyDraft(draft, finalWeight: value)),
                ),
                const SizedBox(height: AppSpacing.md),
                DoctorAssistantPanel(
                  title: 'Save / reset',
                  subtitle:
                      'Run validation before saving, or reset to the current recommended academic defaults.',
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      FilledButton.icon(
                        onPressed: vm.isSaving
                            ? null
                            : () {
                                final validationMessage = validateFacultySettings(draft);
                                if (validationMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(validationMessage)),
                                  );
                                  return;
                                }

                                vm.save(<String, dynamic>{
                                  'language': draft.languageCode,
                                  'notification_enabled': draft.pushEnabled,
                                  'phone': draft.phone,
                                  'email_enabled': draft.emailEnabled,
                                  'reminders_enabled': draft.remindersEnabled,
                                  'quiz_alerts_enabled': draft.quizAlertsEnabled,
                                  'lecture_alerts_enabled': draft.lectureAlertsEnabled,
                                  'theme_mode': draft.themeMode,
                                  'compact_mode': draft.compactMode,
                                  'publish_behavior': draft.coursePublishBehavior,
                                  'attendance_policy': draft.attendancePolicy,
                                  'quiz_rule': draft.quizRule,
                                  'assistant_permissions': <String, dynamic>{
                                    'edit_content': draft.assistantCanEditContent,
                                    'publish_posts': draft.assistantCanPublishPosts,
                                    'manage_grades': draft.assistantCanManageGrades,
                                    'scope_label': draft.assistantScopeLabel,
                                  },
                                  'grade_weights': <String, dynamic>{
                                    'assignments': draft.assignmentWeight.round(),
                                    'midterm': draft.midtermWeight.round(),
                                    'oral': draft.oralWeight.round(),
                                    'attendance': draft.attendanceWeight.round(),
                                    'final': draft.finalWeight.round(),
                                  },
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Settings validated and saved for the current workspace session.')),
                                );
                              },
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save settings'),
                      ),
                      OutlinedButton.icon(
                        onPressed: vm.isSaving
                            ? null
                            : () => setState(() => _draft = FacultySettingsDraft.fromUser(user)),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reset'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

FacultySettingsDraft _copyDraft(
  FacultySettingsDraft draft, {
  String? languageCode,
  String? phone,
  bool? pushEnabled,
  bool? emailEnabled,
  bool? remindersEnabled,
  bool? quizAlertsEnabled,
  bool? lectureAlertsEnabled,
  String? themeMode,
  bool? compactMode,
  String? coursePublishBehavior,
  String? attendancePolicy,
  String? quizRule,
  bool? assistantCanEditContent,
  bool? assistantCanPublishPosts,
  bool? assistantCanManageGrades,
  String? assistantScopeLabel,
  double? assignmentWeight,
  double? midtermWeight,
  double? oralWeight,
  double? attendanceWeight,
  double? finalWeight,
}) {
  return FacultySettingsDraft(
    languageCode: languageCode ?? draft.languageCode,
    phone: phone ?? draft.phone,
    pushEnabled: pushEnabled ?? draft.pushEnabled,
    emailEnabled: emailEnabled ?? draft.emailEnabled,
    remindersEnabled: remindersEnabled ?? draft.remindersEnabled,
    quizAlertsEnabled: quizAlertsEnabled ?? draft.quizAlertsEnabled,
    lectureAlertsEnabled: lectureAlertsEnabled ?? draft.lectureAlertsEnabled,
    themeMode: themeMode ?? draft.themeMode,
    compactMode: compactMode ?? draft.compactMode,
    coursePublishBehavior: coursePublishBehavior ?? draft.coursePublishBehavior,
    attendancePolicy: attendancePolicy ?? draft.attendancePolicy,
    quizRule: quizRule ?? draft.quizRule,
    assistantCanEditContent: assistantCanEditContent ?? draft.assistantCanEditContent,
    assistantCanPublishPosts: assistantCanPublishPosts ?? draft.assistantCanPublishPosts,
    assistantCanManageGrades: assistantCanManageGrades ?? draft.assistantCanManageGrades,
    assistantScopeLabel: assistantScopeLabel ?? draft.assistantScopeLabel,
    assignmentWeight: assignmentWeight ?? draft.assignmentWeight,
    midtermWeight: midtermWeight ?? draft.midtermWeight,
    oralWeight: oralWeight ?? draft.oralWeight,
    attendanceWeight: attendanceWeight ?? draft.attendanceWeight,
    finalWeight: finalWeight ?? draft.finalWeight,
  );
}

class _SettingsVm {
  const _SettingsVm({
    required this.user,
    required this.isSaving,
    required this.save,
  });

  final SessionUser? user;
  final bool isSaving;
  final void Function(Map<String, dynamic> payload) save;

  factory _SettingsVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _SettingsVm(
      user: getCurrentUser(store.state),
      isSaving: store.state.settingsState.status.name == 'loading',
      save: (payload) => store.dispatch(UpdateSettingsAction(payload)),
    );
  }
}
