import 'package:common/enums.dart';
import 'package:intl/intl.dart';
import 'package:lunar/calendar/Lunar.dart';
import 'package:qimendunjia/enums/enum_three_yuan.dart';
import 'package:qimendunjia/enums/enum_zhi_run_type.dart';
import 'package:qimendunjia/model/shi_jia_ju.dart';
import 'package:qimendunjia/utils/zheng_shou_dong_zhi_list.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_arrange_plate_type.dart';

class QiMenJuCalculator {}

/// 时家奇门局计算器的抽象基类。
///
/// 定义了所有时家奇门排盘方法（如拆补、置润、茅山、阴盘）共有的属性和方法。
/// 子类需要实现具体的 [calculate] 方法来提供特定排盘方式的局计算逻辑。
abstract class ShiJiaQiMenJuCalculator {
  /// 排盘类型，例如拆补、置润等。
  final ArrangeType arrangeType;

  /// 需要排盘的公历日期和时间。
  final DateTime dateTime;

  // 存储阳遁时各节气的上元、中元、下元对应的局数。
  // 例如：冬至对应 (1, 7, 4)，表示冬至上元为阳遁一局，中元为阳遁七局，下元为阳遁四局。
  static final YANG_DUN_JIE_QI_JU_NUMER = {
    TwentyFourJieQi.DONG_ZHI: const Tuple3(1, 7, 4), // 冬至: 上元1局, 中元7局, 下元4局
    TwentyFourJieQi.XIAO_HAN: const Tuple3(2, 8, 5), // 小寒: 上元2局, 中元8局, 下元5局
    TwentyFourJieQi.DA_HAN: const Tuple3(3, 9, 6), // 大寒: 上元3局, 中元9局, 下元6局
    TwentyFourJieQi.LI_CHUN: const Tuple3(8, 5, 2), // 立春: 上元8局, 中元5局, 下元2局
    TwentyFourJieQi.YU_SHUI: const Tuple3(9, 6, 3), // 雨水: 上元9局, 中元6局, 下元3局
    TwentyFourJieQi.JING_ZHE: const Tuple3(1, 7, 4), // 惊蛰: 上元1局, 中元7局, 下元4局
    TwentyFourJieQi.CHUN_FEN: const Tuple3(3, 9, 6), // 春分: 上元3局, 中元9局, 下元6局
    TwentyFourJieQi.QING_MING: const Tuple3(4, 1, 7), // 清明: 上元4局, 中元1局, 下元7局
    TwentyFourJieQi.GU_YU: const Tuple3(5, 2, 8), // 谷雨: 上元5局, 中元2局, 下元8局
    TwentyFourJieQi.LI_XIA: const Tuple3(4, 1, 7), // 立夏: 上元4局, 中元1局, 下元7局
    TwentyFourJieQi.XIAO_MAN: const Tuple3(5, 2, 8), // 小满: 上元5局, 中元2局, 下元8局
    TwentyFourJieQi.MANG_ZHONG: const Tuple3(6, 3, 9), // 芒种: 上元6局, 中元3局, 下元9局
  };
  static List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> get yangDunList {
    List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> result = [];
    for (var entries in YANG_DUN_JIE_QI_JU_NUMER.entries) {
      result.add(Tuple3(entries.value.item1, EnumThreeYuan.START, entries.key));
      result
          .add(Tuple3(entries.value.item2, EnumThreeYuan.MIDDLE, entries.key));
      result.add(Tuple3(entries.value.item3, EnumThreeYuan.END, entries.key));
    }
    return result;
  }

  // 存储阴遁时各节气的上元、中元、下元对应的局数。
  // 例如：夏至对应 (9, 3, 6)，表示夏至上元为阴遁九局，中元为阴遁三局，下元为阴遁六局。
  static final YIN_DUN_JIE_QI_JU_NUMER = {
    TwentyFourJieQi.XIA_ZHI: const Tuple3(9, 3, 6), // 夏至: 上元9局, 中元3局, 下元6局
    TwentyFourJieQi.XIAO_SHU: const Tuple3(8, 2, 5), // 小暑: 上元8局, 中元2局, 下元5局
    TwentyFourJieQi.DA_SHU: const Tuple3(7, 1, 4), // 大暑: 上元7局, 中元1局, 下元4局
    TwentyFourJieQi.LI_QIU: const Tuple3(2, 5, 8), // 立秋: 上元2局, 中元5局, 下元8局
    TwentyFourJieQi.CHU_SHU: const Tuple3(1, 4, 7), // 处暑: 上元1局, 中元4局, 下元7局
    TwentyFourJieQi.BAI_LU: const Tuple3(9, 3, 6), // 白露: 上元9局, 中元3局, 下元6局
    TwentyFourJieQi.QIU_FEN: const Tuple3(7, 1, 4), // 秋分: 上元7局, 中元1局, 下元4局
    TwentyFourJieQi.HAN_LU: const Tuple3(6, 9, 3), // 寒露: 上元6局, 中元9局, 下元3局
    TwentyFourJieQi.SHUANG_JIANG: const Tuple3(5, 8, 2), // 霜降: 上元5局, 中元8局, 下元2局
    TwentyFourJieQi.LI_DONG: const Tuple3(6, 9, 3), // 立冬: 上元6局, 中元9局, 下元3局
    TwentyFourJieQi.XIAO_XUE: const Tuple3(5, 8, 2), // 小雪: 上元5局, 中元8局, 下元2局
    TwentyFourJieQi.DA_XUE: const Tuple3(4, 7, 1), // 大雪: 上元4局, 中元7局, 下元1局
  };

  static List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> get yinDunList {
    List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> result = [];
    for (var entries in YIN_DUN_JIE_QI_JU_NUMER.entries) {
      result.add(Tuple3(entries.value.item1, EnumThreeYuan.START, entries.key));
      result
          .add(Tuple3(entries.value.item2, EnumThreeYuan.MIDDLE, entries.key));
      result.add(Tuple3(entries.value.item3, EnumThreeYuan.END, entries.key));
    }
    return result;
  }

  const ShiJiaQiMenJuCalculator({
    required this.dateTime,
    required this.arrangeType,
    // required this.dayJiaZi, // 日干支，某些计算方法可能需要
    // required this.jieQi, // 当前节气，某些计算方法可能需要
  });

