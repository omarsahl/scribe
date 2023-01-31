import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kanban/core/env/env.dart';

class EnvConfig {
  EnvConfig._();

  static get isAndroid => Platform.isAndroid;

  static get isIOS => Platform.isIOS;

  static const currentEnv = String.fromEnvironment(
    'ENV',
    defaultValue: kReleaseMode ? Env.production : Env.development,
  );

  static const debuggingEnabled = bool.fromEnvironment(
    'ENABLE_DEBUGGING',
    defaultValue: !kReleaseMode,
  );

  static const crashlyticsEnabled = bool.fromEnvironment(
    'ENABLE_CRASHLYTICS',
    defaultValue: kReleaseMode,
  );

  static const logsEnabled = bool.fromEnvironment('ENABLE_LOGS', defaultValue: !kReleaseMode);
}
