import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart'; // Enum64Gua
import 'package:tiebanshenshu/service/strategy/ba_gua_jia_ze_strategy.dart';

void main() {
  group('BaGuaJiaZeStrategy 公开方法测试', () {
    test('爻序法 - 应该正确计算雷泽归妹卦', () {
      // Arrange
      final gua64 = Enum64Gua.lei_ze_gui_mei; // 雷泽归妹 (震上兑下)

      // Act
      final result = BaGuaJiaZeStrategy.calculateByYaoSequenceFromGua64(gua64);

      // Assert
      expect(result, isNotNull);
      expect(result.methodName, '爻序法');
      expect(result.tiaoWenNumber, greaterThan(0));
      expect(result.tiaoWenNumber, lessThanOrEqualTo(9999));
      expect(result.pureSixYaoGua, isNotNull);
      expect(result.formula, isNotEmpty);
      expect(result.formula, contains('000'));
      expect(result.description, contains('爻序法'));

      // ignore: avoid_print
      print('爻序法结果: ${result.summary}');
    });

    test('纳甲法 - 应该正确计算雷泽归妹卦', () {
      // Arrange
      final gua64 = Enum64Gua.lei_ze_gui_mei; // 雷泽归妹 (震上兑下)

      // Act
      final result = BaGuaJiaZeStrategy.calculateByNaJiaFromGua64(gua64);

      // Assert
      expect(result, isNotNull);
      expect(result.methodName, '纳甲法');
      expect(result.tiaoWenNumber, greaterThan(0));
      expect(result.tiaoWenNumber, lessThanOrEqualTo(9999));
      expect(result.pureSixYaoGua, isNotNull);
      expect(result.formula, isNotEmpty);
      expect(result.formula, contains('000'));
      expect(result.description, contains('纳甲法'));

      // ignore: avoid_print
      print('纳甲法结果: ${result.summary}');
    });

    test('两种方法应该产生不同的条文数', () {
      // Arrange
      final gua64 = Enum64Gua.qian_wei_tian; // 乾为天

      // Act
      final yaoSeqResult = BaGuaJiaZeStrategy.calculateByYaoSequenceFromGua64(gua64);
      final naJiaResult = BaGuaJiaZeStrategy.calculateByNaJiaFromGua64(gua64);

      // Debug output
      // ignore: avoid_print
      print('乾为天 - 爻序法: ${yaoSeqResult.summary}');
      // ignore: avoid_print
      print('乾为天 - 纳甲法: ${naJiaResult.summary}');
      // ignore: avoid_print
      print('爻序法 yaoSum: ${yaoSeqResult.yaoSum}');
      // ignore: avoid_print
      print('纳甲法 yaoSum: ${naJiaResult.yaoSum}');

      // Assert
      expect(yaoSeqResult.tiaoWenNumber, isNot(equals(naJiaResult.tiaoWenNumber)));
      expect(yaoSeqResult.yaoSum, isNot(equals(naJiaResult.yaoSum)));

      // ignore: avoid_print
      print('乾为天 - 爻序法: ${yaoSeqResult.tiaoWenNumber}, 纳甲法: ${naJiaResult.tiaoWenNumber}');
    });

    test('应该正确处理坤为地卦', () {
      // Arrange
      final gua64 = Enum64Gua.kun_wei_di; // 坤为地

      // Act
      final yaoSeqResult = BaGuaJiaZeStrategy.calculateByYaoSequenceFromGua64(gua64);
      final naJiaResult = BaGuaJiaZeStrategy.calculateByNaJiaFromGua64(gua64);

      // Assert
      // 在后天八卦中，坤=2（不是先天八卦的8）
      expect(yaoSeqResult.upperGuaNumber, 2); // 后天坤为2
      expect(yaoSeqResult.lowerGuaNumber, 2);
      expect(naJiaResult.upperGuaNumber, 2);
      expect(naJiaResult.lowerGuaNumber, 2);

      // ignore: avoid_print
      print('坤为地 - 爻序法: ${yaoSeqResult.summary}');
      // ignore: avoid_print
      print('坤为地 - 纳甲法: ${naJiaResult.summary}');
    });

    test('验证计算公式格式', () {
      // Arrange
      final gua64 = Enum64Gua.shui_lei_tun; // 水雷屯 (坎上震下)

      // Act
      final result = BaGuaJiaZeStrategy.calculateByYaoSequenceFromGua64(gua64);

      // Assert
      // 公式格式应该是: "上卦数000 + 六爻总和 - 下卦数 = 结果"
      final formulaParts = result.formula.split(' ');
      expect(formulaParts, contains('+'));
      expect(formulaParts, contains('-'));
      expect(formulaParts, contains('='));

      // ignore: avoid_print
      print('水雷屯公式: ${result.formula}');
    });

    test('验证六爻数据完整性', () {
      // Arrange
      final gua64 = Enum64Gua.shan_huo_bi; // 山火贲 (艮上离下)

      // Act
      final result = BaGuaJiaZeStrategy.calculateByNaJiaFromGua64(gua64);

      // Assert
      final gua = result.pureSixYaoGua;
      expect(gua, isNotNull);
      // PureSixYaoGua 应该有6个爻
      // 这里只能验证结果不为null,具体验证需要访问内部属性

      // ignore: avoid_print
      print('山火贲 - 纳甲法: ${result.summary}');
    });
  });
}
