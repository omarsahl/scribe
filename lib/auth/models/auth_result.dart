import 'package:kanban/data/entity/user_entity.dart';
import 'package:meta/meta.dart';

@immutable
class AuthProviderResult {
  const AuthProviderResult(this.user);

  final KUser user;
}