  /// 根据符头的地支确定其属于上元、中元还是下元。
  ///
  /// [fouTou] (符头)的干支。
  /// - 地支为子、午、卯、酉（四墓 Yucatán）的符头属于上元。
  /// - 地支为寅、申、巳、亥（四驿马）的符头属于中元。
  /// - 地支为辰、戌、丑、未（四库）的符头属于下元。
  static EnumThreeYuan getThreeYuanByFuHead(JiaZi fouTou) {
    if (DiZhi.fourMuYu.contains(fouTou.diZhi)) {
      // 子午卯酉为上元
      return EnumThreeYuan.START;
    } else if (DiZhi.fourYiMa.contains(fouTou.diZhi)) {
      // 寅申巳亥为中元
      return EnumThreeYuan.MIDDLE;
    } else {
      // 辰戌丑未为下元
      return EnumThreeYuan.END;
    }
  }

  /// 抽象方法，计算时家奇门局。
  ///
  /// 子类必须实现此方法，根据各自的排盘规则（如拆补、置润等）返回一个 [ShiJiaJu] 对象。
  ShiJiaJu calculate();
}

/// 拆补法计算器。
///
/// 拆补法是时家奇门的一种起局方法。其核心特点是：
/// - 符头：日干支逢甲或己者为符头。例如甲子日、己卯日等。每个符头统管五天。
/// - 三元：根据符头的地支来定。子午卯酉为上元，寅申巳亥为中元，辰戌丑未为下元。
/// - 局数：根据当前节气、阴阳遁以及符头所在的三元，从预设的局数表 (YANG_DUN_JIE_QI_JU_NUMER / YIN_DUN_JIE_QI_JU_NUMER) 中查找得到。
class ChaiBuCalculator extends ShiJiaQiMenJuCalculator {
  /// 使用拆补法创建一个奇门局计算器实例。
  ///
  /// [dateTime]：需要排盘的公历日期和时间。
  ChaiBuCalculator({
    required DateTime dateTime,
  }) : super(
          dateTime: dateTime,
          arrangeType: ArrangeType.CHAI_BU, // 排盘方式固定为拆补
        );

  /// 执行拆补法的奇门局计算。
  @override
  ShiJiaJu calculate() {
    return _doCalculate();
  }

  /// 根据拆补法的规则，从日干支推算符头。
  ///
  /// 拆补法中，符头为甲日或己日。每五天一个符头周期。
  /// 例如：甲子为符头，则甲子、乙丑、丙寅、丁卯、戊辰这五日均以此甲子为符头。
  /// [dayGanZhi]：当日的干支。
  /// 返回：该日所属的符头干支。
  static JiaZi getFuTouByDayJiaZi(JiaZi dayGanZhi) {
    // 获取日干支的序号 (0-59)
    // 根据日干支的序号 % 5 来判断在五日符头周期中的位置
    int model = dayGanZhi.number % 5;
    JiaZi fuTou;
    if (model % 5 == 0) {
      // 余数为0，表示是符头周期的最后一天 (如戊辰日，符头为甲子)
      fuTou = JiaZi.getByNumber(dayGanZhi.number - 4); // 符头 = 当前日干支序号 - 4
    } else if (model == 1) {
      // 余数为1，表示是符头当天 (如甲子日，符头为甲子)
      fuTou = dayGanZhi; // 符头即为当日干支
    } else {
      // 其他余数 (2,3,4)，表示在符头周期的中间几天 (如乙丑日，符头为甲子)
      fuTou = JiaZi.getByNumber(
          dayGanZhi.number - model + 1); // 符头 = 当前日干支序号 - 余数 + 1
    }
    return fuTou;
  }

  ShiJiaJu _doCalculate() {
    // 获取排盘时间的农历信息
    Lunar lunar = Lunar.fromDate(dateTime);
    // 获取排盘当天的日干支
    JiaZi dayGanZhi = JiaZi.getFromGanZhiValue(lunar.getDayInGanZhi())!;

    // 获取当前日期所属的节气名称
    String jieQiName = lunar.getCurrentJieQi()?.getName() ??
        lunar.getPrevJieQi().getName(); // 如果当天不是节气，则取上一个节气
    TwentyFourJieQi jieQi = TwentyFourJieQi.fromName(jieQiName);

    // 1. 根据节气判断当前是阳遁还是阴遁
    YinYang yinYangDun = jieQi.yinYangDun;

    // 特殊处理：如果排盘时间为23点 (子时)，日干支应算作下一天
    if (dateTime.hour == 23) {
      dayGanZhi = JiaZi.getByNumber(
          (dayGanZhi.number + 1) % 60); // 日干支序号+1，然后模60确保在甲子表范围内
    }

    // 2. 根据当日干支获取符头
    JiaZi fuTou = getFuTouByDayJiaZi(dayGanZhi);

    // 3. 根据符头的地支确定三元（上元、中元、下元）
    EnumThreeYuan threeYuan =
        ShiJiaQiMenJuCalculator.getThreeYuanByFuHead(fuTou);

    // 4. 根据阴阳遁和当前节气，获取对应的上中下三元的局数表
    Tuple3<int, int, int> juTuple;
    if (yinYangDun.isYang) {
      // 阳遁
      juTuple = ShiJiaQiMenJuCalculator.YANG_DUN_JIE_QI_JU_NUMER[jieQi]!;
    } else {
      // 阴遁
      juTuple = ShiJiaQiMenJuCalculator.YIN_DUN_JIE_QI_JU_NUMER[jieQi]!;
    }

    // 5. 根据符头的三元，从局数表中选取对应的局数
    int juNumber;
    switch (threeYuan) {
      case EnumThreeYuan.START: // 上元
        juNumber = juTuple.item1;
        break;
      case EnumThreeYuan.MIDDLE: // 中元
        juNumber = juTuple.item2;
        break;
      // case EnumThreeYuan.END: // 下元
      default:
        juNumber = juTuple.item3;
        break;
    }

    // 6. 构建并返回时家局对象
    return ShiJiaJu(
        panDateTime: dateTime, // 排盘的公历时间
        juNumber: juNumber, // 计算得到的局数
        fuTouJiaZi: fuTou, // 当前局的符头
        yinYangDun: yinYangDun, // 阴遁或阳遁
        jieQiAt: jieQi, // 排盘时间所在的节气
        jieQiStartAt: DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(lunar.getJieQiTable()[jieQi.name]!.toYmdHms()), // 当前节气的开始时间
        jieQiEnd:
            TwentyFourJieQi.fromName(lunar.getNextJieQi().getName()), // 下一个节气
        jieQiEndAt: DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(lunar.getNextJieQi().getSolar().toYmdHms()), // 下一个节气的开始时间
        atThreeYuan: threeYuan, // 符头所属的三元
        fourZhuEightChar: [
          // 四柱八字
          lunar.getYearInGanZhi(), // 年柱
          lunar.getMonthInGanZhi(), // 月柱
          dayGanZhi.name, // 日柱 (已处理23点情况)
          lunar.getTimeInGanZhi() // 时柱
        ].join(" ").toString());
  }
}

