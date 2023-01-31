import 'package:dart_mappable/dart_mappable.dart';
import 'package:meta/meta.dart';

// part 'label_entity.mapper.dart';

typedef KLabels = Map<int, KLabel>;

// TODO(@omar): add labels to tasks later (no time for now).
@immutable
// @MappableClass()
class KLabel /*with KLabelMappable*/ {
  const KLabel(this.id, this.boardId, this.name, this.color);

  @MappableField(key: 'id')
  final String id;

  @MappableField(key: 'board_id')
  final String boardId;

  @MappableField(key: 'name')
  final String name;

  @MappableField(key: 'color')
  final int color;

  @override
  String toString() => 'KLabel($name, $color)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KLabel && runtimeType == other.runtimeType && id == other.id && boardId == other.boardId;

  @override
  int get hashCode => Object.hash(id, boardId);
}

@immutable
// @MappableClass()
class KLabelCreateModel /*with KLabelCreateModelMappable*/ {
  const KLabelCreateModel({
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
// @MappableClass(
//   ignoreNull: true,
//   generateMethods: GenerateMethods.encode,
// )
class KLabelUpdateModel /*with KLabelUpdateModelMappable*/ {
  const KLabelUpdateModel({this.name, this.colorHex});

  @MappableField(key: 'name')
  final String? name;

  @MappableField(key: 'color_hex')
  final String? colorHex;
}
