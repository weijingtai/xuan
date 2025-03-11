// import 'dart:math';

// import 'package:common/enums.dart';
// import 'package:json_annotation/json_annotation.dart';
// import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';



// /// 坐标系原点定义（黄道/赤道系统的基准点）
// enum OriginPoint {
//   /// 黄道回归制-今宿制
//   /// - 坐标系：黄道（基于太阳视运动）
//   /// - 起点定义：以春分点（白羊0度）为基准，回归制起点对应黄经0度
//   /// - 宿度处理：采用现代天文学实测的28宿黄经位置
//   springEquinox(
//     '春分点', 
//     '黄经0度，现代天文标准原点（J2000黄道与赤道交点）',
//     celestialLongitude: 0.0,
//     referenceEpoch: EpochCorrection.j2000,
//   ),
  
//   /// 黄道回归制-古宿制
//   /// - 坐标系：黄道
//   /// - 起点定义：同“黄道回归制-今宿制”，但宿度采用元代《授时历》固定古宿数据，与当前实际星宿位置存在约14度岁差
//   winterSolstice(
//     '春分点',
//     '黄经0度，现代天文标准原点（J2000黄道与赤道交点）',
//     celestialLongitude: 0.0,
//     referenceEpoch: EpochCorrection.tangDynasty,
//   ),
//     /// 黄道回归校正古宿制
//   /// - 坐标系：黄道
//   /// - 起点定义：回归制基础上叠加岁差校正，使古宿刻度与当前天象对齐
//   eclipticReturnAdjusted(
//     '黄道回归校正古宿制',
//     '回归制基础上叠加岁差校正，使古宿刻度与当前天象对齐',
//     celestialLongitude: 14.0, // 约14度岁差校正值
//     referenceEpoch: EpochCorrection.j2000,
//   ),
  
//   /// 黄道恒星制（郑氏星案制）
//   /// - 坐标系：黄道
//   /// - 起点定义：以虚宿六度（女宿二度）为子宫起点，星曜位置通过岁差校正
//   /// - 宿度处理：古宿固定，宿与地支对应不变（如子必含虚宿）
//   virtualSixAlignment(
//     '虚六对齐',
//     '虚宿六度对齐子宫15度的传统规则（郑氏星案）',
//     celestialLongitude: _calculateVirtualSixLon(),
//     referenceEpoch: EpochCorrection.yuanDynasty,
//   ),
  
//   /// 特殊占星流派参考点
//   /// - 坐标系：黄道
//   /// - 起点定义：以银河系中心为基准点
//   galacticCenter(
//     '银心对齐',
//     '以银河系中心(Sgr A*)为基准，用于特殊占星流派',
//     celestialLongitude: 266.837,
//     referenceEpoch: EpochCorrection.j2000,
//   ),
  

  
//   /// 赤道回归制
//   /// - 坐标系：赤道（基于地球自转轴）
//   /// - 起点定义：春分点赤经0度，与古代天文记录一致
//   /// - 宿度处理：可选用今宿（实测赤经）或古宿（汉代星距）
//   equatorialReturn(
//     '赤道回归制',
//     '以赤道坐标系为基础，春分点赤经0度为起点',
//     celestialLongitude: 0.0,
//     referenceEpoch: EpochCorrection.j2000,
//   ),
  
//   /// 赤道恒星制
//   /// - 坐标系：赤道
//   /// - 起点定义：以28宿实际赤经位置为基准，宿度固定不受岁差影响
//   /// - 特点：12宫按固定辰次划分（如玄枵对应子），与节气无关
//   equatorialFixedStar(
//     '赤道恒星制',
//     '以28宿实际赤经位置为基准，宿度固定不受岁差影响',
//     celestialLongitude: 0.0, // 实际使用时需根据特定星宿位置计算
//     referenceEpoch: EpochCorrection.yuanDynasty,
//   );

//   final String name;
//   final String description;
//   final double celestialLongitude; // 黄经度数（J2000框架）
//   final EpochCorrection referenceEpoch;

