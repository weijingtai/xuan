import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/yuan_tang_strategy.dart';
import 'package:tiebanshenshu/domain/models/yuan_tang_base_number_model.dart';

/// 元堂卦取数法Debug测试
///
/// 打印完整的计算过程,便于人工验证算法正确性
void main() {
  group('YuanTangStrategy Debug - 完整计算过程展示', () {
    test('测试案例1: 甲戌 己巳 辛丑 丁酉 (男/上/夏至)', () {
      // 构造测试数据
      final fourZhu = EightChars(
        year: JiaZi.getFromGanZhiValue("甲戌")!,
        month: JiaZi.getFromGanZhiValue("己巳")!,
        day: JiaZi.getFromGanZhiValue("辛丑")!,
        time: JiaZi.getFromGanZhiValue("丁酉")!,
      );

      final params = YuanTangStrategyParams(
        eightChars: fourZhu,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
        birthMonth: 5,
      );

      // 执行计算
      final strategy = YuanTangStrategy();
      final result = strategy.calculate(params);

      // 验证计算成功
      expect(result.hasError, isFalse);

      final model = result.baseNumbers.first as YuanTangBaseNumberModel;

      // 打印完整计算过程
      _printCalculationDetails(model, params);
    });

    test('测试案例2: 甲戌 己巳 辛丑 丁酉 (女/上/夏至)', () {
      final fourZhu = EightChars(
        year: JiaZi.getFromGanZhiValue("甲戌")!,
        month: JiaZi.getFromGanZhiValue("己巳")!,
        day: JiaZi.getFromGanZhiValue("辛丑")!,
        time: JiaZi.getFromGanZhiValue("丁酉")!,
      );

      final params = YuanTangStrategyParams(
        eightChars: fourZhu,
        gender: Gender.female,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
        birthMonth: 5,
      );

      final strategy = YuanTangStrategy();
      final result = strategy.calculate(params);

      expect(result.hasError, isFalse);

      final model = result.baseNumbers.first as YuanTangBaseNumberModel;

      _printCalculationDetails(model, params);
    });

    test('测试案例3: 甲戌 己巳 辛丑 丁酉 (男/中/冬至)', () {
      final fourZhu = EightChars(
        year: JiaZi.getFromGanZhiValue("甲戌")!,
        month: JiaZi.getFromGanZhiValue("己巳")!,
        day: JiaZi.getFromGanZhiValue("辛丑")!,
        time: JiaZi.getFromGanZhiValue("丁酉")!,
      );

      final params = YuanTangStrategyParams(
        eightChars: fourZhu,
        gender: Gender.male,
        threeYuan: YuanYunOrder.middle,
        birthAfterZhi: TwentyFourJieQi.DONG_ZHI,
        birthMonth: 5,
      );

      final strategy = YuanTangStrategy();
      final result = strategy.calculate(params);

      expect(result.hasError, isFalse);

      final model = result.baseNumbers.first as YuanTangBaseNumberModel;

      _printCalculationDetails(model, params);
    });
  });
}

