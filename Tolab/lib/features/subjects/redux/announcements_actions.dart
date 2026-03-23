import '../data/announcement_model.dart';

class FetchAnnouncementsAction {
  final int subjectId;
  FetchAnnouncementsAction(this.subjectId);
}

class FetchAnnouncementsSuccessAction {
  final int subjectId;
  final List<Announcement> announcements;
  FetchAnnouncementsSuccessAction(this.subjectId, this.announcements);
}

class CreateAnnouncementAction {
  final int subjectId;
  final String title;
  final String body;
  final bool pinned;
  CreateAnnouncementAction(this.subjectId, this.title, this.body, this.pinned);
}

class DeleteAnnouncementAction {
  final int subjectId;
  final int id;
  DeleteAnnouncementAction(this.subjectId, this.id);
}
