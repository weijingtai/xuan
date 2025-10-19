import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/features/kao_ding_liu_qin/models/liu_qin_type.dart';
import 'package:tiebanshenshu/features/kao_ding_liu_qin/usecases/kao_ding_liu_qin_use_case.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('考订六亲集成测试', () {
    late KaoDingLiuQinUseCase useCase;

    setUp(() {
      useCase = KaoDingLiuQinUseCase();
    });

    test('完整计算流程 - 考父母', () async {
      // 使用测试八字：辛未年 辛未月 辛未日 辛未时 (辛未卦得需卦，包含所有六亲)
      final eightChars = EightChars(
        year: JiaZi.XIN_WEI,
        month: JiaZi.XIN_WEI,
        day: JiaZi.XIN_WEI,
        time: JiaZi.XIN_WEI,
      );

      final params = KaoDingLiuQinUseCaseParams(
        eightChars: eightChars,
        liuQinType: LiuQinType.father,
      );

      // 执行计算
      final result = await useCase.execute(params);

      // 验证基础信息
      expect(result.liuQinType, equals(LiuQinType.father));
      expect(result.pillar, equals(JiaZi.XIN_WEI)); // 年柱

      // 验证起卦结果
      expect(result.qiGuaResult.ganNumber, isNotNull);
      expect(result.qiGuaResult.xiaGua, isNotNull);
      expect(result.qiGuaResult.shangGua, isNotNull);

      // 验证纳甲结果
      expect(result.naJiaResult.sixYaoGua, isNotNull);
      expect(result.naJiaResult.gongGua, isNotNull);

      // 打印计算详情（用于调试）
      print('\n【考父母计算结果】');
      print(result.calculationDetail);
      print('\n条文编号: ${result.allTiaoWenNumbers}');
      // print('计算方法: ${result.tiaoWenNumbersByMethod.keys.toList()}');

      // 验证Session管理
      expect(useCase.sessionManager.historyCount, equals(1));
      expect(useCase.canUndo, isFalse); // 第一条记录，不能撤销
      expect(useCase.canRedo, isFalse);
    });

    test('完整计算流程 - 考夫妻', () async {
      final eightChars = EightChars(
        year: JiaZi.XIN_WEI,
        month: JiaZi.XIN_WEI,
        day: JiaZi.XIN_WEI,
        time: JiaZi.XIN_WEI,
      );

      final params = KaoDingLiuQinUseCaseParams(
        eightChars: eightChars,
        liuQinType: LiuQinType.wife,
      );

      final result = await useCase.execute(params);

      // 验证基础信息
      expect(result.liuQinType, equals(LiuQinType.wife));
      expect(result.pillar, equals(JiaZi.XIN_WEI)); // 日柱

      print('\n【考妻子计算结果】');
      print(result.calculationDetail);
    });

    test('批量计算多个六亲', () async {
      final eightChars = EightChars(
        year: JiaZi.XIN_WEI,
        month: JiaZi.XIN_WEI,
        day: JiaZi.XIN_WEI,
        time: JiaZi.XIN_WEI,
      );

      // 计算父、母、妻、子四种关系
      final results = await useCase.executeMultiple(eightChars, [
        LiuQinType.father,
        LiuQinType.mother,
        LiuQinType.wife,
        LiuQinType.son,
      ]);

      expect(results.length, equals(4));
      expect(results[LiuQinType.father]?.pillar, equals(JiaZi.XIN_WEI)); // 年柱
      expect(results[LiuQinType.mother]?.pillar, equals(JiaZi.XIN_WEI)); // 年柱
      expect(results[LiuQinType.wife]?.pillar, equals(JiaZi.XIN_WEI)); // 日柱
      expect(results[LiuQinType.son]?.pillar, equals(JiaZi.XIN_WEI)); // 时柱

      // 验证Session历史
      expect(useCase.sessionManager.historyCount, equals(4));
    });

    test('Session管理 - 撤销重做', () async {
      final eightChars = EightChars(
        year: JiaZi.XIN_WEI,
        month: JiaZi.XIN_WEI,
        day: JiaZi.XIN_WEI,
        time: JiaZi.XIN_WEI,
      );

      // 执行两次计算
      await useCase.execute(
        KaoDingLiuQinUseCaseParams(
          eightChars: eightChars,
          liuQinType: LiuQinType.father,
        ),
      );

      await useCase.execute(
        KaoDingLiuQinUseCaseParams(
          eightChars: eightChars,
          liuQinType: LiuQinType.wife,
        ),
      );

      expect(useCase.sessionManager.historyCount, equals(2));
      expect(useCase.canUndo, isTrue);
      expect(useCase.canRedo, isFalse);

      // 撤销
      final undoState = useCase.undo();
      expect(undoState, isNotNull);
      expect(undoState?.result.liuQinType, equals(LiuQinType.father));
      expect(useCase.canUndo, isFalse);
      expect(useCase.canRedo, isTrue);

      // 重做
      final redoState = useCase.redo();
      expect(redoState, isNotNull);
      expect(redoState?.result.liuQinType, equals(LiuQinType.wife));
      expect(useCase.canUndo, isTrue);
      expect(useCase.canRedo, isFalse);
    });

    test('Session管理 - 按类型筛选历史', () async {
      final eightChars = EightChars(
        year: JiaZi.XIN_WEI,
        month: JiaZi.XIN_WEI,
        day: JiaZi.XIN_WEI,
        time: JiaZi.XIN_WEI,
      );

      // 执行多次计算
      await useCase.execute(
        KaoDingLiuQinUseCaseParams(
          eightChars: eightChars,
          liuQinType: LiuQinType.father,
        ),
      );
      await useCase.execute(
        KaoDingLiuQinUseCaseParams(
          eightChars: eightChars,
          liuQinType: LiuQinType.wife,
        ),
      );
      await useCase.execute(
        KaoDingLiuQinUseCaseParams(
          eightChars: eightChars,
          liuQinType: LiuQinType.father,
        ),
      );

      // 筛选父亲相关的历史记录
      final fatherHistory = useCase.getHistoryByType(LiuQinType.father);
      expect(fatherHistory.length, equals(2));
      expect(
        fatherHistory.every((s) => s.result.liuQinType == LiuQinType.father),
        isTrue,
      );

      // 筛选妻子相关的历史记录
      final wifeHistory = useCase.getHistoryByType(LiuQinType.wife);
      expect(wifeHistory.length, equals(1));
    });

    test('统计信息', () async {
      final eightChars = EightChars(
        year: JiaZi.XIN_WEI,
        month: JiaZi.XIN_WEI,
        day: JiaZi.XIN_WEI,
        time: JiaZi.XIN_WEI,
      );

      // 执行多次计算
      await useCase.executeMultiple(eightChars, [
        LiuQinType.father,
        LiuQinType.wife,
        LiuQinType.son,
      ]);

      final stats = useCase.getStatistics();
      expect(stats['totalCount'], equals(3));
      expect(stats['countByType'], isNotNull);

      print('\n【统计信息】');
      print(stats);
    });
  });
}
