// ignore_for_file: use_super_parameters

import '../../../data/models/admin_models.dart';
import '../../../data/repositories/admin/admin_entity_repositories.dart';
import '../../shared/controllers/management_controller.dart';

class CourseOfferingsController
    extends ManagementController<CourseOfferingModel> {
  CourseOfferingsController(CourseOfferingsRepository repository)
    : super(repository);
}
