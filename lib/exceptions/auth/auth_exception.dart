

abstract class AuthException implements Exception {
  AuthException(this.message, [this.cause]);

  final dynamic cause;
  final String message;

  @override
  String toString() {
    if (cause == null) {
      return message;
    }
    if (cause is Exception) {
      return '$message.\n${cause.toString()}';
    }
    return '$message.\n${Error.safeToString(cause)}';
  }
}

class NoAuthenticatedUserException extends AuthException {
  NoAuthenticatedUserException() : super('No authenticated user');
}

class AccountAlreadyExistsException extends AuthException {
  AccountAlreadyExistsException(this.email, [dynamic cause])
      : super('The email address ($email) is already in use by another account.', cause);

  final String email;
}

class AccountNotFoundException extends AuthException {
  AccountNotFoundException([dynamic cause]) : super('Account not found', cause);
}

class InvalidAuthEmailException extends AuthException {
  InvalidAuthEmailException(this.email, [dynamic cause])
      : super('The email address ($email) is invalid', cause);

  final String email;
}

class InvalidAuthPasswordException extends AuthException {
  InvalidAuthPasswordException([dynamic cause]) : super('Invalid password', cause);
}

class AuthProviderException extends AuthException {
  AuthProviderException(super.message, [super.cause]);
}

class SignUpException extends AuthException {
  SignUpException(this.email, [dynamic cause]) : super('Failed to create a new account for $email', cause);

  final String email;
}
