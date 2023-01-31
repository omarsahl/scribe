import 'package:injectable/injectable.dart';
import 'package:kanban/data/entity/task_entity.dart';
import 'package:kanban/data/kanban_repository.dart';
import 'package:kanban/di/scopes/board_screen_scope.dart';
import 'package:mobx/mobx.dart';

part 'completed_tasks_store.g.dart';

@injectable
@boardScreenScope
class CompletedTaskStore = _CompletedTaskStore with _$CompletedTaskStore;

abstract class _CompletedTaskStore with Store {
  _CompletedTaskStore(this._repo);

  final KRepository _repo;

  ObservableStream<List<KTask>> getCompletedTasks(String boardId) =>
      ObservableStream(_repo.getCompletedTasks(boardId));
}
