import 'package:dart_mappable/dart_mappable.dart';
import 'package:meta/meta.dart';

part 'task_entity.mapper.dart';

@immutable
@MappableClass()
class KTask with KTaskMappable {
  const KTask(
    this.id,
    this.name,
    this.content,
    this.order,
    this.members,
    this.groupId,
    this.boardId,
    this.createdAt,
    this.completedAt,
    this.createdBy,
    this.updatedAt,
    this.timerStart,
    this.timerEnd,
    this.timerTotal,
  );

  @MappableField(key: 'id')
  final String id;

  @MappableField(key: 'name')
  final String name;

  @MappableField(key: 'content')
  final String content;

  @MappableField(key: 'order')
  final int order;

  @MappableField(key: 'group_id')
  final String groupId;

  @MappableField(key: 'board_id')
  final String boardId;

  @MappableField(key: 'members')
  final List<String> members;

  @MappableField(key: 'created_at')
  final int createdAt;

  @MappableField(key: 'completed_at')
  final int? completedAt;

  @MappableField(key: 'created_by')
  final String createdBy;

  @MappableField(key: 'updated_at')
  final int updatedAt;

  @MappableField(key: 'timer_start')
  final int? timerStart;

  @MappableField(key: 'timer_end')
  final int? timerEnd;

  @MappableField(key: 'timer_total')
  final int? timerTotal;

  bool get isTimerActive => timerStart != null;

  @override
  String toString() => 'KTask($id, $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KTask &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          groupId == other.groupId &&
          boardId == other.boardId;

  @override
  int get hashCode => Object.hash(id, groupId, boardId);
}

@immutable
@MappableClass(
  ignoreNull: true,
  generateMethods: GenerateMethods.encode,
)
class KTaskCreateModel with KTaskCreateModelMappable {
  const KTaskCreateModel({
    required this.name,
    required this.content,
    required this.groupId,
    required this.boardId,
    required this.creatorUid,
  });

  @MappableField(key: 'name')
  final String name;

  @MappableField(key: 'content')
  final String content;

  @MappableField(key: 'group_id')
  final String groupId;

  @MappableField(key: 'board_id')
  final String boardId;

  @MappableField(key: 'creator_uid')
  final String creatorUid;
}

@immutable
@MappableClass(
  ignoreNull: true,
  generateMethods: GenerateMethods.encode | GenerateMethods.copy,
)
class KTaskUpdateModel with KTaskUpdateModelMappable {
  const KTaskUpdateModel({
    this.name,
    this.content,
    this.groupId,
    this.completedAt,
    this.updatedAt,
    this.timerStart,
    this.timerEnd,
    this.timerTotal,
  });

  @MappableField(key: 'name')
  final String? name;

  @MappableField(key: 'content')
  final String? content;

  @MappableField(key: 'group_id')
  final String? groupId;

  @MappableField(key: 'completed_at')
  final int? completedAt;

  @MappableField(key: 'updated_at')
  final int? updatedAt;

  @MappableField(key: 'timer_start')
  final int? timerStart;

  @MappableField(key: 'timer_end')
  final int? timerEnd;

  @MappableField(key: 'timer_total')
  final int? timerTotal;
}