// 置润
/// 置润法计算器。
///
/// 置润法是另一种时家奇门起局方法，主要特点在于处理一年中日辰多少不齐（即一年非固定360天）的问题，
/// 通过超神、接气、置闰（重复某个节气的三元）等方式来调整。
/// 符头规则与拆补法不同，置润法规定甲子、己卯、甲午、己酉为上元符头，每十五日一换。
class ZhiRunCalculator extends ShiJiaQiMenJuCalculator {
  ZhiRunCalculator({
    required DateTime dateTime,
  }) : super(
          dateTime: dateTime,
          arrangeType: ArrangeType.ZHI_RUN,
        );

  /// 执行置润法的奇门局计算。
  @override
  ShiJiaJu calculate() {
    return _doCalculate();
  }

  // _getRelevantTwoZhiDates 方法用于获取在指定正授冬至和排盘日期之间的所有冬至和夏至的日期。
  // zhengShouDongZhi: 上一个正授冬至的日期。
  // panDateTime: 排盘（目标）日期。
  // dateFormatter: 用于解析日期字符串的格式化工具。
  // 返回一个包含所有相关冬至和夏至日期的列表。
  static List<DateTime> _getRelevantTwoZhiDates(DateTime zhengShouDongZhi,
      DateTime panDateTime, DateFormat dateFormatter) {
    // dateTimes 存储计算得到的冬至和夏至日期
    List<DateTime> dateTimes = [];
    int yearStart = zhengShouDongZhi.year + 1; // 正授日冬至实为第二年冬至 所以“+1”
    int targetEnd = panDateTime.year;

    for (var i = yearStart; i <= targetEnd; i++) {
      Lunar tmpLunar = Lunar.fromDate(DateTime(i, 1, 1));
      DateTime thisYearDongZhi =
          dateFormatter.parse(tmpLunar.getJieQiTable()["冬至"]!.toYmdHms());
      DateTime thisYearXiaZhi =
          dateFormatter.parse(tmpLunar.getJieQiTable()["夏至"]!.toYmdHms());

      // 将时间调整为 前一天子时开始时间
      thisYearDongZhi = DateTime(thisYearDongZhi.year, thisYearDongZhi.month,
          thisYearDongZhi.day - 1, 22, 59, 59);
      thisYearXiaZhi = DateTime(thisYearXiaZhi.year, thisYearXiaZhi.month,
          thisYearXiaZhi.day - 1, 22, 59, 59);

      dateTimes.add(thisYearDongZhi);
      dateTimes.add(thisYearXiaZhi);
    }

    // 检查targetDateTime 的前一个 二至节是冬至还是夏至
    Lunar targetLunar = Lunar.fromDate(panDateTime);
    String targetDateJieQi = targetLunar.getJieQi();
    if (targetDateJieQi.isEmpty) {
      targetDateJieQi = targetLunar.getPrevJieQi().getName();
    }

    if (panDateTime.month == 12 && panDateTime.day >= 18) {
      // 如果目标日期为12月，则判断日期是否在在下一年冬至开始后，
      DateTime tmp2 = DateTime(panDateTime.year, panDateTime.month + 3,
          panDateTime.day); // 使用month + 3是为了确保跨年获取正确的冬至
      Lunar tmp2Lunar = Lunar.fromDate(tmp2);
      DateTime theDongZhiDate =
          dateFormatter.parse(tmp2Lunar.getJieQiTable()["冬至"]!.toYmdHms());
      if (theDongZhiDate.isBefore(panDateTime)) {
        theDongZhiDate = DateTime(theDongZhiDate.year, theDongZhiDate.month,
            theDongZhiDate.day - 1, 22, 59, 59);
        // 确保不重复添加
        if (!dateTimes.any((dt) => dt.isAtSameMomentAs(theDongZhiDate))) {
          dateTimes.add(theDongZhiDate);
        }
      }
    }
    // 根据日期排序，确保顺序正确
    dateTimes.sort((a, b) => a.compareTo(b));
    return dateTimes;
  }

  /// 置润法 只有甲子、己卯、甲午、己酉 为上元符头
  JiaZi getFuTouByDayJiaZi(JiaZi dayGanZhi) {
    // 2. 获取日的干支
    // 3. 根据日的干支获取符头，
    JiaZi fuTou;
    if (dayGanZhi.number <= 15) {
      fuTou = JiaZi.JIA_ZI; // 甲子
    } else if (dayGanZhi.number > 15 && dayGanZhi.number <= 30) {
      fuTou = JiaZi.JI_MAO; // 己卯
    } else if (dayGanZhi.number > 30 && dayGanZhi.number <= 45) {
      fuTou = JiaZi.JIA_WU; // 甲午
    } else {
      fuTou = JiaZi.JI_YOU; // 己酉
    }
    return fuTou;
  }

