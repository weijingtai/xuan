import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  test('测试获取项目根路径', () {
    // 方法1：使用 Directory.current
    final currentDir = Directory.current;
    print('当前工作目录：${currentDir.path}');

    // 方法2：使用 Platform.script 获取当前脚本路径，然后向上查找项目根目录
    final scriptPath = Platform.script.toFilePath();
    print('当前脚本路径：$scriptPath');

    // 方法3：使用 path 包处理路径
    final projectRoot = path.normalize(path.join(currentDir.path, '..'));
    print('项目根目录：$projectRoot');

    // 验证路径是否存在
    final pubspecPath = path.join(projectRoot, 'pubspec.yaml');
    final pubspecFile = File(pubspecPath);
    expect(pubspecFile.existsSync(), true, reason: 'pubspec.yaml 文件应该存在');

    // 获取 assets 目录路径
    final assetsPath = path.join(projectRoot, 'assets');
    final assetsDir = Directory(assetsPath);
    expect(assetsDir.existsSync(), true, reason: 'assets 目录应该存在');
  });
}
