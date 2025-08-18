import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/algorithm/models/conditional_branch.dart';
import 'package:tiebanshenshu/algorithm/models/execution_step.dart';

void main() {
  group('ConditionalBranch Serialization', () {
    final mockBranch = ConditionalBranch(
      condition: 'variable > 10',
      description: 'A test branch',
      trueSteps: ['stepA'],
      falseSteps: ['stepB'],
      type: ConditionType.expression,
      parameters: {'detail': 'value'},
    );

    test('should serialize to and deserialize from JSON correctly', () {
      // Act
      final json = mockBranch.toJson();
      final deserializedBranch = ConditionalBranch.fromJson(json);

      // Assert
      expect(deserializedBranch, equals(mockBranch));
    });

    test('should handle nullable and default value fields correctly', () {
      // Arrange
      final minimalJson = {
        'condition': 'variable == null',
        'trueSteps': ['stepC'],
      };

      // Act
      final deserializedBranch = ConditionalBranch.fromJson(minimalJson);

      // Assert
      expect(deserializedBranch.condition, 'variable == null');
      expect(deserializedBranch.description, '');
      expect(deserializedBranch.falseSteps, isNull);
      expect(deserializedBranch.type, ConditionType.expression);
      expect(deserializedBranch.parameters, isEmpty);
    });

    test(
      'should verify no conditional branches in sample algorithm steps',
      () async {
        // Arrange
        final file = File('../assets/algorithms/sample_algorithm_1.json');
        final jsonString = await file.readAsString();
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        final stepsData = jsonData['steps'] as List<dynamic>;

        // Act
        final steps = stepsData
            .map(
              (stepJson) =>
                  ExecutionStep.fromJson(stepJson as Map<String, dynamic>),
            )
            .toList();

        // Assert
        for (final step in steps) {
          expect(step.conditionalBranches, isNull);
        }
      },
    );

    test(
      'should handle algorithm structure validation for conditional branches',
      () async {
        // Arrange
        final file = File('../assets/algorithms/sample_algorithm_1.json');
        final jsonString = await file.readAsString();
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;

        // Act & Assert
        expect(jsonData.containsKey('steps'), isTrue);
        final stepsData = jsonData['steps'] as List<dynamic>;

        // Verify each step structure
        for (final stepData in stepsData) {
          final stepMap = stepData as Map<String, dynamic>;
          expect(stepMap.containsKey('id'), isTrue);
          expect(stepMap.containsKey('operationId'), isTrue);
          // conditionalBranches field is optional and not present in sample
          expect(stepMap.containsKey('conditionalBranches'), isFalse);
        }
      },
    );
  });
}
