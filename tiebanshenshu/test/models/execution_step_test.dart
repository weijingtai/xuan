import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/algorithm/models/execution_step.dart';
import 'package:tiebanshenshu/algorithm/models/conditional_branch.dart';

void main() {
  group('ExecutionStep Serialization', () {
    final mockBranch = ConditionalBranch(
      condition: 'test == true',
      trueSteps: ['step2'],
    );

    final mockStep = ExecutionStep(
      id: 'step1',
      name: 'Test Step',
      description: 'A step for testing',
      operationId: 'test_op',
      config: {'retries': 3},
      inputs: {'input1': 'source1'},
      outputs: {'output1': 'dest1'},
      conditionalBranches: [mockBranch],
      required: true,
      timeoutMs: 5000,
      retryCount: 1,
      dependencies: ['step0'],
      isOptional: false,
    );

    test('should serialize to and deserialize from JSON correctly', () {
      // Act
      final json = mockStep.toJson();
      final deserializedStep = ExecutionStep.fromJson(json);

      // Assert
      expect(deserializedStep, equals(mockStep));
    });

    test('should handle nullable and default value fields correctly', () {
      // Arrange
      final minimalJson = {
        'id': 'minimal_step',
        'operationId': 'minimal_op',
      };

      // Act
      final deserializedStep = ExecutionStep.fromJson(minimalJson);

      // Assert
      expect(deserializedStep.id, 'minimal_step');
      expect(deserializedStep.name, '');
      expect(deserializedStep.description, '');
      expect(deserializedStep.config, isEmpty);
      expect(deserializedStep.inputs, isEmpty);
      expect(deserializedStep.outputs, isEmpty);
      expect(deserializedStep.conditionalBranches, isNull); // Note: conditionalBranches is nullable
      expect(deserializedStep.required, isTrue);
      expect(deserializedStep.retryCount, 0);
      expect(deserializedStep.dependencies, isEmpty);
    });
  });
}
