import 'dart:async';

import 'package:kanban/data/entity/board_entity.dart';
import 'package:kanban/data/entity/member_entity.dart';
import 'package:kanban/data/entity/task_entity.dart';
import 'package:kanban/data/entity/task_group_entity.dart';
import 'package:kanban/data/entity/user_entity.dart';

abstract class KDataSource {
  FutureOr<KUser> createUser(KUser user);

  FutureOr<void> deleteUser(String uid);

  Future<void> updateUser(String uid, KUserUpdateModel model);

  Stream<KUser> getUser(String uid);

  String getArchiveGroupId(String boardId);

  FutureOr<KBoard> createBoard(KBoardCreateModel model);

  Stream<KBoard> getBoard(String id);

  Stream<List<KBoard>> getUserBoards(String uid);

  Future<List<KTask>> getBoardTasks(String boardId);

  FutureOr<void> updateBoard(String id, KBoardUpdateModel model);

  FutureOr<void> deleteBoard(String id);

  FutureOr<KTaskGroup> createGroup(KTaskGroupCreateModel model);

  Stream<KTaskGroup> getGroup(String groupId, String boardId);

  Stream<List<KTaskGroup>> getBoardGroups(String boardId);

  FutureOr<void> updateGroup(String groupId, String boardId, KTaskGroupUpdateModel model);

  FutureOr<void> deleteGroup(KTaskGroup group);

  FutureOr<KTask> createTask(KTaskCreateModel model);

  Stream<KTask> getTask(String taskId, String boardId);

  Stream<List<KTask>> getGroupTasks(String boardId, String groupId);

  Stream<List<KTask>> getCompletedTasks(String boardId);

  FutureOr<void> updateTask(String taskId, String boardId, KTaskUpdateModel updateModel);

  FutureOr<bool> toggleTaskTimer(String taskId, String boardId);

  FutureOr<void> archiveTask(KTask task);

  FutureOr<void> addBoardMember(KBoard board, String uid);

  FutureOr<void> removeBoardMember(String boardId, String uid);

  Stream<Map<String, KMember>> getBoardMembers(String boardId);
}
