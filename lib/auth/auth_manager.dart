import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:kanban/auth/models/auth_params.dart';
import 'package:kanban/auth/models/sign_up_params.dart';
import 'package:kanban/auth/providers/auth_providers_registry.dart';
import 'package:kanban/auth/utils/auth_utils.dart';
import 'package:kanban/core/logger/logger.dart';
import 'package:kanban/data/datasource/data_source.dart';
import 'package:kanban/data/entity/user_entity.dart';
import 'package:kanban/exceptions/auth/auth_exception.dart';

final emailRegex = RegExp(r'@.*?\.');

abstract class AuthManager {
  KUser get currentUser;

  KUser? get currentUserOrNull;

  Stream<KUser?> get watchCurrentUser;

  bool get isLoggedIn;

  Future<KUser> logIn(AuthProviderParams authParams);

  Future<void> logOut();

  Future<KUser> signUp(SignUpParams signUpParams);
}

@Singleton(as: AuthManager)
class FirebaseAuthManager extends AuthManager {
  FirebaseAuthManager(this._registry, this._dataSource, this._delegate);

  final FirebaseAuth _delegate;
  final KDataSource _dataSource;
  final KAuthProvidersRegistry _registry;

  @override
  bool get isLoggedIn => currentUserOrNull != null;

  @override
  KUser? get currentUserOrNull {
    final user = _delegate.currentUser;
    if (user == null) {
      return null;
    }
    return user.toKUser();
  }

  @override
  KUser get currentUser {
    if (currentUserOrNull == null) {
      throw NoAuthenticatedUserException();
    }
    return currentUserOrNull!;
  }

  @override
  Stream<KUser?> get watchCurrentUser => _delegate.userChanges().map((user) => user?.toKUser());

  @override
  Future<KUser> logIn(AuthProviderParams authParams) async {
    final provider = _registry.getProvider(authParams);
    final result = await provider.signIn(authParams);
    return await _dataSource.createUser(result.user);
  }

  @override
  Future<void> logOut() async {
    for (var provider in _registry.allProviders) {
      await provider.signOut();
    }
  }

  @override
  Future<KUser> signUp(SignUpParams signUpParams) async {
    final user = await _createAccount(signUpParams);
    try {
      await user.updateDisplayName(signUpParams.name);
    } catch (e, s) {
      logger.e("Error updating new user's name", e, s);
    }
    final kUser = KUser(user.uid, user.displayName, user.email, null, const []);
    return await _dataSource.createUser(kUser);
  }

  Future<User> _createAccount(SignUpParams signUpParams) async {
    try {
      final credentials = await _delegate.createUserWithEmailAndPassword(
        email: signUpParams.email,
        password: signUpParams.password,
      );
      final user = credentials.user;
      if (user == null) {
        throw SignUpException(signUpParams.email);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw AccountAlreadyExistsException(signUpParams.email, e);
        case 'invalid-email':
          throw InvalidAuthEmailException(signUpParams.email, e);
        case 'weak-password':
          throw InvalidAuthPasswordException(e);
        default:
          throw SignUpException(signUpParams.email, e);
      }
    }
  }
}
