import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kanban/json/mappers.container.dart';

T firestoreGenericFromConverter<T>(
    DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
  return mappersContainer.fromMap<T>(snapshot.data()!);
}

Map<String, dynamic> firestoreGenericToConverter<T>(T value, SetOptions? options) {
  return mappersContainer.toMap<T>(value);
}

extension CollectionReferenceX on CollectionReference {
  CollectionReference<R> withGenericConverter<R extends Object?>() {
    return withConverter<R>(
      fromFirestore: firestoreGenericFromConverter,
      toFirestore: firestoreGenericToConverter,
    );
  }
}
