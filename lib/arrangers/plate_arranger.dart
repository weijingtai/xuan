import 'package:common/enums.dart';
import 'package:qimendunjia/model/jia_zi.dart';
import 'package:qimendunjia/model/pan_arrange_settings.dart';
import 'package:qimendunjia/model/shi_jia_ju.dart';
import 'package:qimendunjia/model/six_jia.dart';
import 'package:qimendunjia/arrangers/plate_arrangement_result.dart';

/// 奇门遁甲盘面排列器的抽象基类。
///
/// 定义了所有具体排盘方法（如转盘、飞盘）的通用接口。
abstract class QiMenPlateArranger {
  /// 抽象方法，用于排列奇门遁甲盘。
  ///
  /// [shiJiaJu]: 当前的时家局信息。
  /// [settings]: 排盘设置。
  /// [timeJiaZi]: 当前时间的干支。
  /// [sixJiaXunHeader]: 当前时间所属的六甲旬首。
  /// 返回一个 [PlateArrangementResult] 对象，包含排列好的盘面信息。
  PlateArrangementResult arrangePlate(
    ShiJiaJu shiJiaJu,
    PanArrangeSettings settings,
    JiaZi timeJiaZi,
    SixJia sixJiaXunHeader,
  );

  /// 根据局数和阴阳遁类型，确定地盘的九宫顺序。
  ///
  /// [numberJu] 当前局数 (1-9)。
  /// [yinYangDun] 当前的阴阳遁类型。
  /// 返回一个包含九个后天八卦枚举值的列表，代表地盘九宫顺序。
  /// 例如，阳遁一局从坎宫起甲子戊，则列表第一个元素为坎。
  /// 阴遁九局从离宫起甲子戊，则列表第一个元素为离。
  List<HouTianGua> arrangeJu(int numberJu, YinYang yinYangDun) {
    final List<HouTianGua> result = List.filled(9, HouTianGua.ZHEN); // 初始化，任意值填充

    if (yinYangDun.isYang) {
      // 阳遁，顺排九宫
      // 局数决定了起始宫位，例如阳遁1局从坎1宫开始，阳遁2局从坤2宫开始
      final int startIndex = numberJu - 1; // 数组索引从0开始
      for (int i = 0; i < 9; i++) {
        result[i] = HouTianGua.fromCode((startIndex + i) % 9 + 1);
      }
    } else {
      // 阴遁，逆排九宫
      // 局数决定了起始宫位，例如阴遁9局从离9宫开始，阴遁8局从艮8宫开始
      final int startIndex = numberJu - 1;
      for (int i = 0; i < 9; i++) {
        int palaceCode = (startIndex - i);
        while (palaceCode < 0) {
          palaceCode += 9; // 处理负数取模，确保宫位号在0-8之间
        }
        result[i] = HouTianGua.fromCode(palaceCode % 9 + 1);
      }
    }
    return result;
  }
}
