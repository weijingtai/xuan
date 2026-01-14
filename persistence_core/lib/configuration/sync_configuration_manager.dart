import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:persistence_core/core/sync_coordinator.dart';
import 'package:persistence_core/logging/sync_logger.dart';
import 'package:persistence_core/model/ports.dart';
import '../sync/sync_runtime.dart';

import 'yaml_file_loader.dart';

/// Immutable configuration for sync components.
///
/// 功能说明：
/// - 统一管理同步相关的可调参数，覆盖：
///   - [SyncCoordinator] 的 push/pull 执行参数（批大小、死信阈值、pull 翻页限制等）
///   - [SyncRuntime] 的调度参数（push/pull 周期、退避区间、默认 pull entityTypes）
/// - 支持 JSON 序列化，便于从配置文件加载与写回。
///
/// JSON 约定：
/// - duration 统一以毫秒保存（例如 pushIntervalMs）。
/// - entityTypes 为字符串数组。
class SyncConfiguration {
  /// Creates a [SyncConfiguration].
  ///
  /// 参数说明：
  /// - [pushBatchSize]/[pullBatchSize]: coordinator 单次 push/pull 的默认批大小。
  /// - [maxAttemptsBeforeDead]: outbox 单条记录最大尝试次数。
  /// - [pullMaxPages]: 单次 pull 最多翻页次数。
  /// - [pullLimit]: pull 单页请求上限（null 表示使用 [pullBatchSize]）。
  /// - [pushInterval]/[pullInterval]: runtime 的定时器周期。
  /// - [minBackoff]/[maxBackoff]: runtime 失败后的指数退避区间。
  /// - [pullEntityTypes]: runtime 周期 pull 的实体类型列表。
  const SyncConfiguration({
    required this.pushBatchSize,
    required this.pullBatchSize,
    required this.maxAttemptsBeforeDead,
    required this.pullMaxPages,
    required this.pullLimit,
    required this.pushInterval,
    required this.pullInterval,
    required this.minBackoff,
    required this.maxBackoff,
    required this.pullEntityTypes,
  });

  /// Default configuration matching current constructor defaults.
  const SyncConfiguration.defaults()
      : pushBatchSize = 50,
        pullBatchSize = 50,
        maxAttemptsBeforeDead = 10,
        pullMaxPages = 100,
        pullLimit = null,
        pushInterval = const Duration(seconds: 10),
        pullInterval = const Duration(seconds: 30),
        minBackoff = const Duration(seconds: 2),
        maxBackoff = const Duration(minutes: 2),
        pullEntityTypes = const <String>[];

  final int pushBatchSize;
  final int pullBatchSize;
  final int maxAttemptsBeforeDead;
  final int pullMaxPages;
  final int? pullLimit;
  final Duration pushInterval;
  final Duration pullInterval;
  final Duration minBackoff;
  final Duration maxBackoff;
  final List<String> pullEntityTypes;

  /// Returns a new [SyncConfiguration] with selected fields overridden.
  SyncConfiguration copyWith({
    int? pushBatchSize,
    int? pullBatchSize,
    int? maxAttemptsBeforeDead,
    int? pullMaxPages,
    Object? pullLimit = _unset,
    Duration? pushInterval,
    Duration? pullInterval,
    Duration? minBackoff,
    Duration? maxBackoff,
    List<String>? pullEntityTypes,
  }) {
    return SyncConfiguration(
      pushBatchSize: pushBatchSize ?? this.pushBatchSize,
      pullBatchSize: pullBatchSize ?? this.pullBatchSize,
      maxAttemptsBeforeDead:
          maxAttemptsBeforeDead ?? this.maxAttemptsBeforeDead,
      pullMaxPages: pullMaxPages ?? this.pullMaxPages,
      pullLimit:
          identical(pullLimit, _unset) ? this.pullLimit : pullLimit as int?,
      pushInterval: pushInterval ?? this.pushInterval,
      pullInterval: pullInterval ?? this.pullInterval,
      minBackoff: minBackoff ?? this.minBackoff,
      maxBackoff: maxBackoff ?? this.maxBackoff,
      pullEntityTypes:
          pullEntityTypes ?? List<String>.unmodifiable(this.pullEntityTypes),
    );
  }

