/// Решает, сообщать ли о коде, пойманном в очередном кадре камеры.
///
/// Пока код остаётся в кадре, повторно о нём не сообщаем — иначе приложение
/// тараторило бы, пока камера держится на упаковке. Пропал из кадра хотя бы
/// на [goneAfter] — при следующей встрече сообщаем снова.
///
/// Раньше последний код запоминался навсегда: навёл камеру на тот же товар
/// второй раз — тишина, и переспросить, не расслышав, было нельзя.
class BarcodeRepeatFilter {
  BarcodeRepeatFilter({this.goneAfter = const Duration(seconds: 3)});

  final Duration goneAfter;

  String? _last;
  DateTime _lastSeenAt = DateTime(0);

  /// true — о коде надо сообщить.
  bool shouldReport(String value, DateTime now) {
    final stillInView =
        value == _last && now.difference(_lastSeenAt) < goneAfter;
    // Отсчёт идёт от последнего кадра с этим кодом, а не от момента, когда
    // о нём сообщили: иначе код, который всё время в кадре, назывался бы
    // заново каждые [goneAfter].
    _last = value;
    _lastSeenAt = now;
    return !stillInView;
  }

  /// Забывает последний код — например, при смене режима камеры.
  void reset() {
    _last = null;
    _lastSeenAt = DateTime(0);
  }
}
