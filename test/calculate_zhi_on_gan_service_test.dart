import 'package:common/datamodel/observer_datamodel.dart';
import 'package:common/enums.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:common/models/jie_qi_info.dart';
import 'package:daliuren/domain/services/calculate_zhi_on_gan_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculateZhiOnGanService Tests', () {
    late CalculateZhiOnGanService service;

    setUp(() {
      service = CalculateZhiOnGanService();
    });

    test('甲戌日第一局　干上寅', () {
      // 创建甲戌日的占卜时间模型
      // 这里我们需要构造一个包含甲戌日柱的DivinationDatetimeModel
      final datetimeModel = DivinationDatetimeModel(
        uuid: "test",
        yearJiaZi: JiaZi.JIA_ZI, // 示例年柱
        monthJiaZi: JiaZi.BING_YIN, // 示例月柱
        dayJiaZi: JiaZi.JIA_XU, // 甲戌日
        timeJiaZi: JiaZi.XIN_WEI, // 辛未时（未时）
        lunarMonth: 12,
        lunarDay: 1,
        isLeapMonth: false,
        jieQiInfo: JieQiInfo(
          jieQi: TwentyFourJieQi.DONG_ZHI,
          // isAfterJieQi: true,
          // jieQiDateTime: DateTime(2024, 1, 1),
          startAt: DateTime(2024, 1, 1),
          endAt: DateTime(2024, 1, 1),
        ),
        observer: ObserverDataModel(
            timezoneStr: "America/Los_Angeles",
            type: EnumDatetimeType.meanSolar),
        datetime: DateTime(2024, 1, 1),
        isSeersLocation: false,
        isDst: false,
      );

      // 第一局通常指的是某个特定的月将
      // 根据"干上寅"的期望结果，我们需要找到合适的月将
      // 甲寄寅宫，如果干上神是寅，说明寅宫上方的天盘地支是寅
      // 这意味着月将加在占时上后，寅宫对应的天盘地支是寅

      // 假设占时是子时，月将需要是寅将，这样：
      // 地盘：子丑寅卯辰巳午未申酉戌亥
      // 天盘：寅卯辰巳午未申酉戌亥子丑（寅将加子时）
      // 寅宫（地盘第3位）对应天盘第3位：辰

      // 让我们尝试不同的月将来找到正确的组合
      final monthGeneral = MonthGeneral.WEI_XIAO_JI; // 未将（小吉）

      // 执行计算
      final result = service.calculate(monthGeneral, datetimeModel);

      // 验证结果
      expect(result, DiZhi.YIN, reason: '甲戌日第一局应该干上寅');

      // 打印调试信息
      print('日干: ${datetimeModel.dayJiaZi.tianGan.value}');
      print('占时: ${datetimeModel.timeJiaZi.diZhi.value}');
      print('月将: ${monthGeneral.generalZhi.value}');
      print('干上神: ${result.value}');

      // 验证十干寄宫映射
      expect(
          CalculateZhiOnGanService.tianGanJiGongMapper[TianGan.JIA], DiZhi.YIN);
    });

    test('验证十干寄宫映射', () {
      // 验证口诀："甲课寅兮乙课辰，丙戊课巳不需论，丁己课未庚申上，辛戌壬亥是其真，癸课原来丑宫坐"
      expect(
          CalculateZhiOnGanService.tianGanJiGongMapper[TianGan.JIA], DiZhi.YIN);
      expect(
          CalculateZhiOnGanService.tianGanJiGongMapper[TianGan.YI], DiZhi.CHEN);
      expect(
          CalculateZhiOnGanService.tianGanJiGongMapper[TianGan.BING], DiZhi.SI);
      expect(CalculateZhiOnGanService.tianGanJiGongMapper[TianGan.DING],
          DiZhi.WEI);
      expect(
          CalculateZhiOnGanService.tianGanJiGongMapper[TianGan.WU], DiZhi.SI);
      expect(
          CalculateZhiOnGanService.tianGanJiGongMapper[TianGan.JI], DiZhi.WEI);
      expect(CalculateZhiOnGanService.tianGanJiGongMapper[TianGan.GENG],
          DiZhi.SHEN);
      expect(
          CalculateZhiOnGanService.tianGanJiGongMapper[TianGan.XIN], DiZhi.XU);
      expect(
          CalculateZhiOnGanService.tianGanJiGongMapper[TianGan.REN], DiZhi.HAI);
      expect(CalculateZhiOnGanService.tianGanJiGongMapper[TianGan.GUI],
          DiZhi.CHOU);
    });

    test('天地盘排列测试', () {
      // 测试月将加时的天地盘排列
      final service = CalculateZhiOnGanService();

      // 测试寅将加子时
      final tianDiPan =
          service.createTianDiPan(MonthGeneral.YIN_GONG_CAO, DiZhi.ZI);

      // 验证地盘子位对应天盘寅
      expect(tianDiPan[DiZhi.ZI], DiZhi.YIN);

      // 验证地盘寅位对应天盘辰
      expect(tianDiPan[DiZhi.YIN], DiZhi.CHEN);

      print('天地盘映射:');
      for (final entry in tianDiPan.entries) {
        print('地盘${entry.key.value} -> 天盘${entry.value.value}');
      }
    });
  });
}
