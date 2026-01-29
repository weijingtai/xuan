import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/features/kao_ding_liu_qin/usecases/kao_ding_liu_qin_use_case.dart';
import 'package:tiebanshenshu/features/kao_ding_liu_qin/models/liu_qin_type.dart';

/// 测试考订六亲的化卦功能
void main() {
  // 初始化Flutter测试绑定
  TestWidgetsFlutterBinding.ensureInitialized();

  group('考订六亲化卦测试', () {
    late KaoDingLiuQinUseCase useCase;

    setUp(() {
      useCase = KaoDingLiuQinUseCase();
    });

    test('应该能够使用选择的条文编号进行化卦', () {
      // 准备测试数据 - 使用示例条文编号
      final selectedTiaoWenNumbers = {
        LiuQinType.father: 1234,
        LiuQinType.mother: 5678,
        LiuQinType.husband: 2345,
        LiuQinType.wife: 6789,
        LiuQinType.sibling: 3456,
        LiuQinType.son: 7890,
        LiuQinType.daughter: 4567,
      };

      // 执行化卦
      final huaGuaResults = useCase.performHuaGua(selectedTiaoWenNumbers);

      // 验证结果
      expect(huaGuaResults.length, equals(7));
      expect(huaGuaResults.keys, containsAll(LiuQinType.values));

      // 验证每个化卦结果都有值
      for (final entry in huaGuaResults.entries) {
        final result = entry.value;
        expect(result.shangGuaNumber, greaterThan(0));
        expect(result.shangGuaNumber, lessThanOrEqualTo(8));
        expect(result.xiaGuaNumber, greaterThan(0));
        expect(result.xiaGuaNumber, lessThanOrEqualTo(8));
        expect(result.shangGuaName, isNotEmpty);
        expect(result.xiaGuaName, isNotEmpty);
      }
    });

    test('应该能够获取64卦结果', () {
      // 准备测试数据
      final selectedTiaoWenNumbers = {
        LiuQinType.father: 1234,
        LiuQinType.mother: 5678,
      };

      // 获取64卦结果
      final gua64Results = useCase.getHuaGua64(selectedTiaoWenNumbers);

      // 验证结果
      expect(gua64Results.length, equals(2));
      expect(gua64Results[LiuQinType.father], isNotNull);
      expect(gua64Results[LiuQinType.mother], isNotNull);

      // 打印化卦结果用于调试
      print('\n化卦结果:');
      for (final entry in gua64Results.entries) {
        final gua64 = entry.value;
        print('${entry.key.displayName}: ${gua64?.name ?? "无"}');
      }
    });

    test('完整流程测试 - 从八字到化卦', () async {
      // 1. 准备八字
      final eightChars = EightChars(
        year: JiaZi.GUI_WEI,   // 癸未
        month: JiaZi.REN_WU,   // 壬午
        day: JiaZi.WU_SHEN,    // 戊申
        time: JiaZi.WU_SHEN,   // 戊申
      );

      // 2. 计算父母和夫妻两个类型
      final params1 = KaoDingLiuQinUseCaseParams(
        eightChars: eightChars,
        liuQinType: LiuQinType.father,
      );
      final params2 = KaoDingLiuQinUseCaseParams(
        eightChars: eightChars,
        liuQinType: LiuQinType.wife,
      );

      final result1 = await useCase.execute(params1);
      final result2 = await useCase.execute(params2);

      // 3. 获取目标条目的条文编号（或手动选择）
      final selectedNumbers = {
        LiuQinType.father: result1.targetEntry?.tiaoWenNumber ?? 1234,
        LiuQinType.wife: result2.targetEntry?.tiaoWenNumber ?? 5678,
      };

      print('\n选择的条文编号:');
      print('父: ${selectedNumbers[LiuQinType.father]}');
      print('妻: ${selectedNumbers[LiuQinType.wife]}');

      // 4. 执行化卦
      final huaGuaResults = useCase.performHuaGua(selectedNumbers);
      final gua64Results = useCase.getHuaGua64(selectedNumbers);

      // 5. 验证结果
      expect(huaGuaResults.length, equals(2));
      expect(gua64Results.length, equals(2));

      print('\n化卦结果:');
      for (final entry in gua64Results.entries) {
        final huaGua = huaGuaResults[entry.key];
        final gua64 = entry.value;
        print('${entry.key.displayName}:');
        print('  上卦: ${huaGua?.shangGuaName} (${huaGua?.shangGuaNumber})');
        print('  下卦: ${huaGua?.xiaGuaName} (${huaGua?.xiaGuaNumber})');
        print('  64卦: ${gua64?.name ?? "无"}');
      }
    });
  });
}
