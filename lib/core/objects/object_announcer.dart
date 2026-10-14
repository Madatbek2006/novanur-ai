/// Решает, какие предметы в кадре назвать вслух.
///
/// Предмет называется, когда появился и продержался в кадре [confirmFrames]
/// кадров подряд: детектор иногда на один кадр видит то, чего нет, и
/// приложение не должно называть мусор. Пока предмет остаётся в кадре, он
/// повторно не называется — иначе приложение тараторило бы. Пропал хотя бы на
/// [goneAfter] — при следующей встрече назовётся снова. То же правило, что у
/// штрихкодов.
class ObjectAnnouncer {
  ObjectAnnouncer({
    this.goneAfter = const Duration(seconds: 3),
    this.confirmFrames = 2,
  });

  final Duration goneAfter;
  final int confirmFrames;

  final Map<String, DateTime> _lastSeen = {};
  final Map<String, int> _streak = {};
  final Set<String> _named = {};

  /// Принимает названия предметов в очередном кадре и отдаёт те, что пора
  /// произнести, — в порядке, в каком их отдал детектор.
  List<String> update(Iterable<String> inView, DateTime now) {
    final names = inView.toSet();

    // Серия подряд прерывается, как только предмета нет в кадре.
    _streak.removeWhere((name, _) => !names.contains(name));

    final fresh = <String>[];
    for (final name in names) {
      // Давность проверяется в момент, когда предмет снова в кадре: кадров
      // без него могло и не быть, или последний был раньше, чем истекли
      // [goneAfter]. Не видели дольше — значит, уходил и вернулся.
      final last = _lastSeen[name];
      if (last != null && now.difference(last) >= goneAfter) {
        _named.remove(name);
        _streak.remove(name);
      }
      _lastSeen[name] = now;
      final streak = _streak[name] = (_streak[name] ?? 0) + 1;
      if (streak >= confirmFrames && _named.add(name)) fresh.add(name);
    }
    return fresh;
  }

  void reset() {
    _lastSeen.clear();
    _streak.clear();
    _named.clear();
  }
}