  /// Converts this configuration to a JSON map.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'schemaVersion': 1,
      'pushBatchSize': pushBatchSize,
      'pullBatchSize': pullBatchSize,
      'maxAttemptsBeforeDead': maxAttemptsBeforeDead,
      'pullMaxPages': pullMaxPages,
      'pullLimit': pullLimit,
      'pushIntervalMs': pushInterval.inMilliseconds,
      'pullIntervalMs': pullInterval.inMilliseconds,
      'minBackoffMs': minBackoff.inMilliseconds,
      'maxBackoffMs': maxBackoff.inMilliseconds,
      'pullEntityTypes': pullEntityTypes,
    };
  }

  /// Parses a configuration from JSON.
  ///
  /// 解析策略：
  /// - 对缺失字段使用默认值（见 [SyncConfiguration.defaults]）。
  /// - 对非法类型/非法数值抛出 [FormatException]。
  static SyncConfiguration fromJson(Map<String, Object?> json) {
    final defaults = const SyncConfiguration.defaults();

    int readInt(String key, int fallback, {int min = 0}) {
      final v = json[key];
      if (v == null) return fallback;
      if (v is! int) {
        throw FormatException('Expected int for "$key", got ${v.runtimeType}');
      }
      if (v < min) {
        throw FormatException('Expected "$key" >= $min, got $v');
      }
      return v;
    }

    int? readNullableInt(String key, {int min = 0}) {
      final v = json[key];
      if (v == null) return null;
      if (v is! int) {
        throw FormatException('Expected int for "$key", got ${v.runtimeType}');
      }
      if (v < min) {
        throw FormatException('Expected "$key" >= $min, got $v');
      }
      return v;
    }

    Duration readDurationMs(String key, Duration fallback) {
      final ms = json[key];
      if (ms == null) return fallback;
      if (ms is! int) {
        throw FormatException(
            'Expected int(ms) for "$key", got ${ms.runtimeType}');
      }
      if (ms < 0) {
        throw FormatException('Expected "$key" >= 0, got $ms');
      }
      return Duration(milliseconds: ms);
    }

    List<String> readStringList(String key, List<String> fallback) {
      final v = json[key];
      if (v == null) return fallback;
      if (v is! List) {
        throw FormatException('Expected list for "$key", got ${v.runtimeType}');
      }
      final out = <String>[];
      for (final e in v) {
        if (e is! String) {
          throw FormatException('Expected string list for "$key"');
        }
        final trimmed = e.trim();
        if (trimmed.isNotEmpty) out.add(trimmed);
      }
      return List<String>.unmodifiable(out.toSet().toList()..sort());
    }

    final minBackoff = readDurationMs('minBackoffMs', defaults.minBackoff);
    final maxBackoff = readDurationMs('maxBackoffMs', defaults.maxBackoff);
    if (maxBackoff < minBackoff) {
      throw const FormatException('maxBackoffMs must be >= minBackoffMs');
    }

    return SyncConfiguration(
      pushBatchSize: readInt('pushBatchSize', defaults.pushBatchSize, min: 1),
      pullBatchSize: readInt('pullBatchSize', defaults.pullBatchSize, min: 1),
      maxAttemptsBeforeDead: readInt(
          'maxAttemptsBeforeDead', defaults.maxAttemptsBeforeDead,
          min: 1),
      pullMaxPages: readInt('pullMaxPages', defaults.pullMaxPages, min: 1),
      pullLimit: readNullableInt('pullLimit', min: 1),
      pushInterval: readDurationMs('pushIntervalMs', defaults.pushInterval),
      pullInterval: readDurationMs('pullIntervalMs', defaults.pullInterval),
      minBackoff: minBackoff,
      maxBackoff: maxBackoff,
      pullEntityTypes:
          readStringList('pullEntityTypes', defaults.pullEntityTypes),
    );
  }

  static const Object _unset = Object();
}