//   /// 动态计算虚宿六度的黄经（需考虑岁差）
//   static double _calculateVirtualSixLon() {
//     // 示例：元朝1280年虚宿位置 + 岁差累积偏移
//     const baseLonYuan = 298.5; // 元朝虚宿基准黄经
//     final yearsDiff = DateTime.now().year - 1280;
//     return baseLonYuan + (yearsDiff * 50.29 / 3600); // 简化岁差计算
//   }

//   const OriginPoint(
//     this.name,
//     this.description, {
//     required this.celestialLongitude,
//     required this.referenceEpoch,
//   });
// }
// /// 赤道到黄道的投影算法
// enum ProjectionAlgorithm {
//   bianchini(
//     'Bianchini投影',
//     '明代《天元历理》使用的正弦投影法，公式: sinβ = sinδ cosε - cosδ sinε sinα',
//     formula: r'''
//       β = arcsin(sinδ * cosε - cosδ * sinε * sinα)
//       λ = arctan2(sinα cosε + tanδ sinε, cosα)
//     ''',
//   ),
//   stereographic(
//     '球面投影',
//     '保持角度不变形的保角投影，公式复杂需迭代计算',
//     formula: '复数域变换，详见AAS期刊1998年投影算法',
//   ),
//   rectangular(
//     '直角投影', 
//     '现代天文学常用简化算法，直接应用赤道倾角ε',
//     formula: r'''
//       λ = α + arctan(tanδ * sinε)
//       β = arcsin(sinδ * cosε - cosδ * sinε * sinα)
//     ''',
//   ),
//   none(
//     '无投影',
//     '直接使用原坐标系数据（适用于纯赤道/黄道系统）',
//   );

//   final String name;
//   final String description;
//   final String? formula; // 数学公式的LaTeX/文本表示

//   /// 获取算法实现（示例伪代码）
//   double Function(double a, double b) get transform {
//     switch (this) {
//       case ProjectionAlgorithm.bianchini:
//         return (a, b) => _bianchiniProjection(a, b);
//       case ProjectionAlgorithm.rectangular:
//         return (a, b) => _rectangularProjection(a, b);
//       default:
//         throw UnsupportedError('$name 算法未实现');
//     }
//   }

//   // Bianchini 投影核心计算
//   static double _bianchiniProjection(double α, double δ) {
//     const e = 23.4397; // 黄赤交角（J2000）
//     final sinδ = sin(radians(b));
//     final cosδ = cos(radians(b));
//     final sinα = sin(radians(a));
//     return degrees(asin(sinδ * cos(radians(e)) - cosδ * sin(radians(e)) * sinα));
//   }

//   // 直角投影简化计算
//   static double _rectangularProjection(double a, double b) {
//     const e = 23.4397;
//     return degrees(atan(tan(radians(b)) * cos(radians(e))));
//   }

//   const ProjectionAlgorithm(
//     this.name,
//     this.description, {
//     this.formula,
//   });
// }
// // 核心坐标系与历法参数
// enum CoordinateSystemType {
//   /// 黄道坐标系（基于地球公转轨道）
//   ecliptic(
//     name: '黄道制',
//     referencePlane: '黄道面',
//     originPoint: OriginPoint.springEquinox,
//     projectAlgorithm: ProjectionAlgorithm.bianchini,
//   ),
  
//   /// 赤道坐标系（基于地球自转轴）
//   equatorial(
//     name: '赤道制',
//     referencePlane: '赤道面',
//     originPoint: OriginPoint.vernalPoint,
//     projectAlgorithm: ProjectionAlgorithm.none,
//   );

//   final String name;
//   final String referencePlane;
//   final OriginPoint originPoint;
//   final ProjectionAlgorithm projectAlgorithm;

//   const CoordinateSystemType({
//     required this.name,
//     required this.referencePlane,
//     required this.originPoint,
//     required this.projectAlgorithm,
//   });
// }

