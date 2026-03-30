import 'dart:typed_data';

import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/notification_models.dart';
import '../../../state/app_state.dart';
import '../../notifications/state/notifications_state.dart';
import '../models/student_management_models.dart';

class StudentsState {
  const StudentsState({
    this.status = LoadStatus.initial,
    this.snapshot,
    this.filters = const StudentFilters(),
    this.activeTab = StudentWorkspaceTab.overview,
    this.selectedStudentId,
    this.selectedStudentIds = const <String>{},
    this.sortColumn = 'name',
    this.sortAscending = true,
    this.isWorking = false,
    this.importPreview,
    this.importProgress = 0,
    this.lastImportResult,
    this.errorMessage,
    this.lastUpdatedAt,
  });

  final LoadStatus status;
  final StudentModuleSnapshot? snapshot;
  final StudentFilters filters;
  final StudentWorkspaceTab activeTab;
  final String? selectedStudentId;
  final Set<String> selectedStudentIds;
  final String sortColumn;
  final bool sortAscending;
  final bool isWorking;
  final StudentImportPreview? importPreview;
  final double importProgress;
  final StudentImportResult? lastImportResult;
  final String? errorMessage;
  final DateTime? lastUpdatedAt;

  StudentsState copyWith({
    LoadStatus? status,
    StudentModuleSnapshot? snapshot,
    StudentFilters? filters,
    StudentWorkspaceTab? activeTab,
    String? selectedStudentId,
    Set<String>? selectedStudentIds,
    String? sortColumn,
    bool? sortAscending,
    bool? isWorking,
    StudentImportPreview? importPreview,
    double? importProgress,
    StudentImportResult? lastImportResult,
    String? errorMessage,
    DateTime? lastUpdatedAt,
    bool clearSelection = false,
    bool clearImportPreview = false,
    bool clearLastImportResult = false,
    bool clearError = false,
  }) {
    return StudentsState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      filters: filters ?? this.filters,
      activeTab: activeTab ?? this.activeTab,
      selectedStudentId: selectedStudentId ?? this.selectedStudentId,
      selectedStudentIds: clearSelection
          ? <String>{}
          : selectedStudentIds ?? this.selectedStudentIds,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      isWorking: isWorking ?? this.isWorking,
      importPreview: clearImportPreview
          ? null
          : importPreview ?? this.importPreview,
      importProgress: importProgress ?? this.importProgress,
      lastImportResult: clearLastImportResult
          ? null
          : lastImportResult ?? this.lastImportResult,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

const StudentsState initialStudentsState = StudentsState();

class LoadStudentsAction {
  const LoadStudentsAction({this.force = false});

  final bool force;
}

class StudentsLoadedAction {
  const StudentsLoadedAction(this.snapshot);

  final StudentModuleSnapshot snapshot;
}

class StudentsFailedAction {
  const StudentsFailedAction(this.message);

  final String message;
}

class StudentsAsyncStartedAction {
  const StudentsAsyncStartedAction();
}

class StudentsTabChangedAction {
  const StudentsTabChangedAction(this.tab);

  final StudentWorkspaceTab tab;
}

class StudentsFiltersChangedAction {
  const StudentsFiltersChangedAction(this.filters);

  final StudentFilters filters;
}

class StudentsSelectedStudentChangedAction {
  const StudentsSelectedStudentChangedAction(this.studentId);

  final String? studentId;
}

class StudentsToggleSelectionAction {
  const StudentsToggleSelectionAction(this.studentId);

  final String studentId;
}

class StudentsSetSelectionAction {
  const StudentsSetSelectionAction(this.studentIds);

  final Set<String> studentIds;
}

class StudentsClearSelectionAction {
  const StudentsClearSelectionAction();
}

class StudentsSortChangedAction {
  const StudentsSortChangedAction(this.column);

  final String column;
}

class StudentsImportPreviewRequestedAction {
  const StudentsImportPreviewRequestedAction({
    required this.fileName,
    required this.bytes,
  });

  final String fileName;
  final Uint8List bytes;
}

class StudentsImportPreviewLoadedAction {
  const StudentsImportPreviewLoadedAction(this.preview);

  final StudentImportPreview preview;
}

class StudentsImportMappingUpdatedAction {
  const StudentsImportMappingUpdatedAction(this.field, this.header);

  final StudentImportField field;
  final String? header;
}

class StudentsImportProgressAction {
  const StudentsImportProgressAction(this.value);

  final double value;
}

class StudentsImportRequestedAction {
  const StudentsImportRequestedAction();
}

class StudentsImportCompletedAction {
  const StudentsImportCompletedAction(this.snapshot, this.result);

  final StudentModuleSnapshot snapshot;
  final StudentImportResult result;
}

class StudentsStudentSavedRequestedAction {
  const StudentsStudentSavedRequestedAction({
    required this.student,
    this.verificationCode,
  });

  final StudentProfile student;
  final String? verificationCode;
}

class StudentsBulkActionRequestedAction {
  const StudentsBulkActionRequestedAction({
    required this.type,
    this.studentIds,
    this.courseTitle,
    this.status,
    this.verificationCode,
  });

  final StudentBulkActionType type;
  final List<String>? studentIds;
  final String? courseTitle;
  final StudentEnrollmentStatus? status;
  final String? verificationCode;
}

class StudentsDocumentsUploadRequestedAction {
  const StudentsDocumentsUploadRequestedAction({
    required this.studentId,
    required this.files,
  });

  final String studentId;
  final List<StudentUploadedFile> files;
}

class StudentsDocumentDecisionRequestedAction {
  const StudentsDocumentDecisionRequestedAction({
    required this.studentId,
    required this.documentId,
    required this.status,
    this.verificationCode,
  });

  final String studentId;
  final String documentId;
  final StudentDocumentStatus status;
  final String? verificationCode;
}

class StudentsCampaignRequestedAction {
  const StudentsCampaignRequestedAction({
    required this.title,
    required this.body,
    required this.channel,
    required this.recipientStudentIds,
    this.audienceLabel,
    this.groupId,
  });

  final String title;
  final String body;
  final StudentCommunicationChannel channel;
  final List<String> recipientStudentIds;
  final String? audienceLabel;
  final String? groupId;
}

class StudentsOperationCompletedAction {
  const StudentsOperationCompletedAction({
    required this.snapshot,
    required this.message,
    this.selectedStudentId,
  });

  final StudentModuleSnapshot snapshot;
  final String message;
  final String? selectedStudentId;
}

class StudentsRealtimeAlertReceivedAction {
  const StudentsRealtimeAlertReceivedAction(this.alert);

  final StudentModuleAlert alert;
}

class StudentsTranscriptExportRequestedAction {
  const StudentsTranscriptExportRequestedAction({
    required this.studentId,
    required this.onReady,
    this.onError,
  });

  final String studentId;
  final void Function(Uint8List bytes, String suggestedName) onReady;
  final void Function(String message)? onError;
}

class StudentsAnalyticsExportRequestedAction {
  const StudentsAnalyticsExportRequestedAction({
    required this.onReady,
    this.onError,
  });

  final void Function(Uint8List bytes, String suggestedName) onReady;
  final void Function(String message)? onError;
}

class StudentsDocumentBundleRequestedAction {
  const StudentsDocumentBundleRequestedAction({
    required this.studentId,
    required this.onReady,
    this.onError,
  });

  final String studentId;
  final void Function(Uint8List bytes, String suggestedName) onReady;
  final void Function(String message)? onError;
}

StudentsState studentsReducer(StudentsState state, dynamic action) {
  switch (action) {
    case LoadStudentsAction():
      return state.copyWith(
        status: LoadStatus.loading,
        clearError: true,
        clearLastImportResult: true,
      );
    case StudentsLoadedAction():
      return state.copyWith(
        status: LoadStatus.success,
        snapshot: action.snapshot,
        selectedStudentId:
            state.selectedStudentId ?? action.snapshot.students.firstOrNull?.id,
        lastUpdatedAt: DateTime.now(),
        clearError: true,
      );
    case StudentsFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        isWorking: false,
        errorMessage: action.message,
      );
    case StudentsAsyncStartedAction():
      return state.copyWith(isWorking: true, clearError: true);
    case StudentsTabChangedAction():
      return state.copyWith(activeTab: action.tab);
    case StudentsFiltersChangedAction():
      return state.copyWith(filters: action.filters);
    case StudentsSelectedStudentChangedAction():
      return state.copyWith(selectedStudentId: action.studentId);
    case StudentsToggleSelectionAction():
      final next = Set<String>.from(state.selectedStudentIds);
      if (next.contains(action.studentId)) {
        next.remove(action.studentId);
      } else {
        next.add(action.studentId);
      }
      return state.copyWith(selectedStudentIds: next);
    case StudentsSetSelectionAction():
      return state.copyWith(selectedStudentIds: action.studentIds);
    case StudentsClearSelectionAction():
      return state.copyWith(clearSelection: true);
    case StudentsSortChangedAction():
      final isSameColumn = state.sortColumn == action.column;
      return state.copyWith(
        sortColumn: action.column,
        sortAscending: isSameColumn ? !state.sortAscending : true,
      );
    case StudentsImportPreviewLoadedAction():
      return state.copyWith(
        isWorking: false,
        importPreview: action.preview,
        importProgress: 0,
        clearLastImportResult: true,
      );
    case StudentsImportMappingUpdatedAction():
      final preview = state.importPreview;
      if (preview == null) return state;
      return state.copyWith(
        importPreview: preview.copyWith(
          columnMapping: {
            ...preview.columnMapping,
            action.field: action.header,
          },
        ),
      );
    case StudentsImportProgressAction():
      return state.copyWith(importProgress: action.value);
    case StudentsImportCompletedAction():
      return state.copyWith(
        status: LoadStatus.success,
        snapshot: action.snapshot,
        isWorking: false,
        importProgress: 1,
        lastImportResult: action.result,
        clearImportPreview: true,
        clearError: true,
        lastUpdatedAt: DateTime.now(),
      );
    case StudentsOperationCompletedAction():
      return state.copyWith(
        status: LoadStatus.success,
        snapshot: action.snapshot,
        isWorking: false,
        selectedStudentId: action.selectedStudentId ?? state.selectedStudentId,
        clearError: true,
        lastUpdatedAt: DateTime.now(),
      );
    case StudentsRealtimeAlertReceivedAction():
      final snapshot = state.snapshot;
      if (snapshot == null) return state;
      return state.copyWith(
        snapshot: snapshot.copyWith(
          alerts: [action.alert, ...snapshot.alerts.take(7)],
          generatedAt: DateTime.now(),
        ),
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createStudentsMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadStudentsAction>((store, action, next) async {
      next(action);
      try {
        final snapshot = await deps.studentsRepository.fetchModuleSnapshot(
          forceRefresh: action.force,
        );
        store.dispatch(StudentsLoadedAction(snapshot));
      } catch (error) {
        store.dispatch(StudentsFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, StudentsImportPreviewRequestedAction>((
      store,
      action,
      next,
    ) async {
      store.dispatch(const StudentsAsyncStartedAction());
      next(action);
      try {
        final preview = await deps.studentsRepository.previewImport(
          action.fileName,
          action.bytes,
        );
        store.dispatch(StudentsImportPreviewLoadedAction(preview));
      } catch (error) {
        store.dispatch(StudentsFailedAction(error.toString()));
        _queueToast(
          store,
          title: 'Import preview failed',
          body: error.toString(),
          category: AdminNotificationCategory.system,
        );
      }
    }).call,
    TypedMiddleware<AppState, StudentsImportRequestedAction>((
      store,
      action,
      next,
    ) async {
      store.dispatch(const StudentsAsyncStartedAction());
      next(action);
      final preview = store.state.studentsState.importPreview;
      if (preview == null) {
        store.dispatch(
          const StudentsFailedAction('No import preview is ready.'),
        );
        return;
      }
      try {
        final outcome = await deps.studentsRepository.importStudents(
          preview,
          onProgress: (value) =>
              store.dispatch(StudentsImportProgressAction(value)),
        );
        store.dispatch(
          StudentsImportCompletedAction(outcome.snapshot, outcome.result),
        );
        _queueToast(
          store,
          title: 'Bulk upload completed',
          body: outcome.result.summary,
          category: AdminNotificationCategory.system,
        );
      } catch (error) {
        store.dispatch(StudentsFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, StudentsStudentSavedRequestedAction>((
      store,
      action,
      next,
    ) async {
      store.dispatch(const StudentsAsyncStartedAction());
      next(action);
      try {
        final saved = await deps.studentsRepository.saveStudent(
          action.student,
          verificationCode: action.verificationCode,
        );
        final snapshot = await deps.studentsRepository.fetchModuleSnapshot();
        store.dispatch(
          StudentsOperationCompletedAction(
            snapshot: snapshot,
            message: '${saved.fullName} saved successfully.',
            selectedStudentId: saved.id,
          ),
        );
        _queueToast(
          store,
          title: 'Student saved',
          body: '${saved.fullName} is now up to date.',
          category: AdminNotificationCategory.academic,
        );
      } catch (error) {
        store.dispatch(StudentsFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, StudentsBulkActionRequestedAction>((
      store,
      action,
      next,
    ) async {
      store.dispatch(const StudentsAsyncStartedAction());
      next(action);
      final ids =
          action.studentIds ??
          store.state.studentsState.selectedStudentIds.toList();
      if (ids.isEmpty) {
        store.dispatch(
          const StudentsFailedAction('Select at least one student first.'),
        );
        return;
      }
      try {
        final snapshot = await deps.studentsRepository.performBulkAction(
          type: action.type,
          studentIds: ids,
          courseTitle: action.courseTitle,
          status: action.status,
          verificationCode: action.verificationCode,
        );
        store.dispatch(
          StudentsOperationCompletedAction(
            snapshot: snapshot,
            message: '${action.type.label} completed.',
          ),
        );
        store.dispatch(const StudentsClearSelectionAction());
        _queueToast(
          store,
          title: action.type.label,
          body: '${ids.length} student records updated.',
          category: AdminNotificationCategory.academic,
        );
      } catch (error) {
        store.dispatch(StudentsFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, StudentsDocumentsUploadRequestedAction>((
      store,
      action,
      next,
    ) async {
      store.dispatch(const StudentsAsyncStartedAction());
      next(action);
      try {
        final snapshot = await deps.studentsRepository.uploadDocuments(
          action.studentId,
          action.files,
        );
        store.dispatch(
          StudentsOperationCompletedAction(
            snapshot: snapshot,
            message: '${action.files.length} documents uploaded.',
            selectedStudentId: action.studentId,
          ),
        );
        _queueToast(
          store,
          title: 'Documents uploaded',
          body: '${action.files.length} new files are pending approval.',
          category: AdminNotificationCategory.system,
        );
      } catch (error) {
        store.dispatch(StudentsFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, StudentsDocumentDecisionRequestedAction>((
      store,
      action,
      next,
    ) async {
      store.dispatch(const StudentsAsyncStartedAction());
      next(action);
      try {
        final snapshot = await deps.studentsRepository.updateDocumentStatus(
          studentId: action.studentId,
          documentId: action.documentId,
          status: action.status,
          verificationCode: action.verificationCode,
        );
        store.dispatch(
          StudentsOperationCompletedAction(
            snapshot: snapshot,
            message: 'Document ${action.status.label.toLowerCase()}.',
            selectedStudentId: action.studentId,
          ),
        );
        _queueToast(
          store,
          title: 'Document review',
          body:
              'Student document marked as ${action.status.label.toLowerCase()}.',
          category: AdminNotificationCategory.system,
        );
      } catch (error) {
        store.dispatch(StudentsFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, StudentsCampaignRequestedAction>((
      store,
      action,
      next,
    ) async {
      store.dispatch(const StudentsAsyncStartedAction());
      next(action);
      try {
        final snapshot = await deps.studentsRepository.sendCampaign(
          title: action.title,
          body: action.body,
          channel: action.channel,
          recipientStudentIds: action.recipientStudentIds,
          audienceLabel: action.audienceLabel,
          groupId: action.groupId,
        );
        store.dispatch(
          StudentsOperationCompletedAction(
            snapshot: snapshot,
            message: '${action.title} sent.',
          ),
        );
        _queueToast(
          store,
          title: 'Campaign sent',
          body:
              '${action.recipientStudentIds.length} recipients reached via ${action.channel.label}.',
          category: AdminNotificationCategory.messages,
        );
      } catch (error) {
        store.dispatch(StudentsFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, StudentsTranscriptExportRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final bytes = await deps.studentsRepository.buildTranscriptPdf(
          action.studentId,
        );
        action.onReady(bytes, 'student-transcript-${action.studentId}.pdf');
        _queueToast(
          store,
          title: 'Transcript ready',
          body: 'The student transcript PDF has been prepared.',
          category: AdminNotificationCategory.academic,
        );
      } catch (error) {
        action.onError?.call(error.toString());
        store.dispatch(StudentsFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, StudentsAnalyticsExportRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final bytes = await deps.studentsRepository.buildAnalyticsReportPdf();
        action.onReady(bytes, 'students-analytics-report.pdf');
      } catch (error) {
        action.onError?.call(error.toString());
        store.dispatch(StudentsFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, StudentsDocumentBundleRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final bytes = await deps.studentsRepository.buildDocumentBundle(
          action.studentId,
        );
        action.onReady(bytes, 'student-documents-${action.studentId}.zip');
        _queueToast(
          store,
          title: 'Document bundle ready',
          body: 'Bulk download has been prepared for the selected student.',
          category: AdminNotificationCategory.system,
        );
      } catch (error) {
        action.onError?.call(error.toString());
        store.dispatch(StudentsFailedAction(error.toString()));
      }
    }).call,
    TypedMiddleware<AppState, IncomingNotificationAction>((
      store,
      action,
      next,
    ) {
      next(action);
      final notification = action.notification;
      final isStudentAlert =
          (notification.refType?.toLowerCase().contains('student') ?? false) ||
          notification.title.toLowerCase().contains('student') ||
          notification.body.toLowerCase().contains('student') ||
          notification.title.toLowerCase().contains('approval') ||
          notification.body.toLowerCase().contains('enrollment');
      if (!isStudentAlert) return;
      store.dispatch(
        StudentsRealtimeAlertReceivedAction(
          StudentModuleAlert(
            id: notification.id,
            title: notification.title,
            body: notification.body,
            severity: switch (notification.category) {
              AdminNotificationCategory.system => StudentAlertSeverity.warning,
              AdminNotificationCategory.messages => StudentAlertSeverity.info,
              AdminNotificationCategory.announcements =>
                StudentAlertSeverity.success,
              AdminNotificationCategory.academic =>
                StudentAlertSeverity.critical,
            },
            createdAt: notification.createdAt,
            badgeLabel: notification.category.label,
          ),
        ),
      );
    }).call,
  ];
}

void _queueToast(
  Store<AppState> store, {
  required String title,
  required String body,
  required AdminNotificationCategory category,
}) {
  store.dispatch(
    IncomingNotificationAction(
      AdminNotification(
        id: 'student-module-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        body: body,
        category: category,
        createdAt: DateTime.now(),
        isRead: false,
        rawType: category.backendType,
        refType: 'student_module',
        source: 'local',
        audienceLabel: 'Student management',
      ),
      showToast: true,
      showLocalAlert: false,
    ),
  );
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
