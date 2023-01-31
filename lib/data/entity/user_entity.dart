import 'package:dart_mappable/dart_mappable.dart';
import 'package:kanban/data/entity/member_entity.dart';
import 'package:meta/meta.dart';

part 'user_entity.mapper.dart';

@immutable
@MappableClass(generateMethods: GenerateMethods.encode | GenerateMethods.decode | GenerateMethods.copy)
class KUser with KUserMappable {
  const KUser(this.uid, this.name, this.email, this.photoUrl, this.boards);

  @MappableField(key: 'uid')
  final String uid;

  @MappableField(key: 'name')
  final String? name;

  @MappableField(key: 'email')
  final String? email;

  @MappableField(key: 'boards')
  final List<String> boards;

  final String? photoUrl;

  @override
  String toString() => 'KUser($uid, $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is KUser && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}

@immutable
@immutable
@MappableClass(
  ignoreNull: true,
  generateMethods: GenerateMethods.encode,
)
class KUserUpdateModel with KUserUpdateModelMappable {
  const KUserUpdateModel(this.name, this.email, this.photoUrl);

  @MappableField(key: 'name')
  final String? name;

  @MappableField(key: 'email')
  final String? email;

  final String? photoUrl;
}

extension KUserX on KUser {
  KMember toMember() => KMember(uid, name, photoUrl);
}
