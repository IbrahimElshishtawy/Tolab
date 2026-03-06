class FetchUsersAction {
  final int page;
  FetchUsersAction({this.page = 1});
}

class FetchUsersSuccessAction {
  final List<dynamic> users;
  final bool hasMore;
  FetchUsersSuccessAction(this.users, this.hasMore);
}

class FetchUsersFailureAction {
  final String error;
  FetchUsersFailureAction(this.error);
}

class FetchAdminSubjectsAction {}
class FetchAdminSubjectsSuccessAction {
  final List<dynamic> subjects;
  FetchAdminSubjectsSuccessAction(this.subjects);
}

class FetchAdminOfferingsAction {}
class FetchAdminOfferingsSuccessAction {
  final List<dynamic> offerings;
  FetchAdminOfferingsSuccessAction(this.offerings);
}

class AdminLoadingAction {
  final bool isLoading;
  AdminLoadingAction(this.isLoading);
}

class AdminErrorAction {
  final String? error;
  AdminErrorAction(this.error);
}
