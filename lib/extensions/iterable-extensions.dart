extension IterableExtensions on Iterable {
  Iterable<T> order<T>(int Function(T,T) comparator) {
    final temp = [...(this ?? []).cast<T>()];
    temp.sort(comparator);
    return temp.toList();
  }
}