/// 打印完整的计算过程详情
void _printCalculationDetails(
  YuanTangBaseNumberModel model,
  YuanTangStrategyParams params,
) {
  print('\n${'=' * 70}');
  print('元堂卦取数法完整计算过程');
  print('=' * 70);

  // 输入参数
  print('\n【输入参数】');
  print(
    '四柱: ${params.eightChars.year.ganZhiStr} ${params.eightChars.month.ganZhiStr} '
    '${params.eightChars.day.ganZhiStr} ${params.eightChars.time.ganZhiStr}',
  );
  print('性别: ${params.gender}');
  print('三元: ${params.threeYuan}');
  print('出生节气后: ${params.birthAfterZhi}');

  // 步骤1: 生成天地卦
  print('\n【步骤1: 生成天地卦】');
  print('四柱天干数: ${model.ganNumList}');
  print('四柱地支数: ${model.zhiNumList}');

  // 展开地支数列表
  final flatZhiNum = model.zhiNumList.expand((x) => x).toList();
  print('展开地支数: $flatZhiNum');

  print(
    '奇数总和: ${model.oddNumTotal} (${_formatOddNumbers(model.ganNumList, flatZhiNum)})',
  );
  print(
    '偶数总和: ${model.evenNumTotal} (${_formatEvenNumbers(model.ganNumList, flatZhiNum)})',
  );

  print(
    '天数: ${model.oddNumTotal} % 25 ${model.oddNumTotal % 25 == 0 ? '(25)' : ''}= ${model.tianGuaNum}',
  );
  print(
    '地数: ${model.evenNumTotal} % 30 ${model.evenNumTotal % 30 == 0 ? '(30)' : ''}= ${model.diGuaNum}',
  );

  print(
    '天卦: ${model.tianGua} (天数${model.tianGuaNum}配卦${model.usedThreeYuanWuGong ? ',使用三元五宫' : ''})',
  );
  print('地卦: ${model.diGua} (地数${model.diGuaNum}配卦)');

  // 步骤2: 生成上下卦(先天卦)
  print('\n【步骤2: 生成上下卦(先天卦)】');
  print('年份阴阳: ${model.yearYinYang}');
  print('性别: ${params.gender}');
  print(
    '配卦规则: ${_getUpperLowerGuaRule(model.yearYinYang.name, params.gender.name)}',
  );
  print('上卦: ${model.upperGua} (后天数: ${model.xiantianUpperGuaNumber})');
  print('下卦: ${model.lowerGua} (后天数: ${model.xiantianLowerGuaNumber})');
  print('先天卦: ${model.xiantianGua}');

  // 步骤3: 元堂装卦
  print('\n【步骤3: 元堂装卦】');
  print('时柱干支: ${model.timeGanzhi}');
  print('时辰阴阳: ${model.timeYinYang}');
  print('卦中阳爻数: ${model.totalYangYao}');
  print('卦中阴爻数: ${model.totalYinYao}');
  print(
    '装卦方法: ${_getZhuangguaMethod(model.timeYinYang, model.totalYangYao, model.totalYinYao)}',
  );

  print('\n六爻地支配置(从下到上):');
  for (int i = 0; i < model.zhiList.length; i++) {
    final yaoDetail = model.yaoDetails[i];
    final zhiStr = model.zhiList[i].isEmpty
        ? '---'
        : model.zhiList[i].join(',');
    final marker = yaoDetail.isYuanTangYao ? ' ← 元堂爻' : '';
    print(
      '  ${yaoDetail.positionLabel}爻(${yaoDetail.yinYang}): $zhiStr$marker',
    );
  }

  print('\n元堂爻: ${model.yuantangYaoLabel}爻 (索引${model.yuantangYaoIndex})');

  // 步骤4: 生成后天卦
  print('\n【步骤4: 生成后天卦】');
  // print(
  //   '元堂爻爻变: ${model.yuantangYaoLabel}爻 ${_getYaoYinYang(model.xiantianGua, model.yuantangYaoIndex)} → ${_getYaoYinYangAfterChange(model.xiantianGua, model.yuantangYaoIndex)}',
  // );
  print('上下卦互换: ${model.xiantianGua.top} ↔ ${model.xiantianGua.bottom}');
  print('后天卦: ${model.houtianGua}');
  print('后天卦上卦: ${model.houtianGua.top} (后天数: ${model.houtianUpperGuaNumber})');
  print(
    '后天卦下卦: ${model.houtianGua.bottom} (后天数: ${model.houtianLowerGuaNumber})',
  );

  // 步骤5: 互卦
  print('\n【步骤5: 互卦计算】');
  print('先天卦互卦: ${model.xiantianGua} → ${model.xiantianGuaHu}');
  print('后天卦互卦: ${model.houtianGua} → ${model.houtianGuaHu}');

  // 步骤6: 条文编号
  print('\n【步骤6: 条文编号计算(8种方法)】');

  print('\n1. 先天卦加则法:');
  print('   条文编号: ${model.tiaowenNumberJiazeXiantiangua}');

  print('\n2. 后天卦加则法:');
  print('   条文编号: ${model.tiaowenNumberJiazeHoutiangua}');

  print('\n3. 先天卦纳甲太玄数:');
  print('   条文编号: ${model.tiaowenNumberNajiaTaixuanXiantiangua}');

  print('\n4. 后天卦纳甲太玄数:');
  print('   条文编号: ${model.tiaowenNumberNajiaTaixuanHoutiangua}');

  print('\n5. 先天卦本互:');
  print('   本卦: ${model.xiantianGua}, 互卦: ${model.xiantianGuaHu}');
  print('   条文编号: ${model.tiaowenNumberXiantianBenhu}');

  print('\n6. 后天卦本互:');
  print('   本卦: ${model.houtianGua}, 互卦: ${model.houtianGuaHu}');
  print('   条文编号: ${model.tiaowenNumberHoutianBenhu}');

  print('\n7. 先天卦互取数列表(8个数):');
  print('   基数: ${model.tiaowenNumberXiantianBenhu}');
  print('   列表: ${model.tiaowenNumberListXiantianGuahu}');

  print('\n8. 后天卦互取数列表(8个数):');
  print('   基数: ${model.tiaowenNumberHoutianBenhu}');
  print('   列表: ${model.tiaowenNumberListHoutianGuahu}');

  // 汇总
  print('\n【结果汇总】');
  final allNumbers = <int>{
    model.tiaowenNumberJiazeXiantiangua,
    model.tiaowenNumberJiazeHoutiangua,
    model.tiaowenNumberNajiaTaixuanXiantiangua,
    model.tiaowenNumberNajiaTaixuanHoutiangua,
    model.tiaowenNumberXiantianBenhu,
    model.tiaowenNumberHoutianBenhu,
    ...model.tiaowenNumberListXiantianGuahu,
    ...model.tiaowenNumberListHoutianGuahu,
  }.toList()..sort();

  print('条文编号方法总数: 8种');
  print('生成条文编号总数: ${allNumbers.length}个(去重后)');
  print('所有条文编号: $allNumbers');
  print('基础数: ${model.baseNumber}');

  print('\n${'=' * 70}\n');
}

