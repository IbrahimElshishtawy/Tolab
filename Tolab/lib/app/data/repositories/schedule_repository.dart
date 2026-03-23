import '../../core/utils/result.dart';
import '../datasources/schedule_remote_data_source.dart';
import '../models/schedule_event_model.dart';
import 'base_repository.dart';

class ScheduleRepository with BaseRepository {
  ScheduleRepository(this._remote);

  final ScheduleRemoteDataSource _remote;

  Future<Result<List<ScheduleEventModel>>> list({String week = 'all'}) =>
      guard(() => _remote.list(week: week));
}
