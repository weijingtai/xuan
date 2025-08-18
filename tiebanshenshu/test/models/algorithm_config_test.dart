import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/algorithm/models/algorithm_config.dart';
import 'package:tiebanshenshu/algorithm/models/execution_step.dart';

void main() {
  group('AlgorithmConfig Serialization', () {
    test('should serialize to and deserialize from JSON correctly', () {
      // read  test data from assets/algorithms/calculate_one_pillar.json
      final testFilePath = 'assets/algorithms/calculate_one_pillar.json';
      expect(File(testFilePath).existsSync(), true);
      final testData = File(testFilePath).readAsStringSync();
      var jsonData = jsonDecode(testData);
      // jsonData["globalConfig"] = null;
      // jsonData["ruleSets"] = [];
      // jsonData["steps"] = [];
      // print(jsonData["steps"]);
      // print(jsonData["ruleSets"]);
      // print(jsonData["globalConfig"]);
      // print(jsonData);
      AlgorithmConfig.fromJson(jsonData);
    });
  });
}
