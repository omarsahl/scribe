import 'package:kanban/config/config_store.dart';

class AppConfig extends ConfigStore {
  AppConfig() : super('app_config');

  bool get isDarkTheme => get('is_dark_theme', false);

  Future<void> setIsDarkTheme(bool isDark) => put('is_dark_theme', isDark);
}
