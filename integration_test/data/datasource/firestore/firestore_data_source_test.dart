import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanban/auth/auth_manager.dart';
import 'package:kanban/data/datasource/data_source.dart';
import 'package:kanban/data/datasource/firestore/firestore_data_source.dart';
import 'package:kanban/data/entity/board_entity.dart';
import 'package:kanban/data/entity/member_entity.dart';
import 'package:kanban/data/entity/task_entity.dart';
import 'package:kanban/data/entity/task_group_entity.dart';
import 'package:kanban/data/entity/user_entity.dart';
import 'package:kanban/firebase/firebase_initializer.dart';
import 'package:kanban/utils/datetime/date_time_utils.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'firestore_data_source_test.mocks.dart';

class FakeEntityHelper {
  static const _groupNames = ['Backlog', 'Design', 'To Do', 'Doing', 'Code Review', 'Testing', 'Done'];

  static const String currentUserUid = 'omar-sahl-b4c86a75-9339-74ba-8df5-132a836107f7';
  static const KUser currentUser = KUser(currentUserUid, 'Omar Sahl', 'omarsahl@mail.com', null, []);

  static const String otherUserUid = 'jack-sparrow-b4c86a75-9339-74ba-8df5-132a836107f7';
  static const KUser otherUser = KUser(otherUserUid, 'Jack Sparrow', 'jacksparrow@potc.io', null, []);

  static final KMember currentMember = currentUser.toMember();

  FakeEntityHelper(this._ds);

  final KDataSource _ds;

  int color() => faker.randomGenerator.element(Colors.primaries).shade500.value;

  String emoji() => 'U+${faker.randomGenerator.fromPattern(['#####'])}';

  String boardName() => faker.company.name();

  String boardDescription() => faker.lorem.sentences(faker.randomGenerator.integer(5)).join(' ');

  String groupName() => faker.randomGenerator.element(_groupNames);

  String taskName() => '${faker.color.color()} Task';

  String taskContent() => faker.lorem.words(faker.randomGenerator.integer(30)).join(' ');

  String memberId() => faker.guid.guid();

  String memberName() => faker.person.name();

  FutureOr<KUser> createCurrentUser([List<String> boards = const []]) async {
    await _ds.deleteUser(currentUser.uid);
    return _ds.createUser(
      currentUser.copyWith(boards: boards),
    );
  }

  FutureOr<KUser> createOtherUser([List<String> boards = const []]) async {
    await _ds.deleteUser(currentUser.uid);
    return _ds.createUser(
      otherUser.copyWith(boards: boards),
    );
  }

  FutureOr<KBoard> createFakeBoard() {
    final model = KBoardCreateModel(
      name: boardName(),
      description: boardDescription(),
      adminUid: FakeEntityHelper.currentUserUid,
      members: const [FakeEntityHelper.currentUserUid],
      emoji: emoji(),
    );
    return _ds.createBoard(model);
  }

  FutureOr<KTaskGroup> createFakeGroup() async {
    final board = await createFakeBoard();
    final model = KTaskGroupCreateModel(
      boardId: board.id,
      name: groupName(),
      color: color(),
    );
    return _ds.createGroup(model);
  }

  Future<KTask> createFakeTask() async {
    final group = await createFakeGroup();
    final model = KTaskCreateModel(
      name: taskName(),
      content: taskContent(),
      groupId: group.id,
      boardId: group.boardId,
      creatorUid: FakeEntityHelper.currentUserUid,
    );
    return _ds.createTask(model);
  }
}

