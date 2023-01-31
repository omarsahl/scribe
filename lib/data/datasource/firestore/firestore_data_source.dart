import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:kanban/data/datasource/data_source.dart';
import 'package:kanban/data/entity/board_entity.dart';
import 'package:kanban/data/entity/member_entity.dart';
import 'package:kanban/data/entity/task_entity.dart';
import 'package:kanban/data/entity/task_group_entity.dart';
import 'package:kanban/data/entity/user_entity.dart';
import 'package:kanban/exceptions/data_exception.dart';
import 'package:kanban/exceptions/users_excpetion.dart';
import 'package:kanban/utils/datetime/date_time_utils.dart';
import 'package:kanban/utils/firebase/firestore_utils.dart';

@Singleton(as: KDataSource)
class FirestoreDataSource extends KDataSource {
  FirestoreDataSource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<KUser> get _users => _db.collection('users').withGenericConverter();

  DocumentReference<KUser> _user(String uid) => _users.doc(uid);

  CollectionReference<KBoard> get _boards => _db.collection('boards').withGenericConverter();

  DocumentReference<KBoard> _board(String boardId) => _boards.doc(boardId);

  CollectionReference<KTaskGroup> _groups(String boardId) =>
      _board(boardId).collection('groups').withGenericConverter();

  CollectionReference<KTask> _tasks(String boardId) =>
      _board(boardId).collection('tasks').withGenericConverter();

  @override
  Future<KUser> createUser(KUser user) async {
    final docRef = _users.doc(user.uid);
    final doc = await docRef.get();
    if (doc.exists) {
      return doc.data()!;
    }
    await docRef.set(user);
    return user;
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _users.doc(uid).delete();
  }

