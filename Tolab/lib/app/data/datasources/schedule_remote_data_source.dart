import '../../core/constants/api_constants.dart';
import '../models/schedule_event_model.dart';
import 'base_remote_data_source.dart';

class ScheduleRemoteDataSource {
  ScheduleRemoteDataSource(this._remote);

  final BaseRemoteDataSource _remote;

  Future<List<ScheduleEventModel>> list({String week = 'all'}) async {
    final envelope = await _remote.get<List<ScheduleEventModel>>(
      ApiConstants.timetable,
      queryParameters: {'week': week},
      parser: (raw) => (raw as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(ScheduleEventModel.fromJson)
          .toList(),
    );
    return envelope.data!;
  }
}
