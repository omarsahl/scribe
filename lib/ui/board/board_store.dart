import 'package:injectable/injectable.dart';
import 'package:kanban/data/entity/task_group_entity.dart';
import 'package:kanban/data/kanban_repository.dart';
import 'package:kanban/data/model/kanban.dart';
import 'package:kanban/di/scopes/board_screen_scope.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';

part 'board_store.g.dart';

@singleton
@boardScreenScope
class BoardStore = _BoardStore with _$BoardStore;

abstract class _BoardStore with Store {
  _BoardStore(this._repo);

  final KRepository _repo;
  late final String boardId;

  late final Stream<BoardDetails> _boardDetailsStream = Rx.combineLatest2(
    _repo.getBoard(boardId),
    _repo.getBoardMembers(boardId),
    (board, members) => BoardDetails(board, members),
  ).publishValue().autoConnect();

  late final ObservableStream<BoardDetails> boardDetailsStream = ObservableStream(_boardDetailsStream);
  late final ObservableStream<List<KTaskGroup>> taskGroups = ObservableStream(_repo.getBoardGroups(boardId));

  void init(String id) {
    boardId = id;
  }

  ObservableStream<GroupDetails> getGroupDetails(String groupId, String boardId) {
    return ObservableStream(
      Rx.combineLatest3(
        _boardDetailsStream,
        _repo.getGroup(groupId, boardId),
        _repo.getGroupTasks(boardId, groupId),
        (board, group, tasks) => GroupDetails(group, board, tasks),
      ),
    );
  }
}
