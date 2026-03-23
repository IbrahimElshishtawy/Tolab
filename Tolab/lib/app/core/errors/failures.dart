abstract class Failure {
  const Failure(this.message, {this.details});

  final String message;
  final dynamic details;
}

class OfflineFailure extends Failure {
  const OfflineFailure([super.message = 'No internet connection']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'The request took too long']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed', dynamic details])
    : super(details: details);
}

class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Validation failed',
    dynamic details,
  ]) : super(details: details);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error', dynamic details])
    : super(details: details);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unexpected error', dynamic details])
    : super(details: details);
}
