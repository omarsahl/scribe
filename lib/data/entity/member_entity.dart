import 'package:dart_mappable/dart_mappable.dart';
import 'package:meta/meta.dart';

part 'member_entity.mapper.dart';

@immutable
@MappableClass()
class KMember with KMemberMappable {
  const KMember(this.uid, this.name, this.photoUrl);

  @MappableField(key: 'uid')
  final String uid;

  @MappableField(key: 'name')
  final String? name;

  @MappableField(key: 'photo_url')
  final String? photoUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is KMember && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
