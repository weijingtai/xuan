import 'package:common/enums.dart';
import 'package:common/models/divination_datetime.dart';

///
/// 计算干上神（干上地支）
class CalculateUponGanService {
  /// 十干寄宫映射表
  /// 根据口诀："甲课寅兮乙课辰，丙戊课巳不需论，丁己课未庚申上，辛戌壬亥是其真，癸课原来丑宫坐，分明不用四正神"
  static const Map<TianGan, DiZhi> tianGanJiGongMapper = {
    TianGan.JIA: DiZhi.YIN, // 甲寄寅
    TianGan.YI: DiZhi.CHEN, // 乙寄辰
    TianGan.BING: DiZhi.SI, // 丙寄巳
    TianGan.DING: DiZhi.WEI, // 丁寄未
    TianGan.WU: DiZhi.SI, // 戊寄巳
    TianGan.JI: DiZhi.WEI, // 己寄未
    TianGan.GENG: DiZhi.SHEN, // 庚寄申
    TianGan.XIN: DiZhi.XU, // 辛寄戌
    TianGan.REN: DiZhi.HAI, // 壬寄亥
    TianGan.GUI: DiZhi.CHOU, // 癸寄丑
  };

  /// 计算干上神（干上地支）
  ///
  /// [monthGeneral] 月将地支
  /// [datetimeModel] 占卜时间模型，包含四柱信息
  ///
  /// 返回干上阳神（第一课）
  DiZhi calculate(
      MonthGeneral monthGeneral, DivinationDatetimeModel datetimeModel) {
    // 1. 获取占时（时柱地支）
    DiZhi shiZhi = datetimeModel.timeJiaZi.diZhi;

    // 2. 获取日干
    TianGan riGan = datetimeModel.dayJiaZi.tianGan;

    // 3. 根据日干查找寄宫
    DiZhi jiGong = tianGanJiGongMapper[riGan]!;

    // 4. 排出天地盘
    // 将月将加在占时的地支上，然后顺时针排列其余十一个地支，形成天盘
    Map<DiZhi, DiZhi> tianDiPanMapper = createTianDiPan(monthGeneral, shiZhi);

    // 5. 确定干上阳神
    // 找到日干寄宫在地盘上的位置，查看其上方所临的天盘地支
    DiZhi ganShangYangShen = tianDiPanMapper[jiGong]!;

    return ganShangYangShen;
  }

  /// 创建天地盘映射关系
  ///
  /// [monthGeneral] 月将地支
  /// [shiZhi] 占时地支
  ///
  /// 返回地盘地支到天盘地支的映射
  Map<DiZhi, DiZhi> createTianDiPan(MonthGeneral monthGeneral, DiZhi shiZhi) {
    // 地盘是十二地支的固定方位（顺时针排列）
    List<DiZhi> diPan = DiZhi.listAll;

    // 天盘：将月将加在占时的地支上，然后顺时针排列其余十一个地支
    List<DiZhi> tianPan = createTianPan(monthGeneral, shiZhi);

    // 创建地盘到天盘的映射关系
    Map<DiZhi, DiZhi> tianDiPanMapper = {};
    for (int i = 0; i < 12; i++) {
      tianDiPanMapper[diPan[i]] = tianPan[i];
    }

    return tianDiPanMapper;
  }

  /// 创建天盘地支序列
  ///
  /// [monthGeneral] 月将地支
  /// [shiZhi] 占时地支
  ///
  /// 返回天盘地支序列（从子位开始顺时针排列）
  List<DiZhi> createTianPan(MonthGeneral monthGeneral, DiZhi shiZhi) {
    // 获取占时地支在十二地支中的位置（从0开始）
    int shiZhiIndex = shiZhi.order - 1;

    // 获取月将地支在十二地支中的位置（从0开始）
    int monthGeneralIndex = monthGeneral.generalZhi.order - 1;

    // 计算月将相对于占时的偏移量
    int offset = (monthGeneralIndex - shiZhiIndex + 12) % 12;

    // 创建天盘序列：从子位开始，按照偏移量顺时针排列
    List<DiZhi> tianPan = [];
    List<DiZhi> allDiZhi = DiZhi.listAll;

    for (int i = 0; i < 12; i++) {
      // 计算当前位置对应的天盘地支
      int tianPanIndex = (i + offset) % 12;
      tianPan.add(allDiZhi[tianPanIndex]);
    }

    return tianPan;
  }
}
