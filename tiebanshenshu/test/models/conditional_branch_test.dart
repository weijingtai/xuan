import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/algorithm/models/conditional_branch.dart';

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
  });
}
