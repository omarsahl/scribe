import 'package:dart_mappable/dart_mappable.dart';
import 'package:kanban/json/mappers.dart';
import 'package:meta/meta.dart';

part 'board_entity.mapper.dart';

@immutable
@MappableClass(generateMethods: generateEncDecCpy)
class KBoard with KBoardMappable {
  const KBoard(
    this.id,
    this.name,
    this.description,
    this.adminUid,
    this.members,
    this.emoji,
    this.createdAt,
  );

  @MappableField(key: 'id')
  final String id;

  @MappableField(key: 'name')
  final String name;

  @MappableField(key: 'description')
  final String description;

  @MappableField(key: 'admin_uid')
  final String adminUid;

  @MappableField(key: 'created_at')
  final int createdAt;

  @MappableField(key: 'members')
  final List<String> members;

  @MappableField(key: 'emoji')
  final String? emoji;

  @override
  String toString() => 'KBoard($id, $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is KBoard && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
@immutable
@MappableClass(
  ignoreNull: true,
  generateMethods: GenerateMethods.encode,
)
class KBoardCreateModel with KBoardCreateModelMappable {
  const KBoardCreateModel({
    required this.name,
    required this.description,
    required this.adminUid,
    required this.members,
    this.emoji,
  });

  @MappableField(key: 'name')
  final String name;

  @MappableField(key: 'description')
  final String description;

  @MappableField(key: 'admin_uid')
  final String adminUid;

  @MappableField(key: 'members')
  final List<String> members;

  @MappableField(key: 'emoji')
  final String? emoji;
}

@immutable
@immutable
@MappableClass(
  ignoreNull: true,
  generateMethods: GenerateMethods.encode,
)
class KBoardUpdateModel with KBoardUpdateModelMappable {
  const KBoardUpdateModel({this.name, this.description, this.emoji});

  @MappableField(key: 'name')
  final String? name;

  @MappableField(key: 'description')
  final String? description;

  @MappableField(key: 'emoji')
  final String? emoji;
}