  static final DateFormat dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");
  // _doCalculate 是 ZhiRunCalculator 内执行实际计算的核心私有方法。
  // 它负责整合所有计算步骤，例如：
  // 1. 处理日期和时间，特别是针对子时（23点后）进行调整，确保干支的准确性。
  // 2. 获取日干支，并根据置润法的规则（甲子、己卯、甲午、己酉为上元符头）确定符头。
  // 3. 如果排盘当天不是符头，则追溯到符头所在的日期。
  // 4. 调用 doCa 方法获取局数、三元、节气等关键信息。
  // 5. 构建并返回 ShiJiaJu 对象，其中包含了完整的奇门局信息。
  ShiJiaJu _doCalculate() {
    Lunar lunar = Lunar.fromDate(dateTime);
    String timeGanZhi = lunar.getTimeInGanZhi();
    if (dateTime.hour == 23) {
      // 时辰如果是23点之后 需要将日干支调整为下一天
      // 影响年月日的干支
      lunar = Lunar.fromDate(dateTime.add(const Duration(hours: 1)));
    }

    JiaZi dayJiaZi = JiaZi.getFromGanZhiValue(lunar.getDayInGanZhi())!;
    String eightChar = [
      lunar.getYearInGanZhi(),
      lunar.getMonthInGanZhi(),
      dayJiaZi.name,
      timeGanZhi
    ].join(" ").toString();

    // 起局时间所在的这一年节气
    String jieQiName =
        lunar.getCurrentJieQi()?.getName() ?? lunar.getPrevJieQi().getName();
    TwentyFourJieQi jieQi = TwentyFourJieQi.fromName(jieQiName);
    DateTime jieQiStartAt =
        dateFormatter.parse(lunar.getJieQiTable()[jieQi.name]!.toYmdHms());
    // 1. 根据节气查看当前节气是阴遁还是阳遁
    JiaZi fuTou = getFuTouByDayJiaZi(dayJiaZi);

    // 符头那天
    Lunar fuTouLunar = lunar; // 当天是符头
    DateTime fuTouDateTime = dateTime;
    if (fuTou != dayJiaZi) {
      // 当天不是符头，找到符头那天

      // 相差的天数，用于构建符头那天
      int days = dayJiaZi.number - fuTou.number;
      print("符头干支: ${fuTou.name}");
      fuTouDateTime = dateTime.subtract(Duration(days: days - 1));
      print(dayJiaZi.name);
      print(dateTime);
      print("符头时间：$fuTouDateTime,当前节气为${jieQi.name}，开始于$jieQiStartAt");
      fuTouLunar = Lunar.fromDate(fuTouDateTime);
      print(fuTouLunar.getDayInGanZhi());
    }
    Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> tuple =
        doCa(dateTime); // 调用 doCa 获取局数等核心信息

    return ShiJiaJu(
        panDateTime: dateTime,
        juNumber: tuple.item1,
        fuTouJiaZi: fuTou,
        yinYangDun: tuple.item3.yinYangDun,
        jieQiAt: jieQi,
        jieQiStartAt: jieQiStartAt,
        jieQiEnd: TwentyFourJieQi.fromName(lunar.getNextJieQi().getName()),
        jieQiEndAt: DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(lunar.getNextJieQi().getSolar().toYmdHms()),
        atThreeYuan: tuple.item2,
        fourZhuEightChar: eightChar,
        panJuJieQi: tuple.item3,
        juDayNumber: tuple.item4);
  }

  // doCa 方法是 ZhiRunCalculator 中计算局数、三元、节气和当前元中日数的关键方法。
  // 主要职责包括：
  // 1. 确定上一个“正授冬至”的日期，这是置润法计算的基准点。
  // 2. 计算排盘日期与上一个正授冬至之间的天数差异。
  // 3. 处理子时问题：如果排盘时间是23点之后，则将日期推至下一天进行计算。
  // 4. 根据排盘日期与正授冬至是否在同一年，分别调用 insideOneYear 或 otherYears 方法进行后续计算。
  Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> doCa(DateTime dateTime) {
    // 上一个正授冬至时间

    final lastZhengShouDongZhiDateTime =
        ZhengShouDongZhiList.getPreviousZhengShouDongZhi(dateTime);

    int diffInDays = dateTime.difference(lastZhengShouDongZhiDateTime).inDays;
    var findLunarByDateTime = dateTime;
    if (dateTime.hour == 23) {
      // 如果时间为子时 则天为下一天
      diffInDays += 1;
      findLunarByDateTime.add(const Duration(hours: 1));
    }

    var diffYears = diffInDays ~/ 365;
    if (diffYears == 0) {
      return insideOneYear(lastZhengShouDongZhiDateTime, findLunarByDateTime);
    } else {
      return otherYears(lastZhengShouDongZhiDateTime, dateTime);
    }
    // 目标天 所在年的 冬至、夏至 节气时间
  }

  Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> insideOneYear(
      DateTime zhengShouDongZhi, DateTime targetDateTime) {
    DateTime targetTime = targetDateTime;
    if (targetTime.hour == 23) {
      targetTime = targetTime.add(const Duration(hours: 1)); // 给为第二天
    }
    int finalDiffDays = targetTime.difference(zhengShouDongZhi).inDays;
    List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> dunList = [];
    if (finalDiffDays < 180) {
      dunList.addAll(ShiJiaQiMenJuCalculator.yangDunList);
    } else if (finalDiffDays < 360) {
      dunList.addAll(ShiJiaQiMenJuCalculator.yangDunList);
      dunList.addAll(ShiJiaQiMenJuCalculator.yinDunList);
    } else {
      dunList.addAll(ShiJiaQiMenJuCalculator.yangDunList);
      dunList.addAll(ShiJiaQiMenJuCalculator.yinDunList);
      dunList.addAll(ShiJiaQiMenJuCalculator.yangDunList);
    }

    dunList = dunList.skip(finalDiffDays ~/ 5).toList();

    return Tuple4(dunList.first.item1, dunList.first.item2, dunList.first.item3,
        finalDiffDays % 5 + 1);
  }

