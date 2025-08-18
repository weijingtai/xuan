import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/algorithm/models/algorithm_config.dart';
import 'package:tiebanshenshu/algorithm/models/execution_step.dart';

void main() {
  group('AlgorithmConfig Serialization', () {
    final createdAt = DateTime.now();
    final updatedAt = DateTime.now().add(const Duration(hours: 1));

    final mockStep = ExecutionStep(
      id: 'step1',
      operationId: 'test_op',
    );

    final mockConfig = AlgorithmConfig(
      name: 'Test Algorithm',
      version: '1.0.0',
      description: 'A test description',
      steps: [mockStep],
      globalConfig: {'key': 'value'},
      ruleSets: const [],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    test('should serialize to and deserialize from JSON correctly', () {
      // Act
      final json = mockConfig.toJson();
      final deserializedConfig = AlgorithmConfig.fromJson(json);

      // Assert
      expect(deserializedConfig, equals(mockConfig));
    });

    test('should handle nullable and default value fields correctly', () {
      // Arrange
      final minimalJson = {
        'name': 'Minimal Algorithm',
        'version': '1.0.1',
        'description': '',
        'steps': [],
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

      // Act
      final deserializedConfig = AlgorithmConfig.fromJson(minimalJson);

      // Assert
      expect(deserializedConfig.name, 'Minimal Algorithm');
      expect(deserializedConfig.ruleSets, isEmpty);
      expect(deserializedConfig.globalConfig, isNull);
    });
  });
}
