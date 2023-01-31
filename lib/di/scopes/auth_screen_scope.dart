import 'package:injectable/injectable.dart';
import 'package:kanban/core/logger/logger.dart';
import 'package:kanban/di/di_config.config.dart';
import 'package:kanban/di/di_config.dart';

const authScreenScope = Scope('authScreen');

void initAuthScreenScope() {
  getIt.initAuthScreenScope();
}

Future<void> removeAuthScreenScope() {
  logger.w('Popping scope "${getIt.currentScopeName}"');
  return getIt.popScope();
}
