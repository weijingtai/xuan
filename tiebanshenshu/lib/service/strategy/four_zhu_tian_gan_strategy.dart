/// 四柱天干取数法Strategy实现
///
/// 将四柱天干取数法算法封装为标准计算策略
library;

import '../../domain/four_zhu.dart';
import '../classic/four_zhu_tian_gan_calculatioin.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';

/// 四柱天干取数法计算参数
///
/// 包含执行四柱天干取数法所需的所有参数
class FourZhuTianGanStrategyParams extends BaseCalculationParams {
  /// 四柱信息
  final FourZhu fourZhu;

  const FourZhuTianGanStrategyParams({
    required this.fourZhu,
  });

  @override
  String get description => "四柱天干取数法计算参数：四柱信息(${fourZhu.yearGanzhi} ${fourZhu.monthGanzhi} ${fourZhu.dayGanzhi} ${fourZhu.timeGanzhi})";
}

/// 四柱天干取数法计算结果
///
/// 包含四柱天干取数法的计算结果，主要结果为条文编号
class FourZhuTianGanStrategyResult extends BaseCalculationResult {
  /// 主要结果：条文编号（列表中的第一个）
  final int tiaoWenNumber;
  
  /// 四柱信息
  final FourZhu fourZhu;
  
  /// 基础数字
  final int baseNumber;
  
  /// 完整条文编号列表（用于调试）
  final List<int> tiaoWenNumberList;
  
  /// 天干数字映射表
  final Map<String, int> ganNumberMapping;

  const FourZhuTianGanStrategyResult({
    required this.tiaoWenNumber,
    required this.fourZhu,
    required this.baseNumber,
    required this.tiaoWenNumberList,
    required this.ganNumberMapping,
  });

  @override
  String get summary => "四柱天干取数法结果：条文编号 $tiaoWenNumber（基础数：$baseNumber）";
}

/// 四柱天干取数法计算策略
///
/// 实现四柱天干取数法的标准计算策略
class FourZhuTianGanStrategy 
    extends StandardCalculationStrategy<FourZhuTianGanStrategyParams, FourZhuTianGanStrategyResult> {

  @override
  String get name => "四柱天干取数法";

  @override
  String get description => "排四柱只取天干进行配数，按月日时年顺序排列得到基本数，递加96生成条文列表";

  @override
  List<String> get detailSteps => [
    "1. 排四柱：获取年月日时的天干信息",
    "2. 天干配数：甲1、乙6、丙2、丁7、戊3、己8、庚4、辛9、壬5、癸0",
    "3. 排列组合：按照月、日、时、年的顺序排列天干配数，得到四位基本数",
    "4. 生成条文列表：以基本数为基础递加96七次，得到8个条文编号",
  ];

  @override
  String get school => "四柱天干流派";

  @override
  FourZhuTianGanStrategyResult calculate(FourZhuTianGanStrategyParams params) {
    // 复用原有算法逻辑
    final originalCalculation = FourZhuTianGanCalculation();
    final originalParams = FourZhuTianGanParams(fourZhu: params.fourZhu);
    
    final originalResult = originalCalculation.calculate(originalParams);
    
    // 提取第一个条文编号作为主要结果
    final tiaoWenNumber = originalResult.tiaoWenNumberList.isNotEmpty 
        ? originalResult.tiaoWenNumberList.first 
        : originalResult.baseNumber;
    
    // 封装为新的Result对象
    return FourZhuTianGanStrategyResult(
      tiaoWenNumber: tiaoWenNumber,
      fourZhu: originalResult.fourZhu,
      baseNumber: originalResult.baseNumber,
      tiaoWenNumberList: originalResult.tiaoWenNumberList,
      ganNumberMapping: originalResult.ganNumberMapping,
    );
  }
}