import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:kanban/core/env/env.dart';
import 'package:kanban/di/di_config.dart';

import 'test_di_config.config.dart';

@InjectableInit(
  generateForDir: ['lib', 'integration_test'],
  initializerName: 'integrationTestInit',
)
Future<GetIt> configureIntegrationTestDependencies() => getIt.integrationTestInit(environment: Env.instrumentationTesting);