// /// 宿度起点校准策略（解决虚六度对齐问题）
// mixin SiderealOriginMixin {
//   /// 虚宿六度对齐地支宫位的配置
//   static const Map<DiZhi, double> virtualSixAlignment = {
//     DiZhi.ZI: 15.0, // 子宫15度对齐虚宿6度
//     DiZhi.CHOU: 27.3,
//     // ...其他地支宫校准点
//   };

//   double getAlignmentOffset(DiZhi zhi) => virtualSixAlignment[zhi] ?? 0.0;
// }

// /// 岁差校正策略（含历元参数）
// class PrecessionCorrection {
//   final double baseYear; // 历元年份（如J2000=2000.0）
//   final double annualRate; // 岁差年速率（默认50.29角秒/年）
//   final CorrectionAlgorithm algorithm;

//   const PrecessionCorrection({
//     this.baseYear = 2000.0,
//     this.annualRate = 50.29,
//     this.algorithm = CorrectionAlgorithm.laskar,
//   });

//   double calculateOffset(double targetYear) => 
//       (targetYear - baseYear) * annualRate / 3600; // 转换为度数
// }

// /// 星盘制式全参数配置
// class StarPanelConfig {
//   final CoordinateSystemType coordinateSystem;
//   final StarInnSystemType siderealSystem;
//   final PrecessionCorrection? precession;
//   final EpochCorrection epoch;
//   final List<TwentyEightStarInn> starSequence;

//   /// 关键天文参数验证
//   void validate() {
//     if (coordinateSystem == CoordinateSystemType.equatorial && 
//         siderealSystem.requiresEclipticProjection) {
//       throw StateError('赤道制需指定投影算法');
//     }
//   }
// }

// // 岁差校正模型（核心算法封装）
// class PrecessionCorrection {
//   final double baseYear; // 基准年份（例：J2000=2000.0）
//   final double annualRate; // 岁差年速率（单位：角秒/年）
//   final PrecessionAlgorithm algorithm; // 计算算法

//   static const iau2006Rate = 50.290966; // IAU 2006标准岁差率
//   static const traditionalChineseRate = 50.0; // 中国传统历法近似值

//   const PrecessionCorrection({
//     this.baseYear = 2000.0,
//     this.annualRate = iau2006Rate,
//     this.algorithm = PrecessionAlgorithm.iau2006,
//   });

//   /// 计算目标年份的岁差累积偏移（单位：度）
//   double calculateOffset(double targetYear) {
//     final yearDiff = targetYear - baseYear;
//     switch (algorithm) {
//       case PrecessionAlgorithm.iau2006:
//         return (yearDiff * annualRate) / 3600; // 角秒转度数
//       case PrecessionAlgorithm.laskar1986:
//         return _laskarModel(yearDiff);
//       case PrecessionAlgorithm.none:
//         return 0.0;
//     }
//   }

//   /// Laskar 1986 长周期岁差模型（适用于公元前4000至公元8000年）
//   double _laskarModel(double yearDiff) {
//     final t = yearDiff / 1000;
//     return (5029.0966 * t + 1.11113 * t * t - 0.000000006 * t * t * t) / 3600;
//   }
// }

// // 岁差计算算法类型
// enum PrecessionAlgorithm {
//   iau2006('IAU 2006标准模型', '基于国际天文联合会2006年决议'),
//   laskar1986('Laskar 1986长周期模型', '覆盖-4000至+8000年的高精度模型'),
//   none('不修正岁差', '保持基准历元位置');

//   final String name;
//   final String description;
//   const PrecisionAlgorithm(this.name, this.description);
// }

// // 历元校正系统（时空基准框架）
// enum EpochCorrection {
//   tangDynasty(
//     720.0, 
//     '唐代历元', 
//     '《大衍历》基准，开元十二年（公元724年）春分点'
//   ),
//   yuanDynasty(
//     1280.0,
//     '元朝历元',
//     '《授时历》基准，至元十七年（公元1280年）冬至点',
//   ),
//   j2000(
//     2000.0,
//     'J2000标准历元',
//     '国际天文联合会标准历元（2000年1月1日12:00 TDB）'
//   ),
//   current(
//     -1, // 动态获取当前年
//     '实时历元',
//     '基于系统当前时间的动态修正'
//   );