/// 格式化奇数列表
String _formatOddNumbers(List<int> ganList, List<int> zhiList) {
  final odds = [...ganList, ...zhiList].where((n) => n % 2 == 1).toList();
  return odds.join(' + ');
}

/// 格式化偶数列表
String _formatEvenNumbers(List<int> ganList, List<int> zhiList) {
  final evens = [...ganList, ...zhiList].where((n) => n % 2 == 0).toList();
  return evens.join(' + ');
}

/// 获取上下卦配置规则说明
String _getUpperLowerGuaRule(String yearYinYang, String gender) {
  if (yearYinYang == "阳") {
    if (gender == "男") {
      return "阳年男性 → 天卦在上,地卦在下";
    } else {
      return "阳年女性 → 地卦在上,天卦在下";
    }
  } else {
    if (gender == "女") {
      return "阴年女性 → 天卦在上,地卦在下";
    } else {
      return "阴年男性 → 地卦在上,天卦在下";
    }
  }
}

/// 获取装卦方法说明
String _getZhuangguaMethod(String timeYinYang, int yangYao, int yinYao) {
  final targetYao = timeYinYang == "阳" ? yangYao : yinYao;
  final yaoType = timeYinYang == "阳" ? "阳爻" : "阴爻";

  if (targetYao >= 1 && targetYao <= 3) {
    return "$timeYinYang时取$yaoType($targetYao个) → 双重装配法";
  } else if (targetYao >= 4 && targetYao <= 5) {
    return "$timeYinYang时取$yaoType($targetYao个) → 自上而下排列法";
  } else if (targetYao == 6) {
    return "$timeYinYang时取$yaoType(6个,全爻) → 三爻分组法";
  } else {
    return "$timeYinYang时取$yaoType(0个,全反爻) → 三爻分组法";
  }
}

/// 获取爻的阴阳属性
String _getYaoYinYang(String gua, int yaoIndex) {
  // 转换为二进制表示
  const guaBinaryMapper = {
    '乾': [1, 1, 1],
    '兑': [0, 1, 1],
    '离': [1, 0, 1],
    '震': [0, 0, 1],
    '巽': [1, 1, 0],
    '坎': [0, 1, 0],
    '艮': [1, 0, 0],
    '坤': [0, 0, 0],
  };

  final upperBinary = guaBinaryMapper[gua[0]]!;
  final lowerBinary = guaBinaryMapper[gua[1]]!;
  final allBinary = [...upperBinary, ...lowerBinary];

  return allBinary[yaoIndex] == 1 ? '阳' : '阴';
}

/// 获取爻变后的阴阳属性
String _getYaoYinYangAfterChange(String gua, int yaoIndex) {
  final current = _getYaoYinYang(gua, yaoIndex);
  return current == '阳' ? '阴' : '阳';
}
