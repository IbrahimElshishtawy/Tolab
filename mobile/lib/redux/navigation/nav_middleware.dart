import 'package:redux/redux.dart';
import '../app_state.dart';
import 'nav_actions.dart';
import '../../core/routing/app_router.dart';

List<Middleware<AppState>> createNavMiddlewares() {
  return [
    TypedMiddleware<AppState, NavigateToDeepLinkAction>(_handleDeepLink),
  ];
}

void _handleDeepLink(Store<AppState> store, NavigateToDeepLinkAction action, NextDispatcher next) {
  next(action);

  final uri = Uri.parse(action.deepLink);
  if (uri.scheme != 'lms') return;

  final pathSegments = uri.pathSegments;
  if (pathSegments.length < 2) return;

  final type = pathSegments[0];
  final id = pathSegments[1];

  switch (type) {
    case 'task':
      appRouter.push('/subjects'); // Placeholder until task routing is fully detailed
      break;
    case 'subject':
      appRouter.push('/subjects/$id');
      break;
    case 'post':
      appRouter.push('/community');
      break;
  }
}
