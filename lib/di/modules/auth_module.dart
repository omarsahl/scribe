import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

@module
abstract class AuthModule {
  @singleton
  GoogleSignIn googleSignIn() => GoogleSignIn(scopes: ['email', 'profile']);
}
