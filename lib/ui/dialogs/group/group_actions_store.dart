import 'dart:ui';

import 'package:injectable/injectable.dart';
import 'package:kanban/core/logger/logger.dart';
import 'package:kanban/data/kanban_repository.dart';
import 'package:kanban/data/model/async/async_result.dart';
import 'package:kanban/di/scopes/board_screen_scope.dart';
import 'package:kanban/style/colors.dart';
import 'package:kanban/ui/widgets/textfield/text_field_state.dart';
import 'package:mobx/mobx.dart';

part 'group_actions_store.g.dart';

@injectable
@boardScreenScope
class GroupActionsStore = _GroupActionsStore with _$GroupActionsStore;

abstract class _GroupActionsStore with Store {
  _GroupActionsStore(this._repo);

  final KRepository _repo;

  final TextFieldStateStore nameState = TextFieldStateStore(validator: notBlankValidator);

  @readonly
  Color _selectedColor = LabelColors.defaultColor;

  @computed
  bool get validInputs => nameState.isValid;

  @readonly
  AsyncResult4<void> _status = const AsyncResult4.idle();

  @action
  void setSelectedColor(Color color) {
    _selectedColor = color;
  }

  Future<void> createGroup(String boardId) async {
    return _run(() => _repo.createGroup(boardId, nameState.text, _selectedColor.value));
  }

  Future<void> updateGroup(String groupId, String boardId) {
    return _run(() => _repo.updateGroup(groupId, boardId, nameState.text, _selectedColor.value));
  }

  @action
  Future<void> _run<T>(Future<void> Function() action) async {
    if (_status.isLoading || !validInputs) {
      return;
    }
    _status = const AsyncResult4.loading();
    try {
      _status = AsyncResult4.success(await action());
    } catch (e, s) {
      logger.e('Error executing group action', e, s);
      _status = AsyncResult4.error(e, s);
    }
  }
}
