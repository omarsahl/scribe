import 'package:dart_mappable/dart_mappable.dart';
import 'package:meta/meta.dart';

part 'task_group_entity.mapper.dart';

@immutable
@MappableClass()
class KTaskGroup with KTaskGroupMappable {
  const KTaskGroup(this.id, this.boardId, this.name, this.color, this.createdAt, this.lastTaskOrder);

  @MappableField(key: 'id')
  final String id;

  @MappableField(key: 'board_id')
  final String boardId;

  @MappableField(key: 'name')
  final String name;

  @MappableField(key: 'color')
  final int color;

  @MappableField(key: 'created_at')
  final int createdAt;

  @MappableField(key: 'last_task_order')
  final int lastTaskOrder;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KTaskGroup && runtimeType == other.runtimeType && id == other.id && boardId == other.boardId;

  @override
  int get hashCode => Object.hash(id, boardId);
}

@immutable
@MappableClass(
  ignoreNull: true,
  generateMethods: GenerateMethods.encode,
)
class KTaskGroupCreateModel with KTaskGroupCreateModelMappable {
  const KTaskGroupCreateModel({
    required this.boardId,
    required this.name,
    required this.color,
  });

  @MappableField(key: 'board_id')
  final String boardId;

  @MappableField(key: 'name')
  final String name;

  @MappableField(key: 'color')
  final int color;
}

@immutable
@MappableClass(
  ignoreNull: true,
  generateMethods: GenerateMethods.encode,
)
class KTaskGroupUpdateModel with KTaskGroupUpdateModelMappable {
  const KTaskGroupUpdateModel({this.name, this.color});

  @MappableField(key: 'name')
  final String? name;

  @MappableField(key: 'color')
  final int? color;
}
