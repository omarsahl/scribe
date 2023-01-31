import 'package:injectable/injectable.dart';
import 'package:kanban/auth/auth_manager.dart';
import 'package:kanban/config/app_config.dart';
import 'package:mobx/mobx.dart';

part 'settings_store.g.dart';

@singleton
class SettingsStore = _SettingsStore with _$SettingsStore;

abstract class _SettingsStore with Store {
  _SettingsStore(this._authManager, this._appConfig);

  final AuthManager _authManager;
  final AppConfig _appConfig;

  @readonly
  late bool _isDarkTheme = _appConfig.isDarkTheme;

  Future<void> toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    return _appConfig.setIsDarkTheme(_isDarkTheme);
  }

  Future<void> logOut() => _authManager.logOut();
}
