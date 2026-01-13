import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

void main() {
  test('测试获取项目根路径', () {
    String joinPath(String a, String b) {
      if (a.endsWith(Platform.pathSeparator)) return '$a$b';
      return '$a${Platform.pathSeparator}$b';
    }

    String findProjectRoot() {
      var dir = Directory.current;
      while (true) {
        final pubspecFile = File(joinPath(dir.path, 'pubspec.yaml'));
        if (pubspecFile.existsSync()) return dir.path;
        final parent = dir.parent;
        if (parent.path == dir.path) {
          throw StateError(
              'Unable to find pubspec.yaml from ${Directory.current.path}');
        }
        dir = parent;
      }
    }

    final projectRoot = findProjectRoot();
    expect(File(joinPath(projectRoot, 'pubspec.yaml')).existsSync(), true);
    expect(Directory(joinPath(projectRoot, 'assets')).existsSync(), true);
  });
}
