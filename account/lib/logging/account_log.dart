import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class AccountLog {
  static final _filter = _DynamicLevelFilter(
    kReleaseMode ? Level.info : Level.debug,
  );

  static final Logger log = Logger(
    filter: _filter,
    level: Level.trace,
    printer: kReleaseMode
        ? SimplePrinter(colors: false)
        : PrettyPrinter(methodCount: 0),
  );

  static const Uuid _uuid = Uuid();

  static String newFlowId() => _uuid.v4();

  static void setLevel(Level level) => _filter.setLevel(level);

  static String maskId(String? value) {
    if (value == null) return '—';
    final s = value.trim();
    if (s.isEmpty) return '—';
    if (s.length <= 8) return s;
    return '${s.substring(0, 4)}…${s.substring(s.length - 3)}';
  }

  static String maskEmail(String? email) {
    if (email == null) return '—';
    final s = email.trim();
    if (s.isEmpty) return '—';
    final at = s.indexOf('@');
    if (at <= 1) return '***';
    final name = s.substring(0, at);
    final domain = s.substring(at + 1);
    final maskedName = '${name.substring(0, 1)}***';
    if (domain.isEmpty) return '$maskedName@***';
    return '$maskedName@$domain';
  }
}

class _DynamicLevelFilter extends LogFilter {
  _DynamicLevelFilter(this._level);

  Level _level;

  void setLevel(Level level) {
    _level = level;
  }

  @override
  bool shouldLog(LogEvent event) => event.level.index >= _level.index;
}
