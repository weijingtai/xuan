import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/algorithm/models/rule_set.dart';

void main() {
  group('Rule and RuleSet Serialization', () {
    final mockRule = Rule(
      id: 'rule1',
      name: 'Test Rule',
      description: 'A rule for testing',
      condition: 'input > 10',
      action: {'type': 'ADD', 'value': 5},
      priority: 1,
      enabled: true,
      parameters: {'mode': 'strict'},
    );

    final mockRuleSet = RuleSet(
      name: 'Test RuleSet',
      description: 'A set of rules for testing',
      rules: [mockRule],
      type: RuleSetType.validation,
      priority: 10,
      enabled: true,
    );

    test('Rule should serialize to and deserialize from JSON correctly', () {
      // Act
      final json = mockRule.toJson();
      final deserializedRule = Rule.fromJson(json);

      // Assert
      expect(deserializedRule, equals(mockRule));
    });

    test('RuleSet should serialize to and deserialize from JSON correctly', () {
      // Act
      final json = mockRuleSet.toJson();
      final deserializedRuleSet = RuleSet.fromJson(json);

      // Assert
      expect(deserializedRuleSet, equals(mockRuleSet));
    });

     test('RuleSet should handle default values correctly', () {
      // Arrange
      final minimalJson = {
        'name': 'Minimal RuleSet',
        'rules': [],
      };

      // Act
      final deserializedRuleSet = RuleSet.fromJson(minimalJson);

      // Assert
      expect(deserializedRuleSet.name, 'Minimal RuleSet');
      expect(deserializedRuleSet.description, '');
      expect(deserializedRuleSet.type, RuleSetType.standard);
      expect(deserializedRuleSet.priority, 0);
      expect(deserializedRuleSet.enabled, isTrue);
    });
  });
}
