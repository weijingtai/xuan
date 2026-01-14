import 'dart:io';

import 'package:yaml/yaml.dart';

class YamlFileLoader {
  const YamlFileLoader();

  Future<String?> readFileIfExists(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  Map<String, Object?> parseToMap(String content) {
    final doc = loadYaml(content);
    if (doc is! YamlMap) {
      throw const FormatException('YAML root must be a map');
    }

    final out = <String, Object?>{};
    for (final entry in doc.entries) {
      final key = entry.key;
      if (key is! String) continue;
      out[key] = _toPlainDart(entry.value);
    }
    return out;
  }

  Object? _toPlainDart(Object? value) {
    if (value is YamlMap) {
      final out = <String, Object?>{};
      for (final entry in value.entries) {
        final key = entry.key;
        if (key is! String) continue;
        out[key] = _toPlainDart(entry.value);
      }
      return out;
    }

    if (value is YamlList) {
      return value.map(_toPlainDart).toList(growable: false);
    }

    if (value is num) {
      if (value is int) return value;
      if (value == value.roundToDouble()) return value.toInt();
      return value;
    }

    if (value is String || value is bool || value == null) return value;

    return value.toString();
  }
}

