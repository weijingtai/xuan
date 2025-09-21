/// 太玄取数法（1）Strategy实现
///
/// 将太玄取数法（1）算法封装为标准计算策略
library;

import '../../domain/four_zhu.dart';
import '../classic/tai_xuan_four_zhu_calculation.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';

/// 太玄取数法（1）计算参数
///
/// 包含执行太玄取数法（1）所需的所有参数
class TaiXuanFourZhuStrategyParams extends BaseCalculationParams {
  /// 四柱信息
  final FourZhu fourZhu;

  const TaiXuanFourZhuStrategyParams({
    required this.fourZhu,
  });

  @override
  String get description => "太玄取数法（1）计算参数：四柱信息(${fourZhu.yearGanzhi} ${fourZhu.monthGanzhi} ${fourZhu.dayGanzhi} ${fourZhu.timeGanzhi})";
}

/// 太玄取数法（1）计算结果
///
/// 包含太玄取数法（1）的计算结果，主要结果为条文编号
class TaiXuanFourZhuStrategyResult extends BaseCalculationResult {
  /// 主要结果：条文编号（列表中的第一个）
  final int tiaoWenNumber;
  
  /// 四柱信息
  final FourZhu fourZhu;
  
  /// 是否阳年
  final bool isYangYear;
  
  /// 四柱基本数列表
  final List<int> fourZhuBaseNumberList;
  
  /// 所有条文编号列表
  final List<int> allTiaoWenNumberList;

  const TaiXuanFourZhuStrategyResult({
    required this.tiaoWenNumber,
    required this.fourZhu,
    required this.isYangYear,
    required this.fourZhuBaseNumberList,
    required this.allTiaoWenNumberList,
  });

  @override
  String get summary => "太玄取数法（1）结果：条文编号 $tiaoWenNumber（阳年：$isYangYear，基本数列表：$fourZhuBaseNumberList）";
}

/// 太玄取数法（1）计算策略
///
/// 实现太玄取数法（1）的标准计算策略
class TaiXuanFourZhuStrategy 
    extends StandardCalculationStrategy<TaiXuanFourZhuStrategyParams, TaiXuanFourZhuStrategyResult> {

  @override
  String get name => "太玄取数法（1）";

  @override
  String get description => "排四柱天干地支分别配卦，纳甲配太玄数，上下卦数相配组成四位数，各加减96生成条文列表";

  @override
  List<String> get detailSteps => [
    "1. 排四柱：获取年月日时的干支信息",
    "2. 天干地支配卦：天干配卦法（壬甲从乾数，乙癸向坤求，庚来震上里，辛在巽方留，己从离门起，戊以坎为头，丙须艮处出，丁向兑家收）；地支配卦法（亥子坎宫寅木震，巳午离门丑在坤，卯酉乾金辰是兑，未申艮宫戌巽真）",
    "3. 组卦：同一柱的天干为上卦，地支为下卦，组成一个完整的卦",
    "4. 纳甲配干支：将卦配上纳甲干支，阳年乾卦天干配壬、阴年天干配甲；阳年坤配癸，阴年坤配乙",
    "5. 太玄数计算：每卦每爻的干支取太玄数相加（和数为10则不用），上卦数相加为一组，下卦数相加为一组",
    "6. 四位数组成：四卦各上下两数相配（上卦两位为千、百位，下卦两位为十、个位）",
    "7. 生成条文列表：四组数分别各±96四次，得到所有条文编号",
  ];

  @override
  String get school => "太玄取数流派";

  @override
  TaiXuanFourZhuStrategyResult calculate(TaiXuanFourZhuStrategyParams params) {
    // 复用原有算法逻辑
    final originalCalculation = TaiXuanFourZhuCalculation();
    final originalParams = TaiXuanFourZhuParams(fourZhu: params.fourZhu);
    
    final originalResult = originalCalculation.calculate(originalParams);
    
    // 提取第一个条文编号作为主要结果
    final tiaoWenNumber = originalResult.allTiaoWenNumberList.isNotEmpty 
        ? originalResult.allTiaoWenNumberList.first 
        : (originalResult.fourZhuBaseNumberList.isNotEmpty 
            ? originalResult.fourZhuBaseNumberList.first 
            : 0);
    
    // 封装为新的Result对象
    return TaiXuanFourZhuStrategyResult(
      tiaoWenNumber: tiaoWenNumber,
      fourZhu: originalResult.fourZhu,
      isYangYear: originalResult.isYangYear,
      fourZhuBaseNumberList: originalResult.fourZhuBaseNumberList,
      allTiaoWenNumberList: originalResult.allTiaoWenNumberList,
    );
  }
}