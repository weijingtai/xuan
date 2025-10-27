/// Utility functions for deterministic list reordering.
List<T> moveItem<T>(List<T> list, int oldIndex, int newIndex) {
  if (oldIndex == newIndex) return List<T>.of(list);
  if (oldIndex < 0 || oldIndex >= list.length) return List<T>.of(list);
  if (newIndex < 0 || newIndex > list.length) return List<T>.of(list);
  final copy = List<T>.of(list);
  final item = copy.removeAt(oldIndex);
  var insertIndex = newIndex;
  if (newIndex > oldIndex) {
    insertIndex = newIndex - 1;
  }
  copy.insert(insertIndex, item);
  return copy;
}

