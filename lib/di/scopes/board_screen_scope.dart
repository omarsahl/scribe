import 'package:injectable/injectable.dart';
import 'package:kanban/core/logger/logger.dart';
import 'package:kanban/di/di_config.config.dart';
import 'package:kanban/di/di_config.dart';

const boardScreenScope = Scope('boardScreen');

void initBoardScreenScope() {
  getIt.initBoardScreenScope();
}

void removeBoardScreenScope() {
  logger.w('Popping scope "${getIt.currentScopeName}"');
  getIt.popScope();
}
