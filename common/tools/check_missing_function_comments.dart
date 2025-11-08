import 'dart:io';

/// 函数注释静态检查脚本
///
/// 作用：扫描指定目录下的 `.dart` 文件，检测函数/方法声明前是否存在
/// `///` 风格的函数级注释（或 `/** ... */` 的文档注释）。用于阶段 2 的
/// “注释覆盖率”自检，帮助确保“所有函数都有函数级注释”。
///
/// 使用示例：
/// - `dart run common/tools/check_missing_function_comments.dart --paths common/lib lib`
/// - 或直接：`dart common/tools/check_missing_function_comments.dart --paths common/lib`
///
/// 参数：
/// - `--paths <dir1> <dir2> ...` 需要扫描的目录列表；默认仅扫描 `common/lib`。
/// - `--exclude <pattern>` 可选，排除文件路径中包含 `pattern` 的条目，可重复。
///
/// 退出码：
/// - 0：所有函数均存在函数级注释；
/// - 非 0：存在未注释函数，并输出清单。
void main(List<String> args) {
  final cfg = _parseArgs(args);
  final dirs = cfg.paths.isNotEmpty ? cfg.paths : [Directory('common/lib').path];
  final files = _listDartFiles(dirs, excludes: cfg.excludes);

  final missing = <String, List<_MissingFunction>>{};
  for (final f in files) {
    final misses = _checkFile(File(f));
    if (misses.isNotEmpty) {
      missing[f] = misses;
    }
  }

  if (missing.isEmpty) {
    stdout.writeln('OK: 所有扫描到的函数均存在函数级注释。');
    exit(0);
  }

  stdout.writeln('发现未添加函数级注释的函数：');
  missing.forEach((path, list) {
    stdout.writeln('- $path');
    for (final m in list) {
      stdout.writeln('  • 行 ${m.lineNumber}: ${m.signatureLine.trim()}');
    }
  });
  stdout.writeln('\n提示：请为上述函数补充 `///` 文档注释（含功能描述、参数、返回值与边界/异常说明）。');
  exit(2);
}

/// 解析命令行参数，返回扫描路径与排除模式。
_Config _parseArgs(List<String> args) {
  final paths = <String>[];
  final excludes = <String>[];

  for (int i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--paths') {
      // 收集直到下一个以 `--` 开头的参数或结束
      int j = i + 1;
      while (j < args.length && !args[j].startsWith('--')) {
        paths.add(args[j]);
        j++;
      }
      i = j - 1;
    } else if (a == '--exclude') {
      if (i + 1 < args.length) {
        excludes.add(args[++i]);
      }
    }
  }

  return _Config(paths: paths, excludes: excludes);
}

/// 列出指定目录下的所有 Dart 文件，支持排除模式。
List<String> _listDartFiles(List<String> dirs, {List<String> excludes = const []}) {
  final result = <String>[];
  for (final d in dirs) {
    final dir = Directory(d);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final p = entity.path;
        final skip = excludes.any((ex) => p.contains(ex)) ||
            p.endsWith('.g.dart') || p.contains('/.dart_tool/') || p.contains('/build/');
        if (!skip) result.add(p);
      }
    }
  }
  return result;
}

/// 检查单个文件，返回缺少函数级注释的函数列表。
List<_MissingFunction> _checkFile(File file) {
  final lines = file.readAsLinesSync();
  final misses = <_MissingFunction>[];

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (_isFunctionSignatureLine(line)) {
      if (!_hasLeadingDocComment(lines, i)) {
        misses.add(_MissingFunction(lineNumber: i + 1, signatureLine: line));
      }
    }
  }
  return misses;
}

/// 判断当前行是否可能是函数/方法的声明行（启发式）。
bool _isFunctionSignatureLine(String line) {
  final l = line.trim();
  if (l.isEmpty) return false;
  // 排除 typedef/abstract/interface 以及 class/enum 声明。
  if (l.startsWith('typedef ') || l.startsWith('class ') || l.startsWith('enum ') || l.startsWith('mixin ')) {
    return false;
  }
  // 启发式匹配：标识符(参数) 后跟 `{` 或 `=>` 或 `;`（外部接口/抽象）。
  final fn = RegExp(r'^[\w<>,\[\]\?\s]*\b[\w]+\s*\([^\)]*\)\s*(\{|=>|;)');
  return fn.hasMatch(l);
}

/// 判断在函数声明前是否存在文档注释（/// 或 /** */）。
bool _hasLeadingDocComment(List<String> lines, int signatureIndex) {
  // 回看最多 4 行，忽略空行；遇到非注释直接返回 false。
  int i = signatureIndex - 1;
  int steps = 0;
  bool sawTripleSlash = false;
  bool sawBlockDoc = false;

  while (i >= 0 && steps < 6) {
    final l = lines[i].trim();
    if (l.isEmpty) {
      i--; steps++; continue;
    }
    if (l.startsWith('///')) {
      sawTripleSlash = true; break;
    }
    if (l.startsWith('/**')) {
      // 向上查找块注释起点，简单判定。
      sawBlockDoc = true; break;
    }
    if (l.startsWith('/*')) {
      // 普通块注释，允许作为文档注释使用。
      sawBlockDoc = true; break;
    }
    // 其他内容（如注释以外的代码），判定无文档注释。
    return false;
  }

  return sawTripleSlash || sawBlockDoc;
}

/// 缺失函数注释的记录项。
class _MissingFunction {
  /// 缺少注释的函数所在的行号（1 基）。
  final int lineNumber;
  /// 函数声明行文本（用于输出提示）。
  final String signatureLine;

  _MissingFunction({required this.lineNumber, required this.signatureLine});
}

/// 命令行解析结果。
class _Config {
  /// 扫描路径集合。
  final List<String> paths;
  /// 排除模式集合。
  final List<String> excludes;

  _Config({required this.paths, required this.excludes});
}