import 'dart:io';
import 'package:path/path.dart' as path;

/// 路径工具类
class PathUtils {
  static String? _projectRoot;

  /// 获取项目根目录
  static String get projectRoot {
    if (_projectRoot != null) return _projectRoot!;

    // 获取当前工作目录
    final currentDir = Directory.current.path;

    // 向上查找直到找到 pubspec.yaml
    var dir = currentDir;
    while (true) {
      final pubspecPath = path.join(dir, 'pubspec.yaml');
      if (File(pubspecPath).existsSync()) {
        _projectRoot = dir;
        return dir;
      }

      final parent = path.dirname(dir);
      if (parent == dir) {
        throw Exception('无法找到项目根目录');
      }
      dir = parent;
    }
  }

  /// 获取 assets 目录路径
  static String get assetsPath => path.join(projectRoot, 'assets');

  /// 获取 lib 目录路径
  static String get libPath => path.join(projectRoot, 'lib');

  /// 获取 test 目录路径
  static String get testPath => path.join(projectRoot, 'test');

  /// 获取指定资源的完整路径
  static String getAssetPath(String assetPath) {
    return path.join(assetsPath, assetPath);
  }

  /// 获取指定测试文件的完整路径
  static String getTestPath(String testPath) {
    return path.join(projectRoot, 'test', testPath);
  }
}
