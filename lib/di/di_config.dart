import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:kanban/core/env/env.dart';

import 'di_config.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  generateForDir: ['lib'],
  initializerName: 'init',
)
Future<GetIt> configureDependencies({String env = kReleaseMode ? Env.production : Env.development}) =>
    getIt.init(environment: env);