/// Storage abstraction for reading and writing sync configuration.
///
/// 功能说明：
/// - 解耦“配置从哪里来”（文件、本地数据库、远端下发等）与配置解析/应用逻辑。
abstract class SyncConfigurationStorage {
  /// Reads raw configuration content.
  ///
  /// 返回值：
  /// - null：表示配置不存在（例如文件不存在）。
  Future<String?> read();

  /// Writes raw configuration content.
  Future<void> write(String content);
}

/// In-memory configuration storage.
///
/// 用途：
/// - 单元测试。
/// - 由上层自行持久化时的临时实现。
class InMemorySyncConfigurationStorage implements SyncConfigurationStorage {
  InMemorySyncConfigurationStorage([this._content]);

  String? _content;

  @override
  Future<String?> read() async {
    return _content;
  }

  @override
  Future<void> write(String content) async {
    _content = content;
  }
}

/// File-based configuration storage.
///
/// 说明：
/// - 该实现使用 `dart:io` 读写本地文件，仅适用于具备 IO 能力的平台（非 Web）。
class FileSyncConfigurationStorage implements SyncConfigurationStorage {
  /// Creates a [FileSyncConfigurationStorage].
  ///
  /// 参数说明：
  /// - [filePath]: 配置文件路径。
  FileSyncConfigurationStorage({required String filePath})
      : _file = File(filePath);

  final File _file;

  @override
  Future<String?> read() async {
    if (!await _file.exists()) return null;
    return _file.readAsString();
  }

  @override
  Future<void> write(String content) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(content);
  }
}

class YamlFileSyncConfigurationStorage implements SyncConfigurationStorage {
  YamlFileSyncConfigurationStorage({
    required String filePath,
    YamlFileLoader loader = const YamlFileLoader(),
  })  : _filePath = filePath,
        _loader = loader,
        _file = File(filePath);

  final String _filePath;
  final YamlFileLoader _loader;
  final File _file;

  @override
  Future<String?> read() async {
    return _loader.readFileIfExists(_filePath);
  }

  @override
  Future<void> write(String content) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(content);
  }
}

abstract class SyncConfigurationCodec {
  const SyncConfigurationCodec();

  SyncConfiguration decode(String raw);

  String encode(SyncConfiguration config);
}

class JsonSyncConfigurationCodec extends SyncConfigurationCodec {
  const JsonSyncConfigurationCodec();

  @override
  SyncConfiguration decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Sync configuration must be a JSON object');
    }

    final map = <String, Object?>{};
    decoded.forEach((k, v) {
      if (k is String) {
        map[k] = v as Object?;
      }
    });

    return SyncConfiguration.fromJson(map);
  }

  @override
  String encode(SyncConfiguration config) {
    return const JsonEncoder.withIndent('  ').convert(config.toJson());
  }
}

class YamlSyncConfigurationCodec extends SyncConfigurationCodec {
  YamlSyncConfigurationCodec({YamlFileLoader loader = const YamlFileLoader()})
      : _loader = loader;

  final YamlFileLoader _loader;

  @override
  SyncConfiguration decode(String raw) {
    final root = _loader.parseToMap(raw);
    final sync = root['sync'];
    if (sync is! Map) {
      throw const FormatException('YAML root must contain a "sync" map');
    }

    final map = <String, Object?>{};
    sync.forEach((k, v) {
      if (k is String) {
        map[k] = v as Object?;
      }
    });

    return SyncConfiguration.fromJson(map);
  }

  @override
  String encode(SyncConfiguration config) {
    final json = config.toJson();
    json.remove('schemaVersion');
    return _encodeYaml(json);
  }

  String _encodeYaml(Map<String, Object?> json) {
    final orderedKeys = <String>[
      'schemaVersion',
      'pushBatchSize',
      'pullBatchSize',
      'maxAttemptsBeforeDead',
      'pullMaxPages',
      'pullLimit',
      'pushIntervalMs',
      'pullIntervalMs',
      'minBackoffMs',
      'maxBackoffMs',
      'pullEntityTypes',
    ];

    final buffer = StringBuffer();
    buffer.writeln('sync:');
    for (final key in orderedKeys) {
      if (!json.containsKey(key)) continue;
      final value = json[key];
      if (value is List) {
        buffer.writeln('  $key:');
        for (final item in value) {
          buffer.writeln('    - ${_encodeScalar(item)}');
        }
        continue;
      }

      buffer.writeln('  $key: ${_encodeScalar(value)}');
    }
    return buffer.toString();
  }