  @override
  Stream<KUser> getUser(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      final user = snapshot.data();
      if (user == null) {
        throw UserNotFoundException(uid);
      }
      return user;
    });
  }

  @override
  Future<void> updateUser(String uid, KUserUpdateModel model) async {
    await _users.doc(uid).update(model.toMap());
  }

  @override
  String getArchiveGroupId(String boardId) => _groups(boardId).doc('<archive>@$boardId').id;

  @override
  Future<KBoard> createBoard(KBoardCreateModel model) async {
    final doc = _boards.doc();
    final data = KBoard(
      doc.id,
      model.name,
      model.description,
      model.adminUid,
      model.members,
      model.emoji,
      utcMillis,
    );
    await doc.set(data);
    return data;
  }

  @override
  Future<void> updateBoard(String id, KBoardUpdateModel model) async {
    await _boards.doc(id).update(model.toMap());
  }

  @override
  Future<void> deleteBoard(String id) async {
    await _boards.doc(id).delete();
  }

  @override
  Stream<List<KBoard>> getUserBoards(String uid) {
    return _boards
        .where('members', arrayContains: uid)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshots) => snapshots.docs)
        .map((docs) => docs.map((doc) => doc.data()).toList());
  }

  @override
  Stream<KBoard> getBoard(String id) {
    return _board(id).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) {
        throw EntityNotFoundException(id, KBoard);
      }
      return data;
    });
  }

  @override
  Future<KTaskGroup> createGroup(KTaskGroupCreateModel model) async {
    final doc = _groups(model.boardId).doc();
    final data = KTaskGroup(doc.id, model.boardId, model.name, model.color, utcMillis, 0);
    await doc.set(data);
    return data;
  }

  @override
  Stream<KTaskGroup> getGroup(String groupId, String boardId) {
    return _groups(boardId).doc(groupId).snapshots().map((snapshot) {
      final group = snapshot.data();
      if (group == null) {
        throw EntityNotFoundException(groupId, KTaskGroup);
      }
      return group;
    });
  }

  @override
  Stream<List<KTaskGroup>> getBoardGroups(String boardId) {
    return _groups(boardId)
        .orderBy('created_at')
        .snapshots()
        .map((snapshots) => snapshots.docs)
        .map((docs) => docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<void> updateGroup(String groupId, String boardId, KTaskGroupUpdateModel model) async {
    await _groups(boardId).doc(groupId).update(model.toMap());
  }

  @override
  Future<void> deleteGroup(KTaskGroup group) async {
    await _groups(group.boardId).doc(group.id).delete();
  }

  @override
  Future<KTask> createTask(KTaskCreateModel model) async {
    final groupDocRef = _groups(model.boardId).doc(model.groupId);
    final groupDoc = await groupDocRef.get();
    final group = groupDoc.data();
    if (group == null) {
      throw EntityNotFoundException(model.groupId, KTaskGroup);
    }
    final order = group.lastTaskOrder + 1;
    final doc = _tasks(model.boardId).doc();
    final timestamp = utcMillis;
    final data = KTask(doc.id, model.name, model.content, order, const [], model.groupId, model.boardId,
        timestamp, null, model.creatorUid, timestamp, null, null, null);
    final batch = _db.batch();
    batch.set(doc, data);
    batch.update(groupDocRef, {'last_task_order': order});
    await batch.commit();
    return data;
  }

  @override
  Stream<KTask> getTask(String taskId, String boardId) {
    return _tasks(boardId).doc(taskId).snapshots().map((snapshot) {
      final task = snapshot.data();
      if (task == null) {
        throw EntityNotFoundException(taskId, KTask);
      }
      return task;
    });
  }

  @override
  Future<void> updateTask(String taskId, String boardId, KTaskUpdateModel updateModel) async {
    updateModel = updateModel.copyWith(
      updatedAt: utcMillis,
    );
    await _tasks(boardId).doc(taskId).update(updateModel.toMap());
  }

  @override
  Future<bool> toggleTaskTimer(String taskId, String boardId) {
    final docRef = _tasks(boardId).doc(taskId);
    return _db.runTransaction((transaction) async {
      final taskDoc = await transaction.get(docRef);
      final task = taskDoc.data();
      if (task == null) {
        throw EntityNotFoundException(taskId, KTask);
      }
      final totalTime = task.timerTotal;
      final timerStart = task.timerStart;
      if (timerStart != null) {
        transaction.update(docRef, {
          'timer_start': null,
          'timer_total': (totalTime ?? 0) + (utcMillis - timerStart),
        });
        return false;
      } else {
        transaction.update(docRef, {
          'timer_start': utcMillis,
        });
        return true;
      }
    });
  }

  @override
  Future<void> archiveTask(KTask task) async {
    final archiveId = getArchiveGroupId(task.boardId);
    await _tasks(task.boardId).doc(task.id).update({'group_id': archiveId});
  }

  @override
  Stream<List<KTask>> getGroupTasks(String boardId, String groupId) {
    return _tasks(boardId)
        .where('group_id', isEqualTo: groupId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshots) => snapshots.docs)
        .map((docs) => docs.map((doc) => doc.data()).toList());
  }

  @override
  Stream<List<KTask>> getCompletedTasks(String boardId) {
    return _tasks(boardId)
        .where('completed_at', isGreaterThan: 0)
        .orderBy('completed_at', descending: true)
        .snapshots()
        .map((snapshots) => snapshots.docs)
        .map((docs) => docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<void> addBoardMember(KBoard board, String uid) async {
    final batch = _db.batch();
    batch.update(_board(board.id), {
      'members': FieldValue.arrayUnion([uid]),
    });
    batch.update(_user(uid), {
      'boards': FieldValue.arrayUnion([board.id]),
    });
    await batch.commit();
  }

  @override
  Future<void> removeBoardMember(String boardId, String uid) async {
    final batch = _db.batch();
    batch.update(_board(boardId), {
      'members': FieldValue.arrayRemove([uid]),
    });
    batch.update(_user(uid), {
      'boards': FieldValue.arrayRemove([boardId]),
    });
    await batch.commit();
  }

  @override
  Stream<Map<String, KMember>> getBoardMembers(String boardId) {
    return _users
        .where('boards', arrayContains: boardId)
        .orderBy('name')
        .snapshots()
        .map((snapshots) => snapshots.docs)
        .map(_createMembersMap);
  }

  Map<String, KMember> _createMembersMap(List<QueryDocumentSnapshot<KUser>> docs) {
    return Map.fromEntries(
      docs.map((doc) {
        final user = doc.data();
        return MapEntry(user.uid, user.toMember());
      }),
    );
  }
}
