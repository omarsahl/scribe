import 'package:kanban/data/entity/board_entity.dart';
import 'package:kanban/data/entity/member_entity.dart';
import 'package:kanban/data/entity/task_entity.dart';
import 'package:kanban/data/entity/task_group_entity.dart';
import 'package:meta/meta.dart';

@immutable
class BoardDetails {
  const BoardDetails(this.board, this.members);

  final KBoard board;
  final Map<String, KMember> members;
}

@immutable
class GroupDetails {
  const GroupDetails(this.group, this.board, this.tasks);

  final KTaskGroup group;
  final List<KTask> tasks;
  final BoardDetails board;
}

@immutable
class TaskDetails {
  const TaskDetails(this.task, this.group, this.boardDetails);

  final KTask task;
  final KTaskGroup group;
  final BoardDetails boardDetails;
}
