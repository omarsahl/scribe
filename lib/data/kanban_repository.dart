import 'package:injectable/injectable.dart';
import 'package:kanban/auth/auth_manager.dart';
import 'package:kanban/data/datasource/data_source.dart';
import 'package:kanban/data/entity/board_entity.dart';
import 'package:kanban/data/entity/member_entity.dart';
import 'package:kanban/data/entity/task_entity.dart';
import 'package:kanban/data/entity/task_group_entity.dart';
import 'package:kanban/utils/datetime/date_time_utils.dart';

@singleton
class KRepository {
  KRepository(this._authManager, this._dataSource);

  final KDataSource _dataSource;
  final AuthManager _authManager;

  String get _currentUid => _authManager.currentUser.uid;

  Stream<List<KBoard>> getAllBoards() => _dataSource.getUserBoards(_currentUid);

  Stream<KBoard> getBoard(String id) => _dataSource.getBoard(id);

  Stream<Map<String, KMember>> getBoardMembers(String boardId) => _dataSource.getBoardMembers(boardId);

  Stream<List<KTaskGroup>> getBoardGroups(String boardId) => _dataSource.getBoardGroups(boardId);

  Stream<KTaskGroup> getGroup(String groupId, String boardId) => _dataSource.getGroup(groupId, boardId);

  Stream<List<KTask>> getGroupTasks(String boardId, String groupId) =>
      _dataSource.getGroupTasks(boardId, groupId);

  Stream<List<KTask>> getCompletedTasks(String boardId) => _dataSource.getCompletedTasks(boardId);

  Future<void> createBoard(String name, String description) async {
    await _dataSource.createBoard(
      KBoardCreateModel(
        name: name,
        description: description,
        adminUid: _currentUid,
        members: [_currentUid],
      ),
    );
  }

  Future<void> createGroup(String boardId, String name, int color) async {
    await _dataSource.createGroup(
      KTaskGroupCreateModel(
        boardId: boardId,
        name: name,
        color: color,
      ),
    );
  }

  Future<void> updateGroup(String groupId, String boardId, String name, int color) async {
    await _dataSource.updateGroup(
      groupId,
      boardId,
      KTaskGroupUpdateModel(name: name, color: color),
    );
  }

  Stream<KTask> getTask(String taskId, String boardId) => _dataSource.getTask(taskId, boardId);

  Future<void> createTask({
    required String groupId,
    required String boardId,
    required String name,
    required String content,
  }) async {
    await _dataSource.createTask(
      KTaskCreateModel(
        name: name,
        content: content,
        groupId: groupId,
        boardId: boardId,
        creatorUid: _currentUid,
      ),
    );
  }

  Future<void> updateTask({
    required String taskId,
    required String boardId,
    String? name,
    String? content,
    bool? complete,
  }) async {
    await _dataSource.updateTask(
      taskId,
      boardId,
      KTaskUpdateModel(
        name: name,
        content: content,
        completedAt: complete != null && complete ? utcMillis : null,
      ),
    );
  }

  Future<void> moveTask(KTask task, String newGroupId) async {
    await _dataSource.updateTask(
      task.id,
      task.boardId,
      KTaskUpdateModel(groupId: newGroupId),
    );
  }

  Future<bool> toggleTaskTimer(KTask task) async => _dataSource.toggleTaskTimer(task.id, task.boardId);
}
