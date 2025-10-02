import 'models/fei_xian_info.dart';
import 'utils/palace_utils.dart';

class FeiXian {
  int currentAge;
  final String mainPalace;
  final String yinYang;
  late final List<String> sanhe;

  FeiXian({
    required this.currentAge,
    required this.mainPalace,
    required this.yinYang,
  }) {
    sanhe = _getSanhe();
  }

  List<String> _getSanhe() {
    if (yinYang == "阳") {
      // 阳宫逆地支顺取三合（例：午宫三合为寅、戌）
      return [
        PalaceUtils.getPrevPalace(mainPalace, step: 2),
        PalaceUtils.getNextPalace(mainPalace, step: 2),
      ];
    } else {
      // 阴宫顺地支逆取三合（例：未宫三合为亥、卯）
      return [
        PalaceUtils.getNextPalace(mainPalace, step: 2),
        PalaceUtils.getPrevPalace(mainPalace, step: 2),
      ];
    }
  }

  List<FeiXianInfo> generateSequence(int duration) {
    List<FeiXianInfo> sequence = [];
    int yearsCovered = 0;

    while (yearsCovered < duration) {
      // 前2年在本宫
      if (yearsCovered + 2 <= duration) {
        sequence.add(FeiXianInfo(
          startAge: currentAge,
          endAge: currentAge + 1,
          palace: mainPalace,
        ));
        currentAge += 2;
        yearsCovered += 2;
      } else {
        break;
      }

      // 第3-4年在对宫
      String oppositePalace = PalaceUtils.getOppositePalace(mainPalace);
      if (yearsCovered + 2 <= duration) {
        sequence.add(FeiXianInfo(
          startAge: currentAge,
          endAge: currentAge + 1,
          palace: oppositePalace,
        ));
        currentAge += 2;
        yearsCovered += 2;
      } else {
        break;
      }

      // 第5-6年遍历三合宫（阳宫顺行，阴宫逆行）
      for (String palace in sanhe) {
        if (yearsCovered + 1 <= duration) {
          sequence.add(FeiXianInfo(
            startAge: currentAge,
            endAge: currentAge,
            palace: palace,
          ));
          currentAge += 1;
          yearsCovered += 1;
        } else {
          break;
        }
      }
    }

    return sequence;
  }
}
