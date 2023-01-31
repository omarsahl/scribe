import 'package:firebase_auth/firebase_auth.dart';
import 'package:kanban/data/entity/user_entity.dart';

extension FirebaseUserExtensions on User {
  KUser toKUser() => KUser(uid, displayName, email, photoURL, const []);
}
