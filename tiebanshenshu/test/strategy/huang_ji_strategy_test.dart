import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/models/huang_ji_formula.dart';
import 'package:tiebanshenshu/domain/models/huang_ji_number.dart';
import 'package:tiebanshenshu/service/strategy/huang_ji_strategy.dart';

void main() {
  late HuangJiStrategy strategy = HuangJiStrategy();
  late EightChars testEightChars = EightChars(
    year: JiaZi.YI_HAI, // 乙亥
    month: JiaZi.DING_HAI, // 丁亥
    day: JiaZi.REN_ZI, // 壬子
    time: JiaZi.XIN_HAI, // 辛亥
  );

  group("皇极经世取条文数 公式", () {
    test("基本数一 + 百位月干太玄数 = 经世取条文数", () {
      HuangJiTiaoWenCalculationFormula basePart =
          HuangJiTiaoWenCalculationFormula(
            id: 1,
            name: "元会·条文一",
            description: "基本数一（元会+千位年干） + 月干太玄（百位） = 经世取条文数",
            basePart: HuangJiFormulaBasePart(
              baseNumberType: BaseNumberType.primary,
              numberSource: NumberSource.yuanHui,
            ),
            otherPartsList: [
              HuangJiFormulaOtherSingleNumberPart(
                forBaseOperator: EnumHuangJiOperator.add,
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.year,
                numberPlace: EnumNumberPlace.Thousands,
              ),
              HuangJiFormulaOtherSingleNumberPart(
                forBaseOperator: EnumHuangJiOperator.add,
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.month,
                numberPlace: EnumNumberPlace.Hundreds,
              ),
            ],
          );
      final yuanhuiyunshi = strategy.calcuateYuanHuiYinShi(testEightChars);
      final yearGanThu = HuangJiPlacedNumber.generateWithGanZhi(
        yuanhuiyunshi.yearGanNumber,
        EnumNumberPlace.Thousands,
        FourZhuName.year,
        FourZhuGanZhiType.gan,
      );
      final yuanHuiPrimary = strategy.calcuateBaseNumber(
        yuanhuiyunshi.yuanHuiMergeNumber,
        yearGanThu,
      );
      final yunShiPrimary = strategy.calcuateBaseNumber(
        yuanhuiyunshi.yunShiMergeNumber,
        yearGanThu,
      );
      expect(yuanHuiPrimary.number, equals(9210)); // 12
      expect(yunShiPrimary.number, equals(1111)); // 12
      expect(yunShiPrimary.orinialNumber, equals(13111)); // 12
      int res = strategy.tiaoWenFormulaExecutor(basePart, yuanhuiyunshi);
      expect(res, equals(9810)); // 12
    });
    test("基本数一 + 百位月干太玄数 = 经世取条文数二", () {
      HuangJiTiaoWenCalculationFormula basePart =
          HuangJiTiaoWenCalculationFormula(
            id: 2,
            name: "运世·条文一",
            description: "基本数一（运世+千位年干）+ 日干支合数（干在十位，支在个位） + 个位时干太玄 = 条文数",
            basePart: HuangJiFormulaBasePart(
              // 运世基础数
              baseNumberType: BaseNumberType.basic,
              numberSource: NumberSource.yunShi,
            ),
            otherPartsList: [
              // 年干 千位
              HuangJiFormulaOtherSingleNumberPart(
                forBaseOperator: EnumHuangJiOperator.add,
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.year,
                numberPlace: EnumNumberPlace.Thousands,
              ),
              // 日干支合数（干在十位，支在个位）
              HuangJiFormulaOtherSingleNumberPart(
                forBaseOperator: EnumHuangJiOperator.add,
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Tens,
              ),
              HuangJiFormulaOtherSingleNumberPart(
                forBaseOperator: EnumHuangJiOperator.add,
                fourZhuGanZhiType: FourZhuGanZhiType.zhi,
                fourZhuName: FourZhuName.day,
                numberPlace: EnumNumberPlace.Units,
              ),

              HuangJiFormulaOtherSingleNumberPart(
                forBaseOperator: EnumHuangJiOperator.add,
                fourZhuGanZhiType: FourZhuGanZhiType.gan,
                fourZhuName: FourZhuName.time,
                numberPlace: EnumNumberPlace.Units,
              ),
            ],
          );
      final yuanhuiyunshi = strategy.calcuateYuanHuiYinShi(testEightChars);
      final yearGanThu = HuangJiPlacedNumber.generateWithGanZhi(
        yuanhuiyunshi.yearGanNumber,
        EnumNumberPlace.Thousands,
        FourZhuName.year,
        FourZhuGanZhiType.gan,
      );
      final yuanHuiPrimary = strategy.calcuateBaseNumber(
        yuanhuiyunshi.yuanHuiMergeNumber,
        yearGanThu,
      );
      final yunShiPrimary = strategy.calcuateBaseNumber(
        yuanhuiyunshi.yunShiMergeNumber,
        yearGanThu,
      );
      expect(yuanHuiPrimary.number, equals(9210)); // 12
      expect(yunShiPrimary.number, equals(1111)); // 12
      expect(yunShiPrimary.orinialNumber, equals(13111)); // 12
      int res = strategy.tiaoWenFormulaExecutor(basePart, yuanhuiyunshi);
      expect(res, equals(1187)); //
    });
  });
  group('HuangJiCalculationStrategy', () {
    group('基础计算功能', () {
      test('配太玄数', () async {
        final result = strategy.calcuateYuanHuiYinShi(testEightChars);
        expect(result.yearGanNumber, equals(8)); // 乙亥
        expect(result.yearZhiNumber, equals(4)); // 乙亥
        expect(result.monthGanNumber, equals(6)); // 丁亥
        expect(result.monthZhiNumber, equals(4)); // 丁亥
        expect(result.dayGanNumber, equals(6)); // 壬子
        expect(result.dayZhiNumber, equals(9)); // 壬子
        expect(result.timeGanNumber, equals(7)); // 辛亥
        expect(result.timeZhiNumber, equals(4)); // 辛亥
      });
      test("求 元会 、运世", () {
        final result = strategy.calcuateYuanHuiYinShi(testEightChars);
        expect(result.yuanNumber, equals(12));
        expect(result.huiNumber, equals(10));
        expect(result.yunNumber, equals(15));
        expect(result.shiNumber, equals(11));

        expect(result.yuanHuiMergeNumber.number, equals(1210)); // 12
        expect(result.yunShiMergeNumber.number, equals(5111)); // 12
      });

      test("求 元会基本数 、运世运世基本数 （各加年干千位）", () {
        final result = strategy.calcuateYuanHuiYinShi(testEightChars);
        final yearGanThu = HuangJiPlacedNumber.generateWithGanZhi(
          result.yearGanNumber,
          EnumNumberPlace.Thousands,
          FourZhuName.year,
          FourZhuGanZhiType.gan,
        );
        final yuanHuiPrimary = strategy.calcuateBaseNumber(
          result.yuanHuiMergeNumber,
          yearGanThu,
        );
        final yunShiPrimary = strategy.calcuateBaseNumber(
          result.yunShiMergeNumber,
          yearGanThu,
        );
        expect(yuanHuiPrimary.number, equals(9210)); // 12
        expect(yunShiPrimary.number, equals(1111)); // 12
        expect(yuanHuiPrimary.orinialNumber, equals(13111)); // 12
      });
    });
  });
}
