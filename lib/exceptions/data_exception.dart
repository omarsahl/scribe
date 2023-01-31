class EntityNotFoundException implements Exception {
  EntityNotFoundException(this.id, this.entityType);

  final dynamic id;
  final Type entityType;

  @override
  String toString() => "Entity of type $entityType and id $id doesn't exist";
}
