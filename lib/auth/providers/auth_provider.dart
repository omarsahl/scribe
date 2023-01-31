import 'dart:async';

import 'package:kanban/auth/models/auth_params.dart';
import 'package:kanban/auth/models/auth_result.dart';
import 'package:kanban/auth/providers/auth_providers_registry.dart';
import 'package:kanban/core/logger/logger.dart';
import 'package:meta/meta.dart';

abstract class KAuthProvider<P extends AuthProviderParams> {
  KAuthProvider(this.registry, this.providerId);

  @protected
  final KAuthProvidersRegistry registry;
  final String providerId;

  FutureOr<AuthProviderResult> signIn(P params);

  FutureOr<void> signOut();

  bool accepts(AuthProviderParams params) => params is P;

  void logDebugMessage(String message) {
    logger.i('KAuthProvider($providerId) $message]');
  }

  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    logger.e('KAuthProvider($providerId) $message', error, stackTrace);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KAuthProvider && runtimeType == other.runtimeType && providerId == other.providerId;

  @override
  int get hashCode => providerId.hashCode;
}
