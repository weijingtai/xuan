import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/algorithm/operations/domain_specific_operations.dart';
import 'package:tiebanshenshu/algorithm/models/execution_context.dart';
import 'package:tiebanshenshu/algorithm/models/algorithm_config.dart';
import 'package:tiebanshenshu/algorithm/atomic_operation_registry.dart';

void main() {
  group('GenerateNajiaAtom', () {
    late GenerateNajiaAtom atom;
    late ExecutionContext context;

    setUp(() {
      atom = GenerateNajiaAtom();
      // Create a mock context for the test
      context = ExecutionContext(
        inputs: {},
        config: AlgorithmConfig(
          name: 'test',
          version: '1.0',
          description: '',
          steps: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        operationRegistry: AtomicOperationRegistry(),
      );
    });

    test('should generate correct Najia list for Yang year', () async {
      // Arrange
      final inputs = {
        'hexagram': {'upper': '乾', 'lower': '艮'}, // GuaName: 乾艮
        'isYang': true,
      };

      // Expected Najia for 乾艮 (BenGua is 遁) in a Yang year
      // 乾 -> 壬 (壬戌, 壬申, 壬午)
      // 艮 -> 丙 (丙辰, 丙寅, 丙子)
      final expectedNajia = ['壬戌', '壬申', '壬午', '丙辰', '丙寅', '丙子'];

      // Act
      final result = await atom.execute(context, inputs, {});
      final najiaList = result['najia_list'] as List<dynamic>;

      // Assert
      expect(najiaList, equals(expectedNajia));
    });

    test('should generate correct Najia list for Yin year', () async {
      // Arrange
      final inputs = {
        'hexagram': {'upper': '乾', 'lower': '艮'}, // GuaName: 乾艮
        'isYang': false,
      };

      // Expected Najia for 乾艮 (BenGua is 遁) in a Yin year
      // 乾 -> 甲 (甲戌, 甲申, 甲午)
      // 艮 -> 丙 (丙辰, 丙寅, 丙子)
      final expectedNajia = ['甲戌', '甲申', '甲午', '丙辰', '丙寅', '丙子'];

      // Act
      final result = await atom.execute(context, inputs, {});
      final najiaList = result['najia_list'] as List<dynamic>;

      // Assert
      expect(najiaList, equals(expectedNajia));
    });

    test('should throw argument error for invalid input', () async {
      // Arrange
      final inputs = {
        'hexagram': {'upper': '乾'}, // Missing 'lower'
        'isYang': true,
      };

      // Act & Assert
      expect(
        () async => await atom.execute(context, inputs, {}),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
