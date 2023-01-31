class UserNotFoundException implements Exception {
  UserNotFoundException(this.id);

  final String id;

  @override
  String toString() {
    return 'No user found for uid: $id';
  }
}
