import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/content_models.dart';

class UploadsRepository {
  UploadsRepository(this._demoDataService);

  final DemoDataService _demoDataService;

  Future<List<UploadItem>> fetchUploads() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _demoDataService.uploads();
  }
}
