import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_params.freezed.dart';

@freezed
class AuthProviderParams with _$AuthProviderParams {
  const factory AuthProviderParams.credentials(String email, String password) = CredentialsAuthProviderParams;

  const factory AuthProviderParams.google() = GoogleAuthProviderParams;

  // TODO(@omar, auth): implement this auth method if there will be time for it.
  const factory AuthProviderParams.facebook() = FacebookAuthProviderParams;
}
