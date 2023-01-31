import 'dart:async';

import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:kanban/config/app_config.dart';
import 'package:kanban/config/config_store.dart';
import 'package:kanban/core/io/path_provider.dart';

@singleton
class ConfigManager {
  ConfigManager(this._pathProvider);

  final PathProvider _pathProvider;

  final AppConfig _appConfig = AppConfig();

  Future<AppConfig> get appConfig => _assureOpen(_appConfig);

  @PostConstruct(preResolve: true)
  Future<void> init() async {
    final configDirPath = await _pathProvider.configDir.then((dir) => dir.path);
    Hive.init(configDirPath);
  }

  Future<T> _assureOpen<T extends ConfigStore>(T store) async {
    if (!store.isOpen) {
      await store.open();
    }
    return store;
  }
}