  String _encodeScalar(Object? value) {
    if (value == null) return 'null';
    if (value is num || value is bool) return value.toString();

    final s = value.toString();
    final needsQuote = s.isEmpty ||
        s.contains(':') ||
        s.contains('#') ||
        s.contains('\n') ||
        s.trim() != s ||
        s.contains('"') ||
        s.contains("'") ||
        s.contains('[') ||
        s.contains(']');

    if (!needsQuote) return s;
    final escaped = s.replaceAll("'", "''");
    return "'$escaped'";
  }
}

/// Manages loading, updating, and persisting [SyncConfiguration].
///
/// 功能说明：
/// - 从 [SyncConfigurationStorage] 加载 JSON 配置，并解析为 [SyncConfiguration]。
/// - 允许在运行时更新配置并写回配置文件。
/// - 暴露配置变更的广播流，便于上层做热更新/诊断面板。
///
/// 典型使用：
/// 1) App 启动：manager.load();
/// 2) 构建 coordinator/runtime：manager.buildCoordinator(...), manager.buildRuntime(...)
/// 3) 调试面板修改：manager.update(..., persist: true)
class SyncConfigurationManager {
  /// Creates a [SyncConfigurationManager].
  ///
  /// 参数说明：
  /// - [storage]: 配置存储（文件/内存/自定义）。
  /// - [defaults]: 当存储不存在或内容为空时使用的默认配置。
  SyncConfigurationManager({
    required SyncConfigurationStorage storage,
    SyncConfigurationCodec codec = const JsonSyncConfigurationCodec(),
    SyncConfiguration defaults = const SyncConfiguration.defaults(),
    SyncLogger? logger,
  })  : _storage = storage,
        _codec = codec,
        _defaults = defaults,
        _logger = logger ?? SyncLogger.noop(),
        _current = defaults;

  final SyncConfigurationStorage _storage;
  final SyncConfigurationCodec _codec;
  final SyncConfiguration _defaults;
  final SyncLogger _logger;

  SyncConfiguration _current;
  final StreamController<SyncConfiguration> _controller =
      StreamController<SyncConfiguration>.broadcast();

  bool _disposed = false;

  /// Returns the current configuration snapshot.
  SyncConfiguration get current => _current;

  /// Broadcast stream that emits after each successful load/update.
  Stream<SyncConfiguration> get stream => _controller.stream;

