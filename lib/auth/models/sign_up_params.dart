import 'package:dart_mappable/dart_mappable.dart';
import 'package:meta/meta.dart';

part 'sign_up_params.mapper.dart';

@immutable
@MappableClass()
class SignUpParams with SignUpParamsMappable {
  const SignUpParams(this.name, this.email, this.password);

  @MappableField(key: 'name')
  final String name;

  @MappableField(key: 'email')
  final String email;

  @MappableField(key: 'password')
  final String password;

  @override
  String toString() {
    return 'SignUpParams{name: $name, email: $email, password: $password}';
  }
}
