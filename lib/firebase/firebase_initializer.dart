import 'package:firebase_core/firebase_core.dart';
import 'package:kanban/core/logger/logger.dart';
import 'package:kanban/firebase_options.dart';

class FirebaseInitializer {
  FirebaseInitializer._();

  static final FirebaseInitializer instance = FirebaseInitializer._();

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e, s) {
      logger.e('Error initializing firebase', e, s);
      rethrow;
    }
  }
}
