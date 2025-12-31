import 'package:collection/collection.dart';

extension ListExtensions<T> on List<T> {
  T? getOrNull(int index) {
    return index >= 0 && index < length ? this[index] : null;
  }

  bool containsIf(bool Function(T element) condition) {
    // for (var element in this) {
    //   if (condition(element)) {
    //     return true;
    //   }
    // }
    // return false;
    return any(condition);
  }

  T? firstIf(bool Function(T element) condition) {
    return firstWhereOrNull(condition);
  }

  T? lastIf(bool Function(T element) condition) {
    return lastWhereOrNull(condition);
  }

  int indexIf(bool Function(T element) condition) {
    return indexWhere(condition);
  }

  void removeIf(bool Function(T element) condition) {
    return removeWhere(condition);
  }

  List<T> filterIf(bool Function(T element) condition) {
    return where(condition).toList();
  }

  // List<T> sortIf(bool Function(T element) condition) {
  //   return ;
  // }

  List<T> notContainsItems(List<T> other) {
    var setA = Set<T>.from(this);
    var setB = Set<T>.from(other);
    return setB.difference(setA).toList();
  }
}

extension MapExtensions<K, V> on Map<K, V> {
  V? getOrNull(K key) {
    return containsKey(key) ? this[key] : null;
  }
}
