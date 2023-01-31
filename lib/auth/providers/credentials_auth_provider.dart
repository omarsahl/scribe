import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:kanban/auth/models/auth_params.dart';
import 'package:kanban/auth/models/auth_result.dart';
import 'package:kanban/auth/providers/auth_provider.dart';
import 'package:kanban/auth/providers/auth_providers_registry.dart';
import 'package:kanban/auth/utils/auth_utils.dart';
import 'package:kanban/exceptions/auth/auth_exception.dart';

@singleton
class KCredentialsAuthProvider extends KAuthProvider<CredentialsAuthProviderParams> {
  KCredentialsAuthProvider(this._delegate, KAuthProvidersRegistry registry) : super(registry, 'credentials') {
    registry.register(this);
  }

  final FirebaseAuth _delegate;

  @override
  Future<AuthProviderResult> signIn(CredentialsAuthProviderParams params) async {
    try {
      final credentials = await _delegate.signInWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );
      final user = credentials.user;
      if (user == null) {
        throw AuthProviderException('Credentials returned a null user');
      }
      return AuthProviderResult(user.toKUser());
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw InvalidAuthEmailException(params.email, e);
        case 'user-not-found':
          throw AccountNotFoundException(e);
        case 'wrong-password':
          throw InvalidAuthPasswordException(e);
        default:
          throw AuthProviderException('Failed to login with with $params', e);
      }
    }
  }

  @override
  FutureOr<void> signOut() {
    return _delegate.signOut();
  }
}