//   final double baseYear;
//   final String eraName;
//   final String historicalRef;

//   /// 获取实际基准年份（处理动态历元）
//   double get effectiveYear => 
//       baseYear >= 0 ? baseYear : DateTime.now().year.toDouble();

//   const EpochCorrection(
//     this.baseYear,
//     this.eraName, 
//     this.historicalRef
//   );
// }



// enum StarInnSystemType {
//   classical(
//     '古宿制',
//     EpochCorrection.tangDynasty,
//     PrecessionAlgorithm.none,
//     starAlignment: StarAlignment.virtualSix,
//   ),
//   classicalCorrected(
//     '古宿矫正制',
//     EpochCorrection.j2000,
//     PrecessionAlgorithm.iau2006,
//     starAlignment: StarAlignment.virtualSix,
//   ),
//   modernDynamic(
//     '今宿动态制', 
//     EpochCorrection.current,
//     PrecessionAlgorithm.iau2006,
//     starAlignment: StarAlignment.equinoxBased,
//   );

//   final String name;
//   final EpochCorrection epoch;
//   final PrecessionAlgorithm precession;
//   final StarAlignment starAlignment;

//   /// 是否启用宿度动态计算
//   bool get isDynamic => precession != PrecessionAlgorithm.none;

//   const StarInnSystemType(
//     this.name,
//     this.epoch,
//     this.precession, {
//     required this.starAlignment,
//   });
// }

// // 恒星对齐规则（解决虚宿六度对齐问题）
// enum StarAlignment {
//   virtualSix('虚六定宫', '以虚宿六度对齐子宫15度的传统规则'),
//   equinoxBased('春分对齐', '以春分点为基准的现代天文对齐'),
//   polarAlignment('极轴对齐', '基于天球北极的赤经划分');

//   final String name;
//   final String description;
//   const StarAlignment(this.name, this.description);
// }
// // 二十八宿模型增强
// class TwentyEightStarInn {
//   final String starName;
//   final EnumStars sevenZheng;
//   final String animal;
//   final AstronomicalPosition basePosition; // 历元基准位置
//   final GeoRegion region; // 地理分野

//   const TwentyEightStarInn({
//     required this.starName,
//     required this.sevenZheng,
//     required this.animal,
//     required this.basePosition,
//     required this.region,
//   });

//   /// 获取实际位置（考虑岁差）
//   AstronomicalPosition getActualPosition(DateTime date) {
//     final yearsDiff = date.year + date.dayOfYear / 365.25 - basePosition.epoch;
//     return basePosition.applyPrecession(yearsDiff * precessionRate);
//   }
// }

// // 辅助数据结构
// class AstronomicalPosition {
//   final double longitude; // 黄经/赤经
//   final double latitude; 
//   final double epoch; // 历元年份

//   AstronomicalPosition applyPrecession(double offsetDegrees) => 
//       AstronomicalPosition(
//         longitude: (longitude + offsetDegrees) % 360,
//         latitude: latitude,
//         epoch: epoch,
//       );
// }

// class GeoRegion {
//   final String province;
//   final String landmark;
//   const GeoRegion(this.province, this.landmark);
// }

// // 十二宫模型增强
// class TwelvePalaces {
//   final Map<DiZhi, PalaceConfig> palaces;
//   final AlignmentRule alignmentRule;

//   /// 根据出生时间计算命宫
//   DiZhi calculateLifePalace(DateTime birthTime) {
//     final solarTime = birthTime.toSolarTime();
//     final baseAngle = solarTime.hour * 15 + solarTime.minute / 4;
//     return alignmentRule.getPalace(baseAngle);
//   }
// }

// // 配置示例
// final zhengSystem = StarPanelConfig(
//   coordinateSystem: CoordinateSystemType.equatorial,
//   siderealSystem: StarInnSystemType.classical,
//   precession: null, // 恒星制不启用岁差
//   epoch: EpochCorrection.yuanDynasty,
//   starSequence: ZhengStarSequence.get(),
// );


