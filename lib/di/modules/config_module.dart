import 'package:injectable/injectable.dart';
import 'package:kanban/config/app_config.dart';
import 'package:kanban/config/config_manager.dart';

@module
abstract class ConfigModule {
  @singleton
  @preResolve
  Future<AppConfig> appConfig(ConfigManager configManager) => configManager.appConfig;
}