  // otherYears 方法用于处理排盘日期 (panDateTime) 与上一个正授冬至 (zhengShouDongZhi) 不在同一年内的情况下的局数计算。
  // 这是置润法中较为复杂的部分，涉及到跨年度的节气累积和超神、接气、正授的判断。
  //
  // zhengShouDongZhi: 上一个正授冬至的日期。
  // panDateTime: 排盘（目标）日期。
  //
  // 该方法的核心逻辑是：
  // 1. （已提取到 _getRelevantTwoZhiDates）获取从 `zhengShouDongZhi` 的下一年开始，直到 `panDateTime` 所在年份（可能包含下一年冬至）的所有冬至和夏至日期。
  // 2. 计算这些连续的冬至/夏至节气之间相隔的天数，形成 `daysBetweenEachTwoZhi` 列表。
  // 3. 遍历 `daysBetweenEachTwoZhi`，模拟每个180天（阳遁或阴遁）的周期：
  //    a. 根据当前是阳遁还是阴遁周期，以及上一个周期的置润情况（`previousLoopBalance` 和 `nextDunShuldBe`），确定当前周期实际分配的天数。
  //    b. 将对应的阳遁或阴遁节气列表（`ShiJiaQiMenJuCalculator.yangDunList` 或 `yinDunList`）添加到总的 `dunList` 中。
  //    c. 判断当前180天周期是正授（正好180天）、超神（大于180天但不足9天）、还是接气/置润（小于180天或大于等于180+9天）。
  //    d. 根据判断结果，更新 `previousLoopBalance`（下一个周期需要补偿或扣除的天数）和 `nextDunShuldBe`（下一个周期的置润类型）。如果需要置润（重复上一个节气的三元），则额外添加对应的节气到 `dunList`。
  // 4. 计算排盘日期 (`targetDateTime`) 相对于 `dateTimes` 列表中的第一个二至节的总天数 (`totalDiffInDays`)。
  // 5. 如果 `dunList` 中累积的元数不足以覆盖 `totalDiffInDays`，则根据最后一个遁（`finishedDun`）是阳遁还是阴遁，补上一个完整的对立遁的节气列表。
  // 6. 最后，通过 `totalDiffInDays` 从 `dunList` 中定位到排盘日期所在的元，并计算出元内第几天，返回局数、三元、节气和元内日数。
  Tuple4<int, EnumThreeYuan, TwentyFourJieQi, int> otherYears(
      DateTime zhengShouDongZhi, DateTime panDateTime) {
    Lunar startLunar = Lunar.fromDate(zhengShouDongZhi);
    DateTime targetDateTime = panDateTime;
    if (targetDateTime.hour == 23) {
      targetDateTime = targetDateTime.add(const Duration(hours: 1)); // 给为第二天
    }
    Lunar targetLunar = Lunar.fromDate(targetDateTime);

    // 获取从正授冬至的下一年到排盘日期的每年的冬至和夏至日期。
    // 这些日期是计算置润的基础，通过 _getRelevantTwoZhiDates 方法获得。
    List<DateTime> dateTimes = _getRelevantTwoZhiDates(
        zhengShouDongZhi, targetDateTime, dateFormatter);

    // 计算这些连续的冬至/夏至之间相隔的天数。
    // 例如，对于日期列表 [冬至A, 夏至B, 冬至C]，将计算出 [夏至B与冬至A相差的天数, 冬至C与夏至B相差的天数]。
    // 这些天数用于后续判断每个180天周期（阳遁或阴遁）是正授、超神还是接气。
    List<int> daysBetweenEachTwoZhi = [];
    for (int i = 1; i < dateTimes.length; i++) {
      daysBetweenEachTwoZhi
          .add(dateTimes[i].difference(dateTimes[i - 1]).inDays + 1);
    }
    YinYang lastPeriodType = YinYang.YIN; // 记录上一个处理的遁的类型（阳遁或阴遁），用于最后补充dunList
    int daysCarryOver =
        0; // 记录上一个180天周期结束后，需要带到下一个周期计算的天数（正数表示下一个周期需补，负数表示下一个周期需减）
    EnumZhiRunType currentPeriodZhiRunType =
        EnumZhiRunType.ZHENG_SHOU; // 当前180天周期的置润类型
    List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> dunList =
        []; // 累积的遁列表（包含局数、三元、节气）

    // 遍历每一个二至节之间的时段
    for (int i = 0; i < daysBetweenEachTwoZhi.length; i++) {
      Tuple4<List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>>, int,
          EnumZhiRunType, YinYang> periodResult;
      if (i == 0 || i % 2 == 0) {
        // 索引为偶数，通常为阳遁周期 (冬至到夏至)
        periodResult = _processYangDunPeriod(
            daysBetweenEachTwoZhi[i], daysCarryOver, currentPeriodZhiRunType);
      } else {
        // 索引为奇数，通常为阴遁周期 (夏至到冬至)
        periodResult = _processYinDunPeriod(
            daysBetweenEachTwoZhi[i], daysCarryOver, currentPeriodZhiRunType);
      }
      dunList.addAll(periodResult.item1);
      daysCarryOver = periodResult.item2;
      currentPeriodZhiRunType = periodResult.item3;
      lastPeriodType = periodResult.item4;
    }

    // 在所有二至时段处理完毕后，计算目标日期相对于第一个二至节的总天数
    int totalDiffInDays = targetDateTime.difference(dateTimes.first).inDays;

    // 如果累积的dunList天数不足以覆盖totalDiffInDays，
    // 这通常发生在目标日期超出了已计算的所有二至周期范围，需要根据最后一个周期的类型补充相反类型的遁。
    if (dunList.length * 5 <= totalDiffInDays) {
      if (lastPeriodType.isYang) {
        // 如果最后一个处理的周期是阳遁
        // print("天数不足，需要使用补全阴遁 $totalDiffInDays ${dunList.length * 5}");
        dunList.addAll(ShiJiaQiMenJuCalculator.yinDunList); // 补充一个完整的阴遁周期
      } else {
        // 如果最后一个处理的周期是阴遁
        // print("天数不足，需要使用补全阳遁  $totalDiffInDays ${dunList.length * 5}");
        dunList.addAll(ShiJiaQiMenJuCalculator.yangDunList); // 补充一个完整的阳遁周期
      }
    }

    var resultList = dunList.skip(totalDiffInDays ~/ 5).toList();
    // print(resultList.length);

    return Tuple4(resultList.first.item1, resultList.first.item2,
        resultList.first.item3, totalDiffInDays % 5 + 1);
  }

