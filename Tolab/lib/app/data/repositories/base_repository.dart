import '../../core/errors/app_exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';

mixin BaseRepository {
  Future<Result<T>> guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on AppException catch (error) {
      return FailureResult(_mapFailure(error));
    } catch (_) {
      return const FailureResult(UnknownFailure());
    }
  }

  Failure _mapFailure(AppException exception) {
    switch (exception) {
      case OfflineException():
        return OfflineFailure(exception.message);
      case TimeoutAppException():
        return TimeoutFailure(exception.message);
      case UnauthorizedException():
      case ForbiddenException():
        return AuthFailure(exception.message, exception.details);
      case ValidationException():
        return ValidationFailure(exception.message, exception.details);
      case ServerAppException():
        return ServerFailure(exception.message, exception.details);
      default:
        return UnknownFailure(exception.message, exception.details);
    }
  }
}