@GenerateMocks([AuthManager])
void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer.instance.initialize();

  final db = FirebaseFirestore.instance;

  tearDown(() async {
    await db.terminate();
    await db.clearPersistence();
  });

  test('test createBoard', () async {
    final authManager = MockAuthManager();
    final FirestoreDataSource dataSource = FirestoreDataSource(db);

    when(authManager.currentUser).thenReturn(FakeEntityHelper.currentUser);

    final model = KBoardCreateModel(
      name: 'Test Board $utcMillis',
      description: faker.lorem.sentence(),
      adminUid: FakeEntityHelper.currentUserUid,
      members: const [FakeEntityHelper.currentUserUid],
      emoji: 'U+1F600',
    );
    final expected = await dataSource.createBoard(model);
    final doc = await db.collection('boards').doc(expected.id).get();
    final actual = KBoardMapper.fromMap(doc.data()!);

    expect(actual.id, equals(doc.id));
    expect(actual.adminUid, equals(FakeEntityHelper.currentUserUid));
    expect(actual.createdAt, lessThanOrEqualTo(utcMillis));

    expect(actual, equals(expected));
    expect(actual.id, equals(expected.id));
    expect(actual.name, equals(expected.name));
    expect(actual.description, equals(expected.description));
    expect(actual.emoji, equals(expected.emoji));
  });

  test('test updateBoard', () async {
    final authManager = MockAuthManager();
    final FirestoreDataSource dataSource = FirestoreDataSource(db);
    final entityHelper = FakeEntityHelper(dataSource);

    when(authManager.currentUser).thenReturn(FakeEntityHelper.currentUser);

    final randomBoard = await entityHelper.createFakeBoard();
    var doc = await db.collection('boards').doc(randomBoard.id).get();
    final oldBoard = KBoardMapper.fromMap(doc.data()!);

    expect(oldBoard.id, equals(doc.id));
    expect(oldBoard.name, equals(randomBoard.name));
    expect(oldBoard.description, equals(randomBoard.description));
    expect(oldBoard.emoji, equals(randomBoard.emoji));
    expect(oldBoard.adminUid, equals(FakeEntityHelper.currentUserUid));

    final updateModel = KBoardUpdateModel(name: entityHelper.boardName());
    await dataSource.updateBoard(oldBoard.id, updateModel);
    doc = await db.collection('boards').doc(oldBoard.id).get();
    final newBoard = KBoardMapper.fromMap(doc.data()!);

    expect(newBoard.id, equals(oldBoard.id));
    expect(newBoard.name, equals(updateModel.name));
    expect(newBoard.description, equals(oldBoard.description));
    expect(newBoard.emoji, isNotNull);
    expect(newBoard.adminUid, equals(FakeEntityHelper.currentUserUid));
  });

  test('test deleteBoard', () async {
    final authManager = MockAuthManager();
    final FirestoreDataSource dataSource = FirestoreDataSource(db);
    final entityHelper = FakeEntityHelper(dataSource);

    when(authManager.currentUser).thenReturn(FakeEntityHelper.currentUser);

    final randomBoard = await entityHelper.createFakeBoard();
    var doc = await db.collection('boards').doc(randomBoard.id).get();
    expect(doc.exists, isTrue);

    await Future.delayed(const Duration(seconds: 5));

    await dataSource.deleteBoard(randomBoard.id);
    doc = await db.collection('boards').doc(randomBoard.id).get();
    expect(doc.exists, isFalse);
  });

  test('test createGroup', () async {
    final authManager = MockAuthManager();
    final FirestoreDataSource dataSource = FirestoreDataSource(db);
    final entityHelper = FakeEntityHelper(dataSource);

    when(authManager.currentUser).thenReturn(FakeEntityHelper.currentUser);

    final board = await entityHelper.createFakeBoard();
    final model = KTaskGroupCreateModel(
      boardId: board.id,
      name: entityHelper.groupName(),
      color: entityHelper.color(),
    );
    final expected = await dataSource.createGroup(model);

    final doc = await db.collection('boards').doc(board.id).collection('groups').doc(expected.id).get();
    final actual = KTaskGroupMapper.fromMap(doc.data()!);

    expect(actual.id, equals(doc.id));
    expect(actual.boardId, equals(board.id));
    expect(actual.createdAt, lessThanOrEqualTo(utcMillis));

    expect(actual, equals(expected));
    expect(actual.id, equals(expected.id));
    expect(actual.boardId, equals(expected.boardId));
    expect(actual.name, equals(expected.name));
    expect(actual.color, equals(expected.color));
  });

  test('test updateGroup', () async {
    final authManager = MockAuthManager();
    final FirestoreDataSource dataSource = FirestoreDataSource(db);
    final entityHelper = FakeEntityHelper(dataSource);

    when(authManager.currentUser).thenReturn(FakeEntityHelper.currentUser);

    final group = await entityHelper.createFakeGroup();
    var doc = await db.collection('boards').doc(group.boardId).collection('groups').doc(group.id).get();
    final oldGroup = KTaskGroupMapper.fromMap(doc.data()!);
    expect(oldGroup.id, equals(doc.id));
    expect(oldGroup.createdAt, lessThanOrEqualTo(utcMillis));

    expect(oldGroup, equals(group));
    expect(oldGroup.id, equals(group.id));
    expect(oldGroup.boardId, equals(group.boardId));
    expect(oldGroup.name, equals(group.name));
    expect(oldGroup.color, equals(group.color));

    const updateModel = KTaskGroupUpdateModel(name: 'New Group Name');
    await dataSource.updateGroup(group.id, group.boardId, updateModel);
    doc = await db.collection('boards').doc(group.boardId).collection('groups').doc(group.id).get();
    final newGroup = KTaskGroupMapper.fromMap(doc.data()!);

    expect(newGroup, equals(oldGroup));
    expect(newGroup.id, equals(oldGroup.id));
    expect(newGroup.color, equals(oldGroup.color));
    expect(newGroup.boardId, equals(oldGroup.boardId));
    expect(newGroup.createdAt, equals(oldGroup.createdAt));

    expect(newGroup.name == group.name, isFalse);
    expect(newGroup.name, equals(updateModel.name));
  });

  test('test deleteGroup', () async {
    final authManager = MockAuthManager();
    final FirestoreDataSource dataSource = FirestoreDataSource(db);
    final entityHelper = FakeEntityHelper(dataSource);

    when(authManager.currentUser).thenReturn(FakeEntityHelper.currentUser);

    final group = await entityHelper.createFakeGroup();
    var doc = await db.collection('boards').doc(group.boardId).collection('groups').doc(group.id).get();
    expect(doc.exists, isTrue);

    await Future.delayed(const Duration(seconds: 3));

    await dataSource.deleteGroup(group);
    doc = await db.collection('boards').doc(group.boardId).collection('groups').doc(group.id).get();
    expect(doc.exists, isFalse);
  });

  test('test createTask', () async {
    final authManager = MockAuthManager();
    final FirestoreDataSource dataSource = FirestoreDataSource(db);
    final entityHelper = FakeEntityHelper(dataSource);

    when(authManager.currentUser).thenReturn(FakeEntityHelper.currentUser);

    final group = await entityHelper.createFakeGroup();
    final model = KTaskCreateModel(
      name: entityHelper.taskName(),
      content: entityHelper.taskContent(),
      groupId: group.id,
      boardId: group.boardId,
      creatorUid: FakeEntityHelper.currentUserUid,
    );
    final expected = await dataSource.createTask(model);

    final doc = await db.collection('boards').doc(group.boardId).collection('tasks').doc(expected.id).get();
    final actual = KTaskMapper.fromMap(doc.data()!);

    expect(actual.id, equals(doc.id));
    expect(actual.groupId, equals(group.id));
    expect(actual.boardId, equals(group.boardId));
    expect(actual.createdAt, lessThanOrEqualTo(utcMillis));
    expect(actual.members, isEmpty);
    expect(expected.members, isEmpty);
    expect(actual.completedAt, isNull);
    expect(expected.completedAt, isNull);
    expect(actual.updatedAt, equals(actual.createdAt));
    expect(expected.updatedAt, equals(expected.createdAt));
    expect(actual.createdBy, equals(FakeEntityHelper.currentMember.uid));
    expect(expected.createdBy, equals(FakeEntityHelper.currentMember.uid));
    expect(actual.timerStart, isNull);
    expect(expected.timerStart, isNull);
    expect(actual.timerEnd, isNull);
    expect(expected.timerEnd, isNull);
    expect(actual.timerTotal, isNull);
    expect(expected.timerTotal, isNull);

    expect(actual, equals(expected));
    expect(actual.id, equals(expected.id));
    expect(actual.groupId, equals(expected.groupId));
    expect(actual.boardId, equals(expected.boardId));
    expect(actual.name, equals(expected.name));
    expect(actual.content, equals(expected.content));
    expect(actual.createdAt, equals(expected.createdAt));
    expect(actual.completedAt, equals(expected.completedAt));
    expect(actual.createdBy, equals(expected.createdBy));
    expect(actual.updatedAt, equals(expected.updatedAt));
    expect(actual.timerStart, equals(expected.timerStart));
    expect(actual.timerEnd, equals(expected.timerEnd));
    expect(actual.timerTotal, equals(expected.timerTotal));
  });

  test('test updateTask', () async {
    final authManager = MockAuthManager();
    final FirestoreDataSource dataSource = FirestoreDataSource(db);
    final entityHelper = FakeEntityHelper(dataSource);

    when(authManager.currentUser).thenReturn(FakeEntityHelper.currentUser);

    final task = await entityHelper.createFakeTask();
    await Future.delayed(const Duration(milliseconds: 500));
    var doc = await db.collection('boards').doc(task.boardId).collection('tasks').doc(task.id).get();
    final oldTask = KTaskMapper.fromMap(doc.data()!);

    expect(oldTask.id, equals(doc.id));
    expect(oldTask.createdAt, lessThanOrEqualTo(utcMillis));
    expect(oldTask.members, isEmpty);
    expect(task.members, isEmpty);
    expect(oldTask.completedAt, isNull);
    expect(task.completedAt, isNull);
    expect(oldTask.updatedAt, equals(oldTask.createdAt));
    expect(oldTask.createdBy, equals(FakeEntityHelper.currentMember.uid));
    expect(task.createdBy, equals(FakeEntityHelper.currentMember.uid));
    expect(oldTask.timerStart, isNull);
    expect(task.timerStart, isNull);
    expect(oldTask.timerEnd, isNull);
    expect(task.timerEnd, isNull);
    expect(oldTask.timerTotal, isNull);
    expect(task.timerTotal, isNull);

    expect(oldTask, equals(task));
    expect(oldTask.id, equals(task.id));
    expect(oldTask.groupId, equals(task.groupId));
    expect(oldTask.boardId, equals(task.boardId));
    expect(oldTask.name, equals(task.name));
    expect(oldTask.content, equals(task.content));
    expect(oldTask.createdAt, equals(task.createdAt));
    expect(oldTask.completedAt, equals(task.completedAt));
    expect(oldTask.createdBy, equals(task.createdBy));
    expect(oldTask.updatedAt, equals(task.updatedAt));
    expect(oldTask.timerStart, equals(task.timerStart));
    expect(oldTask.timerEnd, equals(task.timerEnd));
    expect(oldTask.timerTotal, equals(task.timerTotal));

    final model = KTaskUpdateModel(
      content: entityHelper.taskContent(),
      completedAt: utcMillis + const Duration(hours: 1).inMilliseconds,
    );
    await dataSource.updateTask(task.id, task.boardId, model);
    doc = await db.collection('boards').doc(task.boardId).collection('tasks').doc(task.id).get();
    final newTask = KTaskMapper.fromMap(doc.data()!);

    expect(newTask.content, equals(model.content));
    expect(newTask.completedAt, equals(model.completedAt));
    expect(newTask.updatedAt, greaterThan(newTask.createdAt));
    expect(newTask.updatedAt, greaterThan(oldTask.updatedAt));
    expect(newTask.updatedAt, lessThanOrEqualTo(utcMillis));
    expect(newTask.members, isEmpty);

    expect(newTask, equals(oldTask));
    expect(newTask.id, equals(oldTask.id));
    expect(newTask.name, equals(oldTask.name));
    expect(newTask.groupId, equals(oldTask.groupId));
    expect(newTask.boardId, equals(oldTask.boardId));
    expect(newTask.createdAt, equals(oldTask.createdAt));
    expect(newTask.createdBy, equals(oldTask.createdBy));
    expect(newTask.timerStart, equals(oldTask.timerStart));
    expect(newTask.timerEnd, equals(oldTask.timerEnd));
    expect(newTask.timerTotal, equals(oldTask.timerTotal));
  });

  test('test archiveTask', () async {
    final authManager = MockAuthManager();
    final FirestoreDataSource dataSource = FirestoreDataSource(db);
    final entityHelper = FakeEntityHelper(dataSource);

    when(authManager.currentUser).thenReturn(FakeEntityHelper.currentUser);

    final task = await entityHelper.createFakeTask();
    var doc = await db.collection('boards').doc(task.boardId).collection('tasks').doc(task.id).get();
    final taskInOriginalGroup = KTaskMapper.fromMap(doc.data()!);
    expect(taskInOriginalGroup.boardId, equals(task.boardId));
    expect(taskInOriginalGroup.groupId, equals(task.groupId));

    await Future.delayed(const Duration(seconds: 5));

    await dataSource.archiveTask(taskInOriginalGroup);
    doc = await db.collection('boards').doc(task.boardId).collection('tasks').doc(task.id).get();
    final taskInArchive = KTaskMapper.fromMap(doc.data()!);
    expect(taskInArchive.boardId, equals(taskInOriginalGroup.boardId));
    expect(taskInArchive.groupId, equals(dataSource.getArchiveGroupId(taskInOriginalGroup.boardId)));
  });

  test('test addBoardMember', () async {
    final authManager = MockAuthManager();
    final FirestoreDataSource dataSource = FirestoreDataSource(db);
    final entityHelper = FakeEntityHelper(dataSource);

    when(authManager.currentUser).thenReturn(FakeEntityHelper.currentUser);

    final board = await entityHelper.createFakeBoard();
    final admin = await entityHelper.createCurrentUser([board.id]);
    final member = await entityHelper.createOtherUser();
    await dataSource.addBoardMember(board, member.uid);

    final boardDoc = await db.collection('boards').doc(board.id).get();
    final actualBoard = KBoardMapper.fromMap(boardDoc.data()!);
    expect(actualBoard.adminUid, equals(admin.uid));
    expect(actualBoard.members, containsAll([admin.uid, member.uid]));

    final adminDoc = await db.collection('users').doc(admin.uid).get();
    final actualAdmin = KUserMapper.fromMap(adminDoc.data()!);
    expect(actualAdmin.uid, equals(admin.uid));
    expect(actualAdmin.boards, contains(board.id));

    final memberDoc = await db.collection('users').doc(member.uid).get();
    final actualMember = KUserMapper.fromMap(memberDoc.data()!);
    expect(actualMember.uid, equals(member.uid));
    expect(actualMember.boards, contains(board.id));
  });

  test('test removeBoardMember', () async {
    final authManager = MockAuthManager();
    final FirestoreDataSource dataSource = FirestoreDataSource(db);
    final entityHelper = FakeEntityHelper(dataSource);

    when(authManager.currentUser).thenReturn(FakeEntityHelper.currentUser);

    final board = await entityHelper.createFakeBoard();
    final admin = await entityHelper.createCurrentUser([board.id]);
    final member = await entityHelper.createOtherUser();
    await dataSource.addBoardMember(board, member.uid);

    var boardDoc = await db.collection('boards').doc(board.id).get();
    var actualBoard = KBoardMapper.fromMap(boardDoc.data()!);
    expect(actualBoard.adminUid, equals(admin.uid));
    expect(actualBoard.members, containsAll([admin.uid, member.uid]));

    var adminDoc = await db.collection('users').doc(admin.uid).get();
    var actualAdmin = KUserMapper.fromMap(adminDoc.data()!);
    expect(actualAdmin.uid, equals(admin.uid));
    expect(actualAdmin.boards, contains(board.id));

    var memberDoc = await db.collection('users').doc(member.uid).get();
    var actualMember = KUserMapper.fromMap(memberDoc.data()!);
    expect(actualMember.uid, equals(member.uid));
    expect(actualMember.boards, contains(board.id));

    await dataSource.removeBoardMember(board.id, member.uid);

    boardDoc = await db.collection('boards').doc(board.id).get();
    actualBoard = KBoardMapper.fromMap(boardDoc.data()!);
    expect(actualBoard.adminUid, equals(admin.uid));
    expect(actualBoard.members, contains([admin.uid]));
    expect(actualBoard.members.contains(member.uid), isFalse);

    adminDoc = await db.collection('users').doc(admin.uid).get();
    actualAdmin = KUserMapper.fromMap(adminDoc.data()!);
    expect(actualAdmin.uid, equals(admin.uid));
    expect(actualAdmin.boards, contains(board.id));

    memberDoc = await db.collection('users').doc(member.uid).get();
    actualMember = KUserMapper.fromMap(memberDoc.data()!);
    expect(actualMember.uid, equals(member.uid));
    expect(actualMember.boards.contains(board.id), isFalse);
  });
}
