enum SyncLogLevel {
  trace,
  debug,
  info,
  warn,
  error,
}

class SyncLogRecord {
  const SyncLogRecord({
    required this.atUtc,
    required this.level,
    required this.event,
    required this.message,
    required this.data,
    required this.error,
    required this.stackTrace,
  });

  final DateTime atUtc;
  final SyncLogLevel level;
  final String event;
  final String? message;
  final Map<String, Object?> data;
  final Object? error;
  final StackTrace? stackTrace;
}

abstract class SyncLogSink {
  const SyncLogSink();

  void add(SyncLogRecord record);
}

class SyncLogger {
  SyncLogger({
    required SyncLogSink sink,
    SyncLogLevel minLevel = SyncLogLevel.info,
    DateTime Function()? nowUtc,
  })  : _sink = sink,
        _minLevel = minLevel,
        _nowUtc = nowUtc ?? DateTime.now().toUtc;

  final SyncLogSink _sink;
  final SyncLogLevel _minLevel;
  final DateTime Function() _nowUtc;

  void trace(
    String event, {
    String? message,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    log(SyncLogLevel.trace, event, message: message, data: data);
  }

  void debug(
    String event, {
    String? message,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    log(SyncLogLevel.debug, event, message: message, data: data);
  }

  void info(
    String event, {
    String? message,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    log(SyncLogLevel.info, event, message: message, data: data);
  }

  void warn(
    String event, {
    String? message,
    Map<String, Object?> data = const <String, Object?>{},
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      SyncLogLevel.warn,
      event,
      message: message,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void error(
    String event, {
    String? message,
    Map<String, Object?> data = const <String, Object?>{},
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      SyncLogLevel.error,
      event,
      message: message,
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void log(
    SyncLogLevel level,
    String event, {
    String? message,
    Map<String, Object?> data = const <String, Object?>{},
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_isEnabled(level)) return;
    _sink.add(
      SyncLogRecord(
        atUtc: _nowUtc(),
        level: level,
        event: event,
        message: message,
        data: data,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }

  bool _isEnabled(SyncLogLevel level) {
    return level.index >= _minLevel.index;
  }

  static SyncLogger noop() {
    return SyncLogger(sink: const _NoopLogSink());
  }
}

class PrintLogSink extends SyncLogSink {
  PrintLogSink({void Function(String line)? printer})
      : _printer = printer ?? print;

  final void Function(String line) _printer;

  @override
  void add(SyncLogRecord record) {
    final base =
        '[${record.atUtc.toIso8601String()}] ${record.level.name} ${record.event}';

    final message = record.message;
    final data = record.data;
    final error = record.error;

    if (message == null && data.isEmpty && error == null) {
      _printer(base);
      return;
    }

    final buffer = StringBuffer(base);
    if (message != null) buffer.write(' msg=$message');
    if (data.isNotEmpty) buffer.write(' data=$data');
    if (error != null) buffer.write(' err=$error');
    _printer(buffer.toString());
  }
}

class InMemoryLogSink extends SyncLogSink {
  InMemoryLogSink();

  final List<SyncLogRecord> records = <SyncLogRecord>[];

  @override
  void add(SyncLogRecord record) {
    records.add(record);
  }
}

class CompositeLogSink extends SyncLogSink {
  const CompositeLogSink(this._sinks);

  final List<SyncLogSink> _sinks;

  @override
  void add(SyncLogRecord record) {
    for (final sink in _sinks) {
      sink.add(record);
    }
  }
}

class RingBufferLogSink extends SyncLogSink {
  RingBufferLogSink({required int capacity})
      : _capacity = capacity <= 0 ? 1 : capacity;

  final int _capacity;
  final List<SyncLogRecord> _buffer = <SyncLogRecord>[];
  int _start = 0;

  List<SyncLogRecord> snapshot() {
    if (_buffer.isEmpty) return const <SyncLogRecord>[];
    if (_buffer.length < _capacity) return List<SyncLogRecord>.of(_buffer);

    final out = <SyncLogRecord>[];
    for (var i = 0; i < _buffer.length; i += 1) {
      out.add(_buffer[(_start + i) % _buffer.length]);
    }
    return out;
  }

  @override
  void add(SyncLogRecord record) {
    if (_buffer.length < _capacity) {
      _buffer.add(record);
      return;
    }
    _buffer[_start] = record;
    _start = (_start + 1) % _capacity;
  }
}

class _NoopLogSink extends SyncLogSink {
  const _NoopLogSink();

  @override
  void add(SyncLogRecord record) {}
}
