import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

@module
abstract class FirebaseModule {
  @injectable
  FirebaseAuth firebaseAuth() => FirebaseAuth.instance;

  @injectable
  FirebaseFirestore firebaseFirestore() => FirebaseFirestore.instance;
}
