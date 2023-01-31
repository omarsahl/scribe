import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:kanban/auth/models/auth_params.dart';
import 'package:kanban/auth/models/auth_result.dart';
import 'package:kanban/auth/providers/auth_provider.dart';
import 'package:kanban/auth/providers/auth_providers_registry.dart';
import 'package:kanban/auth/utils/auth_utils.dart';
import 'package:kanban/exceptions/auth/auth_exception.dart';

@singleton
class KGoogleAuthProvider extends KAuthProvider<GoogleAuthProviderParams> {
  KGoogleAuthProvider(this._googleSignIn, this._firebaseAuth, KAuthProvidersRegistry registry)
      : super(registry, 'google') {
    registry.register(this);
  }

  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;

  @override
  Future<AuthProviderResult> signIn(GoogleAuthProviderParams params) async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      logDebugMessage('Auth failed: account is null');
      throw AuthProviderException('Google sign in returned an invalid account (null)');
    }
    return await _handleGoogleAccount(account);
  }

  @override
  Future<void> signOut() {
    return _googleSignIn.signOut();
  }

  Future<AuthProviderResult> _handleGoogleAccount(GoogleSignInAccount account) async {
    final GoogleSignInAuthentication googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    try {
      final credentials = await _firebaseAuth.signInWithCredential(credential);
      final user = credentials.user;
      if (user == null) {
        throw AuthProviderException('Google credentials returned a null user');
      }
      return AuthProviderResult(user.toKUser());
    } on FirebaseAuthException catch (e) {
      throw AuthProviderException('Failed to sign in with google', e);
    }
  }
}
