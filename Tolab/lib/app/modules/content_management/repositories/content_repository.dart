import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/content_models.dart';

class ContentRepository {
  ContentRepository(this._demoDataService);

  final DemoDataService _demoDataService;

  Future<List<ContentItem>> fetchContent() async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    return _demoDataService.contentItems();
  }
}
