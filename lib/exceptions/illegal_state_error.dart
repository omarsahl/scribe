class IllegalStateException implements Exception {
  IllegalStateException(this.message);

  final String message;

  @override
  String toString() {
    return message;
  }
}
