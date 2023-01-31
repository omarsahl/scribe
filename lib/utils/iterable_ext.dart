extension IterableX<E> on Iterable<E> {
  List<T> mapToList<T>(T Function(E e) toElement, [bool growable = false]) {
    return map(toElement).toList(growable: growable);
  }

  Set<T> mapToSet<T>(T Function(E e) toElement) {
    return map(toElement).toSet();
  }
}
