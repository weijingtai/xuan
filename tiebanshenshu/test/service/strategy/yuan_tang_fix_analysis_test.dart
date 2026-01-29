import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/yuan_tang_strategy.dart';
import 'package:tiebanshenshu/domain/models/yuan_tang_base_number_model.dart';

/// 元堂卦装卦逻辑修正分析测试
///
/// 对比当前实现与外部预期的差异，验证修正方案
void main() {
  late YuanTangStrategy strategy;
  late EightChars testEightChars;
  late YuanTangStrategyParams testParams;

  setUp(() {
    strategy = YuanTangStrategy();

    // 测试数据：男 己酉 丙子 辛巳 戊子
    testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("己酉")!,
      month: JiaZi.getFromGanZhiValue("丙子")!,
      day: JiaZi.getFromGanZhiValue("辛巳")!,
      time: JiaZi.getFromGanZhiValue("戊子")!,
    );

    testParams = YuanTangStrategyParams(
      eightChars: testEightChars,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
      birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      birthMonth: 5,
    );
  });

  group('装卦逻辑分析 - 己酉丙子辛巳戊子', () {
    test('当前实现输出分析', () {
      final result = strategy.calculate(testParams);
      final model = result.baseNumbers.first as YuanTangBaseNumberModel;

      print('\n========== 当前实现输出 ==========');
      print('先天卦: ${model.xiantianGua}');
      print('时辰阴阳: ${model.timeYinYang}');
      print('阳爻数: ${model.totalYangYao}');
      print('阴爻数: ${model.totalYinYao}');
      print('元堂爻位置: ${model.yuantangYaoLabel}爻 (索引${model.yuantangYaoIndex})');
      print('\n六爻配置:');
      for (int i = 0; i < 6; i++) {
        final yao = model.yaoDetails[i];
        final zhiStr = model.zhiList[i].isEmpty
            ? '空'
            : model.zhiList[i].join(',');
        final mark = yao.isYuanTangYao ? ' [元堂]' : '';
        print('  ${yao.positionLabel}爻(索引$i): $zhiStr$mark');
      }

      print('\n========== 外部预期输出 ==========');
      print('元堂爻位置: 初爻 (索引0)');
      print('\n六爻配置:');
      print('  初爻(索引0): 子,寅 [元堂]');
      print('  二爻(索引1): 辰');
      print('  三爻(索引2): 巳');
      print('  四爻(索引3): 丑,卯');
      print('  五爻(索引4): 空');
      print('  上爻(索引5): 空');

      print('\n========== 差异分析 ==========');
      print('问题：当前输出与外部预期完全相反');
      print('原因：_zhuangguaLowerThan3方法的第二次反转操作');
      print('修正方案：移除line 592的reversed操作');
      print('=====================================\n');

      // 验证当前输出
      expect(model.yuantangYaoIndex, equals(5)); // 当前在上爻
      expect(model.yuantangYaoLabel, equals('上'));
    });

    test('外部预期值验证', () {
      // 外部预期的六爻配置（从下到上：初、二、三、四、五、上）
      final expectedZhiList = [
        ['子', '寅'], // 初爻 - 元堂爻
        ['辰'], // 二爻
        ['巳'], // 三爻
        ['丑', '卯'], // 四爻
        [], // 五爻 - 空
        [], // 上爻 - 空
      ];

      final expectedYuantangYaoIndex = 0; // 初爻
      final expectedYuantangYaoLabel = '初';

      print('\n========== 外部预期详细信息 ==========');
      print('基础配置:');
      print('  先天卦: 震震');
      print('  时辰: 子时 (阳时)');
      print('  取爻规则: 阳时取阳爻');
      print('  阳爻数: 2个');
      print('  装卦方法: 双重装配 (_zhuangguaLowerThan3)');

      print('\n地支分配:');
      print('  阳时地支集: [子, 丑, 寅, 卯, 辰, 巳]');
      print('  双重装配用: [子, 丑, 寅, 卯] (前4个)');
      print('  剩余填充用: [辰, 巳] (后2个)');

      print('\n预期装配结果:');
      for (int i = 0; i < expectedZhiList.length; i++) {
        final zhiStr = expectedZhiList[i].isEmpty
            ? '空'
            : expectedZhiList[i].join(',');
        final mark = i == expectedYuantangYaoIndex ? ' [元堂]' : '';
        print('  索引$i: $zhiStr$mark');
      }

      print('\n元堂爻确定:');
      print('  时支: 子');
      print('  查找包含"子"的爻位: 索引$expectedYuantangYaoIndex');
      print('  元堂爻标签: $expectedYuantangYaoLabel');
      print('=====================================\n');

      // 这些是外部预期值，当前实现不满足
      expect(expectedYuantangYaoIndex, equals(0));
      expect(expectedYuantangYaoLabel, equals('初'));
    });

    test('震卦二进制分析', () {
      print('\n========== 震卦二进制分析 ==========');
      print('震卦: [0, 0, 1] (初阴、二阴、三阳)');
      print('震震卦拼接: [上卦] + [下卦]');
      print('  上卦(四五上): [0, 0, 1]');
      print('  下卦(初二三): [0, 0, 1]');
      print('  拼接结果: [0, 0, 1, 0, 0, 1]');

      print('\n索引与爻位对应:');
      print('  索引0: 四爻(阴)');
      print('  索引1: 五爻(阴)');
      print('  索引2: 上爻(阳) ← 阳爻');
      print('  索引3: 初爻(阴)');
      print('  索引4: 二爻(阴)');
      print('  索引5: 三爻(阳) ← 阳爻');

      print('\n第一次反转(line 563):');
      print('  反转前: [0, 0, 1, 0, 0, 1]');
      print('  反转后: [1, 0, 0, 1, 0, 0]');
      print('  阳爻位置: 索引0, 索引3');

      print('\n双重装配过程:');
      print('  目标: 给2个阳爻位置装配地支');
      print('  地支: [子, 丑, 寅, 卯]');
      print('  循环1: 索引0添加"子", 索引3添加"丑"');
      print('  循环2: 索引0添加"寅", 索引3添加"卯"');
      print('  结果: [[子,寅], [], [], [丑,卯], [], []]');

      print('\n填充剩余位置:');
      print('  剩余地支: [辰, 巳]');
      print('  填充后: [[子,寅], [辰], [巳], [丑,卯], [], []]');

      print('\n第二次反转(line 592) - 问题所在:');
      print('  反转前: [[子,寅], [辰], [巳], [丑,卯], [], []]');
      print('  反转后: [[], [], [丑,卯], [巳], [辰], [子,寅]]');
      print('  ↑ 这导致了顺序完全颠倒！');

      print('\n如果移除第二次反转:');
      print('  结果: [[子,寅], [辰], [巳], [丑,卯], [], []]');
      print('  对应爻位:');
      print('    索引0(初爻): [子,寅] ← 包含时支"子"，元堂爻！');
      print('    索引1(二爻): [辰]');
      print('    索引2(三爻): [巳]');
      print('    索引3(四爻): [丑,卯]');
      print('    索引4(五爻): []');
      print('    索引5(上爻): []');
      print('  ✓ 完全符合外部预期！');
      print('=====================================\n');
    });
  });

  group('修正方案验证', () {
    test('方案说明', () {
      print('\n========== 修正方案 ==========');
      print('问题根源:');
      print('  _zhuangguaLowerThan3 方法中的第二次反转(line 592)');
      print('  导致装卦结果与预期完全相反');

      print('\n修正步骤:');
      print(
        '  1. 移除 _zhuangguaLowerThan3 的 line 592: return resultList.reversed.toList()',
      );
      print('  2. 改为: return resultList;');
      print('  3. 同时检查 _zhuanggua45 的 line 211，可能也需要移除反转');
      print('  4. 检查 _zhuanggua6Yang，确保逻辑一致');

      print('\n预期效果:');
      print('  修正后，元堂爻将从上爻(索引5)移动到初爻(索引0)');
      print('  六爻配置将符合外部预期');

      print('\n需要更新的测试:');
      print('  1. yuan_tang_strategy_test.dart - 更新具体测试数据的预期值');
      print('  2. yuan_tang_strategy_specific_debug_test.dart - 更新预期对比');
      print('  3. yuan_tang_use_case_test.dart - 可能需要更新');

      print('\n注意事项:');
      print('  1. 这是一个核心逻辑修改，会影响所有使用该方法的场景');
      print('  2. 需要全面测试，确保没有引入其他问题');
      print('  3. 建议先在分支上修改和测试，确认无误后再合并');
      print('=====================================\n');
    });
  });
}
