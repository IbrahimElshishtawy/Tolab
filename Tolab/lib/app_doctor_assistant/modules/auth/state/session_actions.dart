import '../../../core/models/session_user.dart';

class SessionEstablishedAction {
  SessionEstablishedAction(this.user);

  final SessionUser user;
}

class SessionClearedAction {
  const SessionClearedAction();
}
