import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import 'package:xuan/utils/path_utils.dart';

void main() {
  test('测试路径工具类', () {
    // 获取项目根目录
    final projectRoot = PathUtils.projectRoot;
    print('项目根目录：$projectRoot');

    // 验证项目根目录是否正确
    final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
    expect(pubspecFile.existsSync(), true, reason: 'pubspec.yaml 文件应该存在');

    // 测试其他路径
    print('assets 目录：${PathUtils.assetsPath}');
    print('lib 目录：${PathUtils.libPath}');
    print('test 目录：${PathUtils.testPath}');

    // 验证目录是否存在
    expect(Directory(PathUtils.assetsPath).existsSync(), true);
    expect(Directory(PathUtils.libPath).existsSync(), true);
    expect(Directory(PathUtils.testPath).existsSync(), true);

    // 测试资源路径
    final assetPath = PathUtils.getAssetPath('icons/icon.png');
    print('资源路径：$assetPath');

    // 测试测试文件路径
    final testPath = PathUtils.getTestPath('utils/path_utils_test.dart');
    print('测试文件路径：$testPath');
    expect(File(testPath).existsSync(), true);
  });
}
