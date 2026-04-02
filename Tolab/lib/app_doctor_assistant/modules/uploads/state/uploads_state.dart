import '../../../core/models/notification_models.dart';
import '../../../core/state/async_state.dart';

class UploadsState extends AsyncState<List<UploadModel>> {
  const UploadsState({
    super.status,
    super.data,
    super.error,
    this.progress = 0,
  });

  final double progress;

  @override
  UploadsState copyWith({
    ViewStatus? status,
    List<UploadModel>? data,
    String? error,
    bool clearError = false,
    double? progress,
  }) {
    return UploadsState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: clearError ? null : error ?? this.error,
      progress: progress ?? this.progress,
    );
  }
}
