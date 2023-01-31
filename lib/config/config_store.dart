import 'package:hive/hive.dart';
import 'package:kanban/exceptions/illegal_state_error.dart';
import 'package:meta/meta.dart';

@immutable
class ConfigEvent {
  const ConfigEvent(this.key, this.value, this.deleted);

  ConfigEvent._fromBoxEvent(BoxEvent event) : this(event.key, event.value, event.deleted);

  final String key;

  final dynamic value;

  final bool deleted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigEvent &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          value == other.value &&
          deleted == other.deleted;

  @override
  int get hashCode => Object.hash(key, value, deleted);
}

abstract class ConfigStore {
  ConfigStore(this.name);

  final String name;

  Box? _delegate;

  Box checkOpened() {
    if (_delegate == null) {
      throw IllegalStateException('open() must be called before using the config store');
    }
    return _delegate!;
  }

  bool get isOpen => _delegate?.isOpen ?? false;

  Future<void> open() async {
    if (isOpen) {
      return;
    }
    _delegate = await Hive.openBox(name);
  }

  Future<void> close() => checkOpened().close();

  Future<void> clear() => checkOpened().clear();

  @protected
  Future<void> put<T>(String key, T value) => checkOpened().put(key, value);

  @protected
  T get<T>(String key, T defaultValue) => checkOpened().get(key, defaultValue: defaultValue);

  @protected
  T? getOrNull<T>(String key, [T? defaultValue]) => checkOpened().get(key, defaultValue: defaultValue);

  @protected
  Future<void> delete(String key) => checkOpened().delete(key);

  Stream<ConfigEvent> watch([String? key]) => checkOpened().watch(key: key).map(ConfigEvent._fromBoxEvent);

  @override
  String toString() => 'ConfigStore($name)';

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigStore && runtimeType == other.runtimeType && name == other.name;
}
