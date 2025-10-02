import 'package:common/enums.dart';
import 'package:daliuren/domain/services/calculators/lunar_calculator.dart';
import 'package:daliuren/domain/services/calculators/tian_di_pan_calculator.dart';
import 'package:daliuren/domain/services/calculators/gui_ren_calculator.dart';
import 'package:daliuren/domain/services/calculators/four_class_calculator.dart';
import 'package:daliuren/domain/services/calculators/three_chuan_calculator.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';

/// 大六壬计算服务
///
/// 编排各个Calculator,实现完整的大六壬占卜计算流程
///
/// 计算流程:
/// 1. 农历与八字计算 (LunarCalculator)
/// 2. 月将确定 (LunarCalculator)
/// 3. 天地盘生成 (TianDiPanCalculator)
/// 4. 贵人与神将定位 (GuiRenCalculator)
/// 5. 宫位映射生成 (TianDiPanCalculator)
/// 6. 四课计算 (FourClassCalculator)
/// 7. 三传推导 (ThreeChuanCalculator)
/// 8. 阴阳遁和局数计算 (LunarCalculator)
class DaLiuRenCalculationService {
  final LunarCalculator lunarCalculator;
  final TianDiPanCalculator tianDiPanCalculator;
  final GuiRenCalculator guiRenCalculator;
  final FourClassCalculator fourClassCalculator;
  final ThreeChuanCalculator threeChuanCalculator;

  DaLiuRenCalculationService({
    required this.lunarCalculator,
    required this.tianDiPanCalculator,
    required this.guiRenCalculator,
    required this.fourClassCalculator,
    required this.threeChuanCalculator,
  });

  /// 完整的占卜计算流程
  ///
  /// [dateTime] 起卦时间
  /// [question] 问题描述(可选)
  /// Returns: 完整的大六壬盘面数据
  ///
  /// Example:
  /// ```dart
  /// final kePan = service.calculate(
  ///   DateTime.now(),
  ///   question: "测试占卜"
  /// );
  /// ```
  DaLiuRenKePan calculate(DateTime dateTime, {String? question}) {
    try {
      // 步骤1: 计算农历与八字
      final baZiStr = lunarCalculator.calculateBaZi(dateTime);
      final baZiList = lunarCalculator.parseBaZiString(baZiStr);
      final yearJiaZi = baZiList[0];
      final monthJiaZi = baZiList[1];
      final dayJiaZi = baZiList[2];
      final timeJiaZi = baZiList[3];

      // 步骤2: 计算月将
      final monthGeneral = lunarCalculator.calculateMonthGeneral(dateTime);

      // 步骤3: 生成天地盘
      final tianDiPanMapper = tianDiPanCalculator.generateTianDiPanMapper(
        timeJiaZi.diZhi,
        monthGeneral,
      );

      // 步骤4: 计算贵人
      final guiRenResult = guiRenCalculator.calculateGuiRenLocation(
        dayJiaZi,
        timeJiaZi,
      );
      final isDayGuiRen = guiRenResult.item1;
      final guiRenDiZhi = guiRenResult.item2;

      // 步骤5: 生成神将映射
      final godsMapper = guiRenCalculator.calculateGodsMapper(
        timeJiaZi.diZhi,
        tianDiPanMapper,
        guiRenDiZhi,
      );

      // 步骤6: 生成宫位映射
      final gongMapper = tianDiPanCalculator.generateGongMapper(
        tianDiPanMapper,
        godsMapper,
        dayJiaZi,
      );

      // 步骤7: 计算四课
      final fourClass = fourClassCalculator.calculate(dayJiaZi, gongMapper);

      // 步骤8: 计算三传
      final threeChuan = threeChuanCalculator.calculate(
        dayJiaZi,
        fourClass,
        gongMapper,
      );

      // 步骤9: 计算阴阳遁
      final yinYangDun = lunarCalculator.determineYinYangDun(isDayGuiRen);

      // 步骤10: 组装完整的盘面数据
      // 注意: 这里直接使用DaLiuRenKePan的现有构造函数
      // 未来可能需要重构DaLiuRenKePan为纯数据模型,接收所有计算好的参数
      return DaLiuRenKePan(
        panDateTime: dateTime,
        question: question,
        eightChatStr: baZiStr,
        monthGeneral: monthGeneral,
      );
    } catch (e) {
      throw Exception('Failed to calculate Da Liu Ren: $e');
    }
  }
}
