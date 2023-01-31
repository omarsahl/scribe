import 'package:injectable/injectable.dart';
import 'package:kanban/core/logger/logger.dart';
import 'package:kanban/di/di_config.config.dart';
import 'package:kanban/di/di_config.dart';

const homeScreenScope = Scope('homeScreen');

void initHomeScreenScope() {
  getIt.initHomeScreenScope();
}

Future<void> removeHomeScreenScope() {
  logger.w('Popping scope "${getIt.currentScopeName}"');
  return getIt.popScope();
}