  // _processYangDunPeriod 处理阳遁180天周期内的超神、接气、置润逻辑。
  //
  // daysInPeriod: 当前阳遁周期（例如某年冬至到夏至）的实际天数。
  // daysCarryOverFromPrevious: 上一个阴遁周期结束时，需要延续到当前阳遁周期的天数。
  //                            正数表示上个周期多余，本周期需要补足；负数表示上个周期不足，本周期需要扣除。
  // previousZhiRunType: 上一个阴遁周期的置润类型，影响本周期天数的调整方式。
  //
  // 返回: Tuple4
  //   item1 (List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>>): 此阳遁周期产生的节气元列表，将加入总的dunList。
  //   item2 (int): 当前阳遁周期结束后，需要带到下一个阴遁周期的天数结余。
  //   item3 (EnumZhiRunType): 当前阳遁周期最终确定的置润类型，将作为下一个阴遁周期的 previousZhiRunType。
  //   item4 (YinYang): 当前处理的周期类型，固定为 YinYang.YANG。
  static Tuple4<List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>>, int,
          EnumZhiRunType, YinYang>
      _processYangDunPeriod(int daysInPeriod, int daysCarryOverFromPrevious,
          EnumZhiRunType previousZhiRunType) {
    List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> periodDunList = [];
    int newDaysCarryOver = 0;
    EnumZhiRunType nextZhiRunType = EnumZhiRunType.ZHENG_SHOU;

    // 根据上一个周期的置润类型，调整当前周期的实际天数
    int currentEffectiveDays = daysInPeriod;
    if (previousZhiRunType == EnumZhiRunType.JIE_QI) {
      // 上一周期是接气，本周期天数要减去上周期“借”的天数
      currentEffectiveDays = daysInPeriod - daysCarryOverFromPrevious;
    } else if (previousZhiRunType == EnumZhiRunType.CHAO_SHEN) {
      // 上一周期是超神，本周期天数要加上上周期“欠”的天数
      currentEffectiveDays = daysInPeriod + daysCarryOverFromPrevious;
    } else {
      // 正授或初始情况，直接使用上周期结余调整
      currentEffectiveDays = daysInPeriod + daysCarryOverFromPrevious;
    }

    periodDunList.addAll(ShiJiaQiMenJuCalculator.yangDunList); // 阳遁周期，基础为阳遁表

    if (currentEffectiveDays == 180) {
      // 正授：阳遁周期不多不少正好180天
      // print("正授结束，无超神，接气之类。阳遁正好180天");
      nextZhiRunType = EnumZhiRunType.ZHENG_SHOU;
      newDaysCarryOver = 0; // 无结余
    } else if (currentEffectiveDays > 180) {
      // 天数超出180天
      if (currentEffectiveDays - 180 >= 9) {
        // 置润：超出天数大于等于9天，需要重复芒种三元（阳遁最后一个节气）
        newDaysCarryOver =
            15 - (currentEffectiveDays - 180); // 下一个阴遁周期需要“接气”，补回 (15 - 超出天数) 天
        // print("阳遁180天已经用完，然而并没有夏至没到，其时间超过9天（为${currentEffectiveDays-180}），需要进行置润操作，重复芒种节三元15天，阴遁开始需要向后延 $newDaysCarryOver 天");
        nextZhiRunType = EnumZhiRunType.JIE_QI; // 下一周期为接气
        periodDunList.addAll(ShiJiaQiMenJuCalculator.yangDunList
            .sublist(ShiJiaQiMenJuCalculator.yangDunList.length - 3)); // 重复芒种三元
      } else {
        // 超神：超出天数小于9天
        newDaysCarryOver =
            currentEffectiveDays - 180; // 这些超出的天数需要下一个阴遁周期“超神”补上（即阴遁提前开始）
        // print("阳遁180天已经用完，然而并没有夏至没到，夏至需要超神补全 $newDaysCarryOver 天（提前n天开始阴遁）");
        nextZhiRunType = EnumZhiRunType.CHAO_SHEN; // 下一周期为超神
      }
    } else {
      // 接气：天数不足180天
      newDaysCarryOver =
          180 - currentEffectiveDays; // 不足的天数，下一个阴遁周期需要“接气”补上（即阴遁延后开始）
      // print("阳遁180天未用完，但夏至节已经到来，阴遁开始需要向后延 $newDaysCarryOver 天");
      nextZhiRunType = EnumZhiRunType.JIE_QI; // 下一周期为接气
    }
    return Tuple4(
        periodDunList, newDaysCarryOver, nextZhiRunType, YinYang.YANG);
  }

  // _processYinDunPeriod 处理阴遁180天周期内的超神、接气、置润逻辑。
  //
  // daysInPeriod: 当前阴遁周期（例如某年夏至到冬至）的实际天数。
  // daysCarryOverFromPrevious: 上一个阳遁周期结束时，需要延续到当前阴遁周期的天数。
  //                            正数表示上个周期多余，本周期需要补足；负数表示上个周期不足，本周期需要扣除。
  // previousZhiRunType: 上一个阳遁周期的置润类型，影响本周期天数的调整方式。
  //
  // 返回: Tuple4
  //   item1 (List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>>): 此阴遁周期产生的节气元列表，将加入总的dunList。
  //   item2 (int): 当前阴遁周期结束后，需要带到下一个阳遁周期的天数结余。
  //   item3 (EnumZhiRunType): 当前阴遁周期最终确定的置润类型，将作为下一个阳遁周期的 previousZhiRunType。
  //   item4 (YinYang): 当前处理的周期类型，固定为 YinYang.YIN。
  static Tuple4<List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>>, int,
          EnumZhiRunType, YinYang>
      _processYinDunPeriod(int daysInPeriod, int daysCarryOverFromPrevious,
          EnumZhiRunType previousZhiRunType) {
    List<Tuple3<int, EnumThreeYuan, TwentyFourJieQi>> periodDunList = [];
    int newDaysCarryOver = 0;
    EnumZhiRunType nextZhiRunType = EnumZhiRunType.ZHENG_SHOU;

    // 根据上一个周期的置润类型，调整当前周期的实际天数
    int currentEffectiveDays = daysInPeriod;
    if (previousZhiRunType == EnumZhiRunType.JIE_QI) {
      // 上一周期是接气，本周期天数要减去上周期“借”的天数
      currentEffectiveDays = daysInPeriod - daysCarryOverFromPrevious;
    } else if (previousZhiRunType == EnumZhiRunType.CHAO_SHEN) {
      // 上一周期是超神，本周期天数要加上上周期“欠”的天数
      currentEffectiveDays = daysInPeriod + daysCarryOverFromPrevious;
    } else {
      // 正授或初始情况，直接使用上周期结余调整
      currentEffectiveDays = daysInPeriod + daysCarryOverFromPrevious;
    }

    periodDunList.addAll(ShiJiaQiMenJuCalculator.yinDunList); // 阴遁周期，基础为阴遁表

    if (currentEffectiveDays == 180) {
      // 正授：阴遁周期不多不少正好180天
      // print("正授结束，无超神，接气之类。阴遁正好180天");
      nextZhiRunType = EnumZhiRunType.ZHENG_SHOU;
      newDaysCarryOver = 0;
    } else if (currentEffectiveDays > 180) {
      // 天数超出180天
      if (currentEffectiveDays - 180 >= 9) {
        // 置润：超出天数大于等于9天，需要重复大雪三元（阴遁最后一个节气）
        newDaysCarryOver =
            15 - (currentEffectiveDays - 180); // 下一个阳遁周期需要“接气”，补回 (15 - 超出天数) 天
        // print("阴遁180天已经用完，然而并没有冬至，其时间超过9天（为${currentEffectiveDays-180}），需要进行置润操作，重复大雪节三元15天，阳遁开始需要向后延 $newDaysCarryOver 天");
        nextZhiRunType = EnumZhiRunType.JIE_QI;
        periodDunList.addAll(ShiJiaQiMenJuCalculator.yinDunList
            .sublist(ShiJiaQiMenJuCalculator.yinDunList.length - 3)); // 重复大雪三元
      } else {
        // 超神：超出天数小于9天
        newDaysCarryOver =
            currentEffectiveDays - 180; // 这些超出的天数需要下一个阳遁周期“超神”补上（即阳遁提前开始）
        // print("阴遁180天已经用完，然而并没有冬至，冬至需要超神补全 $newDaysCarryOver 天（提前n天开始阳遁）");
        nextZhiRunType = EnumZhiRunType.CHAO_SHEN;
      }
    } else {
      // 接气：天数不足180天
      newDaysCarryOver =
          180 - currentEffectiveDays; // 不足的天数，下一个阳遁周期需要“接气”补上（即阳遁延后开始）
      // print("阴遁180天未用完，但冬至节已经到来，阳遁开始需要向后延 $newDaysCarryOver 天");
      nextZhiRunType = EnumZhiRunType.JIE_QI;
    }
    return Tuple4(periodDunList, newDaysCarryOver, nextZhiRunType, YinYang.YIN);
  }
}

