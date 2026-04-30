import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/subject_models.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../subjects/data/repositories/mock_subjects_repository.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';
import '../../../timetable/presentation/providers/timetable_providers.dart';

typedef AssignmentUploadKey = ({String subjectId, String taskId});

class AssignmentUploadState {
  const AssignmentUploadState({
    this.selectedFileName,
    this.errorMessage,
    this.isUploading = false,
    this.isSuccess = false,
  });

  final String? selectedFileName;
  final String? errorMessage;
  final bool isUploading;
  final bool isSuccess;

  AssignmentUploadState copyWith({
    String? selectedFileName,
    String? errorMessage,
    bool? isUploading,
    bool? isSuccess,
  }) {
    return AssignmentUploadState(
      selectedFileName: selectedFileName ?? this.selectedFileName,
      errorMessage: errorMessage,
      isUploading: isUploading ?? this.isUploading,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

final assignmentUploadControllerProvider =
    NotifierProvider<
      AssignmentUploadController,
      Map<String, AssignmentUploadState>
    >(AssignmentUploadController.new);

final assignmentUploadStateProvider =
    Provider.family<AssignmentUploadState, AssignmentUploadKey>((ref, key) {
      final stateMap = ref.watch(assignmentUploadControllerProvider);
      return stateMap[_encodeKey(key)] ?? const AssignmentUploadState();
    });

class AssignmentUploadController
    extends Notifier<Map<String, AssignmentUploadState>> {
  @override
  Map<String, AssignmentUploadState> build() => {};

  Future<void> pickFile(AssignmentUploadKey key) async {
    final result = await FilePicker.pickFiles(
      withData: false,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    _setState(
      key,
      _readState(key).copyWith(
        selectedFileName: result.files.single.name,
        errorMessage: null,
        isSuccess: false,
      ),
    );
  }

  Future<TaskItem?> upload(AssignmentUploadKey key) async {
    final fileName = _readState(key).selectedFileName;
    if (fileName == null) {
      _setState(
        key,
        _readState(key).copyWith(errorMessage: 'اختر ملفًا أولاً قبل الرفع.'),
      );
      return null;
    }

    _setState(
      key,
      _readState(
        key,
      ).copyWith(isUploading: true, errorMessage: null, isSuccess: false),
    );

    try {
      final updatedTask = await ref
          .read(subjectsRepositoryProvider)
          .uploadAssignment(
            subjectId: key.subjectId,
            taskId: key.taskId,
            fileName: fileName,
          );
      ref.invalidate(tasksProvider(key.subjectId));
      ref.invalidate(subjectByIdProvider(key.subjectId));
      ref.invalidate(homeDashboardProvider);
      ref.invalidate(timetableItemsProvider);
      _setState(
        key,
        _readState(key).copyWith(isUploading: false, isSuccess: true),
      );
      return updatedTask;
    } catch (_) {
      _setState(
        key,
        _readState(key).copyWith(
          isUploading: false,
          isSuccess: false,
          errorMessage: 'تعذر رفع الملف الآن. حاول مرة أخرى.',
        ),
      );
      return null;
    }
  }

  AssignmentUploadState _readState(AssignmentUploadKey key) {
    return state[_encodeKey(key)] ?? const AssignmentUploadState();
  }

  void _setState(AssignmentUploadKey key, AssignmentUploadState next) {
    state = {...state, _encodeKey(key): next};
  }
}

String _encodeKey(AssignmentUploadKey key) => '${key.subjectId}::${key.taskId}';
