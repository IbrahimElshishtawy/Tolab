import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/moderation_models.dart';

class ModerationRepository {
  ModerationRepository(this._demoDataService);

  final DemoDataService _demoDataService;

  Future<List<ModerationItem>> fetchItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _demoDataService.moderationItems();
  }
}
