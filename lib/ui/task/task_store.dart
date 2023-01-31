import 'package:injectable/injectable.dart';
import 'package:kanban/core/logger/logger.dart';
import 'package:kanban/data/entity/task_entity.dart';
import 'package:kanban/data/kanban_repository.dart';
import 'package:kanban/data/model/async/async_result.dart';
import 'package:kanban/di/scopes/board_screen_scope.dart';
import 'package:kanban/ui/widgets/textfield/text_field_state.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';

part 'task_store.g.dart';

@injectable
@boardScreenScope
class TaskStore = _TaskStore with _$TaskStore;

abstract class _TaskStore with Store {
  _TaskStore(this._repo);

  late final String _taskId;
  late final String _boardId;

  final TextFieldStateStore nameState = TextFieldStateStore(validator: notBlankValidator);
  final TextFieldStateStore contentState = TextFieldStateStore(validator: noOpValidator);

  final KRepository _repo;

  void init(String taskId, String boardId) {
    _taskId = taskId;
    _boardId = boardId;
  }

  late final Stream<KTask> taskStream = _repo.getTask(_taskId, _boardId).publishValue().autoConnect();

  @computed
  bool get validInputs => nameState.isValid && contentState.isValid;

  @readonly
  AsyncResult4<void> _upsertStatus = const AsyncResult4.idle();

  @readonly
  AsyncResult4<bool> _timerChangesStatus = const AsyncResult4.idle();

  Future<void> createTask(String groupId, String boardId) async {
    return _run(() {
      return _repo.createTask(
        groupId: groupId,
        boardId: boardId,
        name: nameState.text,
        content: contentState.text,
      );
    });
  }

  Future<void> updateTask(String taskId, String boardId, [bool? complete]) {
    return _run(() {
      return _repo.updateTask(
        taskId: taskId,
        boardId: boardId,
        complete: complete,
        name: nameState.text,
        content: contentState.text,
      );
    });
  }

  @action
  Future<void> toggleTimer(KTask task) async {
    _timerChangesStatus = const AsyncResult4.loading();
    try {
      _timerChangesStatus = AsyncResult4.success(await _repo.toggleTaskTimer(task));
    } catch (e, s) {
      logger.e('Error updating task timer', e, s);
      _timerChangesStatus = AsyncResult4.error(e);
    }
  }

  @action
  Future<void> _run<T>(Future<void> Function() action) async {
    if (_upsertStatus.isLoading || !validInputs) {
      return;
    }
    _upsertStatus = const AsyncResult4.loading();
    try {
      _upsertStatus = AsyncResult4.success(await action());
    } catch (e, s) {
      logger.e('Error executing task action', e, s);
      _upsertStatus = AsyncResult4.error(e, s);
    }
  }
}
