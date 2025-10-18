import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/features/kao_ding_liu_qin/models/liu_qin_type.dart';
import 'package:tiebanshenshu/features/kao_ding_liu_qin/usecases/kao_ding_liu_qin_use_case.dart';

void main() {
  group('考订六亲基础测试', () {
    late KaoDingLiuQinUseCase useCase;

    setUp(() {
      useCase = KaoDingLiuQinUseCase();
    });

    test('测试八字到柱位映射', () {
      final eightChars = EightChars(
        year: JiaZi.JIA_ZI,
        month: JiaZi.YI_CHOU,
        day: JiaZi.BING_YIN,
        time: JiaZi.DING_MAO,
      );

      // 测试考父母 - 应该使用年柱
      final fatherParams = KaoDingLiuQinUseCaseParams(
        eightChars: eightChars,
        liuQinType: LiuQinType.father,
      );
      expect(fatherParams.correspondingPillar, equals(JiaZi.JIA_ZI));

      // 测试考夫妻 - 应该使用日柱
      final wifeParams = KaoDingLiuQinUseCaseParams(
        eightChars: eightChars,
        liuQinType: LiuQinType.wife,
      );
      expect(wifeParams.correspondingPillar, equals(JiaZi.BING_YIN));

      // 测试考兄弟 - 应该使用月柱
      final siblingParams = KaoDingLiuQinUseCaseParams(
        eightChars: eightChars,
        liuQinType: LiuQinType.sibling,
      );
      expect(siblingParams.correspondingPillar, equals(JiaZi.YI_CHOU));

      // 测试考子女 - 应该使用时柱
      final sonParams = KaoDingLiuQinUseCaseParams(
        eightChars: eightChars,
        liuQinType: LiuQinType.son,
      );
      expect(sonParams.correspondingPillar, equals(JiaZi.DING_MAO));
    });

    test('测试LiuQinType扩展属性', () {
      expect(LiuQinType.father.displayName, equals('父亲'));
      expect(LiuQinType.mother.displayName, equals('母亲'));
      expect(LiuQinType.wife.displayName, equals('妻子'));
      expect(LiuQinType.husband.displayName, equals('丈夫'));
      expect(LiuQinType.sibling.displayName, equals('兄弟姐妹'));
      expect(LiuQinType.son.displayName, equals('儿子'));
      expect(LiuQinType.daughter.displayName, equals('女儿'));

      expect(LiuQinType.father.correspondingPillar, equals('年柱'));
      expect(LiuQinType.wife.correspondingPillar, equals('日柱'));
      expect(LiuQinType.sibling.correspondingPillar, equals('月柱'));
      expect(LiuQinType.son.correspondingPillar, equals('时柱'));

      expect(LiuQinType.father.isParent, isTrue);
      expect(LiuQinType.mother.isParent, isTrue);
      expect(LiuQinType.wife.isSpouse, isTrue);
      expect(LiuQinType.husband.isSpouse, isTrue);
      expect(LiuQinType.sibling.isSibling, isTrue);
      expect(LiuQinType.son.isChild, isTrue);
      expect(LiuQinType.daughter.isChild, isTrue);
    });

    test('测试Session管理器基础功能', () {
      final sessionManager = useCase.sessionManager;

      expect(sessionManager.canUndo, isFalse);
      expect(sessionManager.canRedo, isFalse);
      expect(sessionManager.historyCount, equals(0));
    });
  });

  group('起卦逻辑测试', () {
    test('测试干支配数', () {
      // 测试天干配数
      expect(TianGan.JIA.index, equals(0)); // 甲对应6
      expect(TianGan.YI.index, equals(1)); // 乙对应2

      // 测试地支配数
      expect(DiZhi.ZI.index, equals(0)); // 子对应[1,6]
      expect(DiZhi.CHOU.index, equals(1)); // 丑对应[5,10]
    });
  });
}