  /// Loads configuration from storage.
  ///
  /// 行为：
  /// - 若存储不存在/内容为空：使用 defaults，并（可选）写回。
  /// - 若内容存在：解析 JSON 成 [SyncConfiguration]。
  ///
  /// 参数说明：
  /// - [writeBackIfMissing]: 当存储缺失时是否把 defaults 写回。
  Future<SyncConfiguration> load({bool writeBackIfMissing = true}) async {
    _ensureNotDisposed();

    _logger.debug(
      'sync_config_load_start',
      data: <String, Object?>{
        'codec': _codec.runtimeType.toString(),
        'storage': _storage.runtimeType.toString(),
        'writeBackIfMissing': writeBackIfMissing,
      },
    );

    final raw = await _storage.read();
    if (raw == null || raw.trim().isEmpty) {
      _current = _defaults;
      _emit(_current);
      _logger.warn(
        'sync_config_load_missing',
        data: <String, Object?>{
          'codec': _codec.runtimeType.toString(),
          'storage': _storage.runtimeType.toString(),
          'writeBackIfMissing': writeBackIfMissing,
        },
      );
      if (writeBackIfMissing) {
        await save();
      }
      return _current;
    }

    try {
      _current = _codec.decode(raw);
    } on Object catch (e, st) {
      _logger.error(
        'sync_config_decode_error',
        data: <String, Object?>{
          'codec': _codec.runtimeType.toString(),
          'storage': _storage.runtimeType.toString(),
          'rawLength': raw.length,
        },
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
    _emit(_current);

    _logger.info(
      'sync_config_load_success',
      data: <String, Object?>{
        'codec': _codec.runtimeType.toString(),
        'storage': _storage.runtimeType.toString(),
      },
    );
    return _current;
  }

  /// Saves current configuration to storage.
  Future<void> save() async {
    _ensureNotDisposed();
    _logger.debug(
      'sync_config_save_start',
      data: <String, Object?>{
        'codec': _codec.runtimeType.toString(),
        'storage': _storage.runtimeType.toString(),
      },
    );

    final content = _codec.encode(_current);
    try {
      await _storage.write(content);
    } on Object catch (e, st) {
      _logger.error(
        'sync_config_save_error',
        data: <String, Object?>{
          'codec': _codec.runtimeType.toString(),
          'storage': _storage.runtimeType.toString(),
          'contentLength': content.length,
        },
        error: e,
        stackTrace: st,
      );
      rethrow;
    }

    _logger.info(
      'sync_config_save_success',
      data: <String, Object?>{
        'codec': _codec.runtimeType.toString(),
        'storage': _storage.runtimeType.toString(),
        'contentLength': content.length,
      },
    );
  }

  /// Updates configuration using [updater].
  ///
  /// 参数说明：
  /// - [updater]: 基于旧配置返回新配置。
  /// - [persist]: 是否写回存储。
  Future<SyncConfiguration> update(
    SyncConfiguration Function(SyncConfiguration current) updater, {
    bool persist = true,
  }) async {
    _ensureNotDisposed();
    final next = updater(_current);
    _current = next;
    _emit(_current);

    _logger.info(
      'sync_config_update',
      data: <String, Object?>{
        'persist': persist,
      },
    );

    if (persist) await save();
    return _current;
  }

  /// Builds a [SyncCoordinator] using the current configuration.
  ///
  /// 参数说明：
  /// - [outboxStore]/[remoteGateway]/[nowUtc]：同 [SyncCoordinator] 构造参数。
  /// - [syncStateStore]/[localApplier]：用于启用 pull（可选）。
  SyncCoordinator buildCoordinator({
    required OutboxStore outboxStore,
    required RemoteGateway remoteGateway,
    required DateTime Function() nowUtc,
    SyncStateStore? syncStateStore,
    LocalApplier? localApplier,
  }) {
    _ensureNotDisposed();
    final c = _current;
    return SyncCoordinator(
      outboxStore: outboxStore,
      remoteGateway: remoteGateway,
      nowUtc: nowUtc,
      syncStateStore: syncStateStore,
      localApplier: localApplier,
      pushBatchSize: c.pushBatchSize,
      pullBatchSize: c.pullBatchSize,
      maxAttemptsBeforeDead: c.maxAttemptsBeforeDead,
    );
  }

  /// Builds a [SyncRuntime] using the current configuration.
  ///
  /// 行为：
  /// - 将 runtime 调度相关参数从配置注入（interval/backoff）。
  /// - 自动调用一次 setPullEntityTypes(config.pullEntityTypes)。
  SyncRuntime buildRuntime({
    required SyncCoordinator coordinator,
    AuthScopeProvider? authScopeProvider,
    DateTime Function()? nowUtc,
  }) {
    _ensureNotDisposed();
    final c = _current;
    final runtime = SyncRuntime(
      coordinator: coordinator,
      authScopeProvider: authScopeProvider,
      pushInterval: c.pushInterval,
      pullInterval: c.pullInterval,
      minBackoff: c.minBackoff,
      maxBackoff: c.maxBackoff,
      nowUtc: nowUtc,
    );
    runtime.setPullEntityTypes(c.pullEntityTypes, triggerImmediately: false);
    return runtime;
  }

  /// Disposes this manager and closes its stream.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _controller.close();
  }

  void _emit(SyncConfiguration config) {
    if (_controller.isClosed) return;
    _controller.add(config);
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('SyncConfigurationManager is disposed');
    }
  }
}