// 茅山
/// 茅山法计算器。
///
/// 茅山法（也称飞宫法或飞盘法的一种），其特点是每个节气固定上中下三元，每元固定60个时辰。
/// - 上元：从节气开始的0-59时辰。
/// - 中元：从节气开始的60-119时辰。
/// - 下元：从节气开始的120-179时辰。
///   (注：实际代码中判断边界为 <=180h 上元, <=360h 中元, >360h 下元，这可能与传统定义60时辰（5天）略有差异，需要核对具体算法来源。
///    原注释为120h(5天*24h/天 / 2h/时辰 = 60个时辰), 240h, 360h。代码中的180, 360可能是小时数。)
/// 局数直接取自对应节气和该节气三元的固定局数。
class MaoShanCalculator extends ShiJiaQiMenJuCalculator {
  /// 使用茅山法创建一个奇门局计算器实例。
  ///
  /// [dateTime]：需要排盘的公历日期和时间。
  MaoShanCalculator({
    required DateTime dateTime,
  }) : super(
          dateTime: dateTime,
          arrangeType: ArrangeType.MAO_SHAN, // 排盘方式固定为茅山
        );
  static final DateFormat dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");

  /// 执行茅山法的奇门局计算。
  @override
  ShiJiaJu calculate() {
    return _doCalculate();
  }

  ShiJiaJu _doCalculate() {
    // 获取排盘时间的农历信息
    Lunar lunar = Lunar.fromDate(dateTime);
    // 获取排盘时间的时辰干支
    String timeGanZhi = lunar.getTimeInGanZhi();

    // 特殊处理：如果排盘时间为23点 (子时)，各项数据应算作下一天
    if (dateTime.hour == 23) {
      lunar = Lunar.fromDate(dateTime.add(const Duration(hours: 1)));
    }

    // 获取调整后的日干支（如果跨天了）和完整的四柱八字
    JiaZi dayJiaZi = JiaZi.getFromGanZhiValue(lunar.getDayInGanZhi())!;
    String eightChar = [
      lunar.getYearInGanZhi(),
      lunar.getMonthInGanZhi(),
      dayJiaZi.name,
      timeGanZhi // 时干支在子时调整中通常不变，除非特定算法要求随日子时变化
    ].join(" ").toString();

    // 获取当前日期所属的节气名称
    String jieQiName =
        lunar.getCurrentJieQi()?.getName() ?? lunar.getPrevJieQi().getName();
    TwentyFourJieQi jieQi = TwentyFourJieQi.fromName(jieQiName);

    // 获取当前节气的精确开始时间
    DateTime jieQiExactStartAt =
        dateFormatter.parse(lunar.getJieQiTable()[jieQi.name]!.toYmdHms());
    // 茅山法通常以节气当日的子时（前一天23点）作为节气的开始计算点
    DateTime jieQiCaltStartAt = DateTime(jieQiExactStartAt.year,
        jieQiExactStartAt.month, jieQiExactStartAt.day - 1, 23, 0, 0);

    // 获取下一个节气的开始时间，作为当前节气的结束点
    DateTime nextJieQiExactStartAt = dateFormatter.parse(
        lunar.getJieQiTable()[lunar.getNextJieQi().getName()]!.toYmdHms());
    // 当前节气的计算结束点应为下一个节气开始的前一刻（或前一天23点，取决于算法定义）
    // DateTime currentJieQiCalcEndAt = nextJieQiExactStartAt.subtract(const Duration(days: 1));
    // currentJieQiCalcEndAt = DateTime(currentJieQiCalcEndAt.year, currentJieQiCalcEndAt.month, currentJieQiCalcEndAt.day, 23, 0, 0);

    // 根据节气判断阴阳遁
    Tuple3<int, int, int> dunJuNumbers; // 存储上中下三元的局数
    if (jieQi.yinYangDun.isYang) {
      dunJuNumbers = ShiJiaQiMenJuCalculator.YANG_DUN_JIE_QI_JU_NUMER[jieQi]!;
    } else {
      dunJuNumbers = ShiJiaQiMenJuCalculator.YIN_DUN_JIE_QI_JU_NUMER[jieQi]!;
    }

    // 计算排盘时间距离节气计算开始时间的小时数
    int diffHourPanDateWithJieQiStart =
        dateTime.difference(jieQiCaltStartAt).inHours;

    EnumThreeYuan yuan; // 当前排盘时间所属的三元
    int juNumber; // 计算得到的局数

    // 茅山法规定：每个节气分为上中下三元，每元固定60个时辰（120小时）。
    // 注意：代码中使用180小时、360小时作为分界点，这对应于每个元90个时辰（如果1时辰=2小时）。
    // 这与“每元60个时辰”的说法存在差异，需要确认算法依据。以下按代码逻辑注释。
    // 若1元=60时辰=5天=120小时:
    // if (diffHourPanDateWithJieQiStart < 120) { // 0-119小时，上元
    //   yuan = EnumThreeYuan.START;
    //   juNumber = dunJuNumbers.item1;
    // } else if (diffHourPanDateWithJieQiStart < 240) { // 120-239小时，中元
    //   yuan = EnumThreeYuan.MIDDLE;
    //   juNumber = dunJuNumbers.item2;
    // } else { // >= 240小时，下元 (茅山法一个节气通常15天左右，240小时为10天，下元可持续到节气结束)
    //   yuan = EnumThreeYuan.END;
    //   juNumber = dunJuNumbers.item3;
    // }
    // 当前代码的逻辑 (180h, 360h 为分界):
    if (diffHourPanDateWithJieQiStart <= 180) {
      // 0-180小时，上元
      yuan = EnumThreeYuan.START;
      juNumber = dunJuNumbers.item1;
    } else if (diffHourPanDateWithJieQiStart <= 360 &&
        diffHourPanDateWithJieQiStart > 180) {
      // 181-360小时，中元
      yuan = EnumThreeYuan.MIDDLE;
      juNumber = dunJuNumbers.item2;
    } else {
      // > 360小时，下元
      yuan = EnumThreeYuan.END;
      juNumber = dunJuNumbers.item3;
    }

    // 构建并返回时家局对象
    return ShiJiaJu(
        panDateTime: dateTime,
        juNumber: juNumber,
        // 茅山法的符头通常是节气开始那天的干支，这里取节气计算开始时间的干支
        fuTouJiaZi: JiaZi.getFromGanZhiValue(
            Lunar.fromDate(jieQiCaltStartAt).getDayInGanZhi())!,
        yinYangDun: jieQi.yinYangDun,
        jieQiAt: jieQi, // 当前节气
        jieQiStartAt: jieQiCaltStartAt, // 节气计算开始时间
        jieQiEnd:
            TwentyFourJieQi.fromName(lunar.getNextJieQi().getName()), // 下一个节气
        jieQiEndAt: nextJieQiExactStartAt, // 下一个节气的精确开始时间
        atThreeYuan: yuan, // 所属三元
        fourZhuEightChar: eightChar); // 四柱八字
  }
}

