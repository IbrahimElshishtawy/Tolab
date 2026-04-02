import '../../../core/models/content_models.dart';

class LoadSectionContentAction {}

class LoadSectionContentSuccessAction {
  LoadSectionContentSuccessAction(this.items);

  final List<SectionContentModel> items;
}

class LoadSectionContentFailureAction {
  LoadSectionContentFailureAction(this.message);

  final String message;
}

class SaveSectionContentAction {
  SaveSectionContentAction(this.payload);

  final Map<String, dynamic> payload;
}
