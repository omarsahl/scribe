import 'package:injectable/injectable.dart';
import 'package:kanban/core/logger/logger.dart';
import 'package:kanban/data/entity/task_entity.dart';
import 'package:kanban/data/entity/task_group_entity.dart';
import 'package:kanban/data/kanban_repository.dart';
import 'package:kanban/data/model/async/async_result.dart';
import 'package:kanban/di/scopes/board_screen_scope.dart';
import 'package:mobx/mobx.dart';

part 'task_move_store.g.dart';

@injectable
@boardScreenScope
class TaskMoveStore = _TaskMoveStore with _$TaskMoveStore;

abstract class _TaskMoveStore with Store {
  _TaskMoveStore(this._repo);

  final KRepository _repo;

  @readonly
  AsyncResult4<void> _moveStatus = const AsyncResult4.idle();

  ObservableStream<List<KTaskGroup>> getAllGroups(String boardId) =>
      ObservableStream(_repo.getBoardGroups(boardId));

  @action
  Future<void> moveTask(KTask task, String newGroupId) async {
    if (task.groupId == newGroupId) {
      _moveStatus = const AsyncResult4.success(null);
      return;
    }
    if (_moveStatus.isLoading) {
      return;
    }
    _moveStatus = const AsyncResult4.loading();
    try {
      _moveStatus = AsyncResult4.success(await _repo.moveTask(task, newGroupId));
    } catch (e, s) {
      logger.e('Error executing group action', e, s);
      _moveStatus = AsyncResult4.error(e, s);
    }
  }
}