// 阴盘
/// 阴盘法计算器。
///
/// 阴盘奇门（或称飞盘奇门的一种）的局数计算方法较为独特：
/// 局数 = (年支序数 + 农历月数 + 农历日数 + 时支序数) % 9。
/// 如果余数为0，则取9局。
/// 阴阳遁的判断依然依据节气（冬至后阳遁，夏至后阴遁）。
class YinPanCalculator extends ShiJiaQiMenJuCalculator {
  /// 使用阴盘法创建一个奇门局计算器实例。
  ///
  /// [dateTime]：需要排盘的公历日期和时间。
  YinPanCalculator({
    required DateTime dateTime,
  }) : super(
          dateTime: dateTime,
          arrangeType: ArrangeType.YIN_PAN, // 排盘方式固定为阴盘
        );
  static final DateFormat dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");

  /// 执行阴盘法的奇门局计算。
  @override
  ShiJiaJu calculate() {
    return _doCalculate();
  }

  ShiJiaJu _doCalculate() {
    // 获取排盘时间的农历信息
    Lunar lunar = Lunar.fromDate(dateTime);
    // 获取排盘时间的时辰干支
    String timeGanZhi = lunar.getTimeInGanZhi();

    // 特殊处理：如果排盘时间为23点 (子时)，各项数据应算作下一天
    if (dateTime.hour == 23) {
      lunar = Lunar.fromDate(dateTime.add(const Duration(hours: 1)));
    }

    // 获取调整后的日干支（如果跨天了）和完整的四柱八字
    JiaZi dayJiaZi = JiaZi.getFromGanZhiValue(lunar.getDayInGanZhi())!;
    String eightChar = [
      lunar.getYearInGanZhi(), // 年柱
      lunar.getMonthInGanZhi(), // 月柱
      dayJiaZi.name, // 日柱
      timeGanZhi // 时柱
    ].join(" ").toString();

    // 1. 计算阴盘局数
    // 年支序数 (地支的顺序，如子为1, 丑为2, ..., 亥为12)
    int yearZhiIndex =
        JiaZi.getFromGanZhiValue(lunar.getYearInGanZhi())!.diZhi.order;
    // 时支序数
    int timeZhiIndex = JiaZi.getFromGanZhiValue(timeGanZhi)!.diZhi.order;
    // 农历月数
    int lunarMonth = lunar.getMonth();
    // 农历日数
    int lunarDay = lunar.getDay();

    // 局数 = (年支序数 + 农历月数 + 农历日数 + 时支序数) % 9
    int juNumber = (yearZhiIndex + lunarMonth + lunarDay + timeZhiIndex) % 9;
    if (juNumber == 0) {
      // 如果余数为0，则取9局
      juNumber = 9;
    }

    // 2. 判断阴阳遁
    // 获取当前日期所属的节气名称
    String jieQiName =
        lunar.getCurrentJieQi()?.getName() ?? lunar.getPrevJieQi().getName();
    TwentyFourJieQi jieQi = TwentyFourJieQi.fromName(jieQiName);
    YinYang yinYangDun = jieQi.yinYangDun; // 冬至后阳遁，夏至后阴遁

    // 获取节气相关时间信息 (主要用于填充ShiJiaJu对象，阴盘局数计算不直接依赖节气三元)
    DateTime jieQiExactStartAt =
        dateFormatter.parse(lunar.getJieQiTable()[jieQi.name]!.toYmdHms());
    // 节气开始时间通常指节气交换的精确时刻
    DateTime nextJieQiExactStartAt = dateFormatter.parse(
        lunar.getJieQiTable()[lunar.getNextJieQi().getName()]!.toYmdHms());

    // 3. 构建并返回时家局对象
    return ShiJiaJu(
        panDateTime: dateTime,
        juNumber: juNumber, // 计算得到的阴盘局数
        // 阴盘法通常不强调传统意义上的符头，或有其特定定义，此处暂用节气开始日干支或留空/特定值
        // 为保持对象结构一致，暂取节气开始日的干支作为参考，实际应用中可能不同
        fuTouJiaZi: JiaZi.getFromGanZhiValue(
            Lunar.fromDate(jieQiExactStartAt).getDayInGanZhi())!,
        yinYangDun: yinYangDun, // 阴遁或阳遁
        jieQiAt: jieQi, // 当前节气
        jieQiStartAt: jieQiExactStartAt, // 节气精确开始时间
        jieQiEnd:
            TwentyFourJieQi.fromName(lunar.getNextJieQi().getName()), // 下一个节气
        jieQiEndAt: nextJieQiExactStartAt, // 下一个节气的精确开始时间
        atThreeYuan: EnumThreeYuan.NONE, // 阴盘法不使用传统的三元划分方法来定局
        fourZhuEightChar: eightChar); // 四柱八字
  }
}
