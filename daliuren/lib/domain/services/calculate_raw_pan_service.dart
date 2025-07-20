import 'package:common/enums.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:common/shared/shared.dart';
import 'package:daliuren/domain/entities/raw_pan_info_model.dart';
import 'package:daliuren/domain/enums/gui_ren.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:tuple/tuple.dart';

import '../../core/constants/da_liu_ren_common_constants.dart';
import '../../model/pan_config.dart';
import '../entities/liu_ren_pan_model.dart';
import '../enums/pan_type.dart';
import 'calculate_day_night_gui_ren.dart';
import 'calculate_gui_ren_position_service.dart';
import 'calculate_month_general_service.dart';
import 'calculate_upon_gan_service.dart';
import 'three_chuan_calculator.dart';

///
/// 用于实时进行排盘
/// 盘面的结果为最基础的 四课、三传、盘面十二宫、日干支 、干上神
// @Deprecated("current deprecated")
class CalculateRawPanService {
  final CalculateMonthGeneralService _monthGeneralService =
      CalculateMonthGeneralService();
  final CalculateUponGanService _zhiOnGanService = CalculateUponGanService();
  final CalculateDayNightGuiRen _dayNightGuiRen = CalculateDayNightGuiRen();
  final CalculateGuiRenPositionService _guiRenPositionService =
      CalculateGuiRenPositionService();

  LiuRenPanModel calculate(DaLiuRenPanConfig config,
      DivinationDatetimeModel divinationDatetimeModel) {
    final JiaZi dayJiaZi = divinationDatetimeModel.dayJiaZi;
    // 1. 计算月将
    final MonthGeneral _monthGeneral = _monthGeneralService.calculate(
        config.monthGeneralType, divinationDatetimeModel);

    // 2. 计算干上神
    final DiZhi uponGod =
        _zhiOnGanService.calculate(_monthGeneral, divinationDatetimeModel);

    // 3. 计算日夜贵人
    final EnumDayNight dayNight = _dayNightGuiRen.calculate(
        config.dayNightBoundaryType, divinationDatetimeModel);

    // 4. 计算贵人位置
    final DiZhi guiRenPosition = CalculateGuiRenPositionService.calculate(
        divinationDatetimeModel.dayJiaZi.gan, dayNight, config.guiRenType);

    // 5. 安地盘：以地支十二位（子、丑、寅、卯、辰、巳、午、未、申、酉、戌、亥）为基础，按照一定的顺序排列。
    List<DiZhi> diPan = DiZhi.listAll; // 地盘固定为十二地支顺序

    // 6. 立天盘：将月将置于地盘所占的时辰地支上，然后按照顺时针方向，依次将剩余的十一个地支排列在天盘上。
    Map<DiZhi, DiZhi> tianDiPanMapper = _createTianDiPanMapper(
        _monthGeneral, divinationDatetimeModel.timeJiaZi.diZhi);

    // 7. 安人盘：根据地盘上所起的时辰地支，参考贵人顺逆起法，确定贵人的位置，并以此为基础，顺时针或逆时针排列人盘地支。
    Map<DiZhi, GuiRen> godsMapper = _calculateGodsMapper(
        divinationDatetimeModel.timeJiaZi.diZhi,
        tianDiPanMapper,
        guiRenPosition);

    // 8. 生成十二宫的 RawEachGong 映射
    Map<DiZhi, EachGong> gongMapper = {};
    final List<JiaZi> dayXunList =
        JiaZi.getTenXunByXunHeader(dayJiaZi.getXunHeader());
    Map<DiZhi, JiaZi> dayXunMapper =
        Map.fromEntries(dayXunList.map((e) => MapEntry(e.diZhi, e)));

    for (DiZhi groundDiZhi in diPan) {
      gongMapper[groundDiZhi] = EachGong(
        groundPanDiZhi: groundDiZhi,
        skyPanDiZhi: tianDiPanMapper[groundDiZhi]!,
        guiRen: godsMapper[groundDiZhi]!,
        jiaZi: dayXunMapper[groundDiZhi],
      );
    }
    // 9. 定四课
    List<RawEachClass> fourClass =
        _calculateFourClasses(divinationDatetimeModel.dayJiaZi, gongMapper);

    // 10. 定三传
    final threeChuanOutput = DaLiuRenModelCalculator(
            monthJiaZi: divinationDatetimeModel.monthJiaZi,
            dayJiaZi: divinationDatetimeModel.dayJiaZi,
            timeJiaZi: divinationDatetimeModel.timeJiaZi,
            guiRenPosition: guiRenPosition,
            guiRenType: config.guiRenType,
            gong: gongMapper,
            fourClass: fourClass,
            dayNight: dayNight,
            dayNightBoundaryType: config.dayNightBoundaryType)
        .calculate();
    // 根据 threeChuanOutput中 ThreeClassItem生成 EachChuan
    final threeChuanTuple = convertToEachChuan(threeChuanOutput, gongMapper);

    // 11. 定盘类型
    PanType panType = DaLiuRenCommonConstants
        .ziGongUponPanTypeMapper[gongMapper[DiZhi.ZI]!.skyPanDiZhi]!;
    return LiuRenPanModel(
      dayJiaZi: divinationDatetimeModel.dayJiaZi,
      timeGanZhi: divinationDatetimeModel.timeJiaZi,
      monthGeneral: _monthGeneral,
      dayNight: dayNight,
      gongMapper: gongMapper,
      fourClasses: fourClass,
      threeChuans: [
        threeChuanTuple.item1,
        threeChuanTuple.item2,
        threeChuanTuple.item3
      ],
      guiRenLocation: guiRenPosition,
      ju: calculateJu(dayJiaZi, uponGod),
      panType: panType,
      nineZongMen: threeChuanOutput.nineZongmen,
      patternName: threeChuanOutput.patternName,
    );
  }

  int calculateJu(JiaZi dayJiaZi, DiZhi upon) {
    // 1. 获得这个干值日第一局的 干上神
    final firstZhi = DaLiuRenCommonConstants.juMapper[dayJiaZi]!;
    List<DiZhi> _tmpList =
        CollectUtils.changeSeq(firstZhi, DiZhi.listAll.reversed.toList());
    int ju = _tmpList.indexOf(upon) + 1;
    return ju;
  }

  Tuple3<EachChuan, EachChuan, EachChuan> convertToEachChuan(
    ThreeChuanOutput threeChuanOutput,
    Map<DiZhi, EachGong> gongMapper,
  ) {
    DiZhi firstDiZhi = threeChuanOutput.first.diZhi;
    EachGong firstGong = gongMapper[firstDiZhi]!;
    EachChuan firstChuan = EachChuan(
      order: threeChuanOutput.first.order,
      guiRen: firstGong.guiRen,
      liuQin: threeChuanOutput.first.liuQin,
      diZhi: firstDiZhi,
      jiaZi: firstGong.jiaZi,
    );
    DiZhi secondDiZhi = threeChuanOutput.second.diZhi;
    EachGong secondGong = gongMapper[secondDiZhi]!;
    EachChuan secondChuan = EachChuan(
      order: threeChuanOutput.second.order,
      guiRen: secondGong.guiRen,
      liuQin: threeChuanOutput.second.liuQin,
      diZhi: secondDiZhi,
      jiaZi: secondGong.jiaZi,
    );
    DiZhi thirdDiZhi = threeChuanOutput.third.diZhi;
    EachGong thirdGong = gongMapper[thirdDiZhi]!;
    EachChuan thirdChuan = EachChuan(
      order: threeChuanOutput.third.order,
      guiRen: thirdGong.guiRen,
      liuQin: threeChuanOutput.third.liuQin,
      diZhi: thirdDiZhi,
      jiaZi: thirdGong.jiaZi,
    );
    return Tuple3(firstChuan, secondChuan, thirdChuan);
  }

  /// 创建天地盘映射关系
  /// 将月将置于占时地支上，然后按顺时针排列
  Map<DiZhi, DiZhi> _createTianDiPanMapper(
      MonthGeneral monthGeneral, DiZhi timeZhi) {
    List<DiZhi> diPan = DiZhi.listAll;
    List<DiZhi> tianPan = [];

    // 找到月将在十二地支中的位置
    int monthGeneralIndex = diPan.indexOf(monthGeneral.generalZhi);
    // 找到占时在十二地支中的位置
    int timeZhiIndex = diPan.indexOf(timeZhi);

    // 计算月将相对于占时的偏移量
    int offset = (monthGeneralIndex - timeZhiIndex + 12) % 12;

    // 创建天盘序列：从子位开始，按照偏移量顺时针排列
    for (int i = 0; i < 12; i++) {
      int tianPanIndex = (i + offset) % 12;
      tianPan.add(diPan[tianPanIndex]);
    }

    // 创建地盘到天盘的映射
    Map<DiZhi, DiZhi> mapper = {};
    for (int i = 0; i < 12; i++) {
      mapper[diPan[i]] = tianPan[i];
    }

    return mapper;
  }

  /// 计算十二神分布
  /// 根据贵人位置和顺逆起法确定十二神的分布
  Map<DiZhi, GuiRen> _calculateGodsMapper(
      DiZhi timeDiZhi, Map<DiZhi, DiZhi> tianDiPanMapper, DiZhi guiRenDiZhi) {
    // 将天地盘映射反转，以天盘为key
    Map<DiZhi, DiZhi> skyAsKey = tianDiPanMapper.map((k, v) => MapEntry(v, k));

    // 天盘的顺序
    List<DiZhi> skySeq = DiZhi.listAll;

    // 从贵人位置开始排列天盘序列
    List<DiZhi> tianSeq4Gods = _changeDiZhiSeq(guiRenDiZhi, skySeq);

    // 根据贵人天盘落宫对应的地盘确定顺逆
    DiZhi diPanLuoGong = skyAsKey[tianSeq4Gods.first]!;
    List<DiZhi> diSeq4Gods = _changeDiZhiSeq(diPanLuoGong, skySeq);

    // 判断是否为逆时针排列十二神
    // 贵人落在巳、午、未、申、酉、戌时为逆时针
    bool isAntiClockwise = [
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI,
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU
    ].contains(diPanLuoGong);

    List<GuiRen> godsSeq =
        isAntiClockwise ? GuiRen.antiClockwiseList : GuiRen.clockwiseList;

    return Map<DiZhi, GuiRen>.fromIterables(diSeq4Gods, godsSeq);
  }

  /// 改变地支序列，从指定地支开始排列
  List<DiZhi> _changeDiZhiSeq(DiZhi start, List<DiZhi> originalSeq) {
    List<DiZhi> oldList = List.from(originalSeq);
    int startIndex = oldList.indexOf(start);

    List<DiZhi> newList = oldList.sublist(startIndex).toList(growable: true);
    newList.addAll(oldList.sublist(0, startIndex));

    return newList;
  }

  /// 计算四课
  ///
  /// [dayJiaZi] 日柱干支
  /// [tianDiPanMapper] 天地盘映射关系
  /// [godsMapper] 十二神映射关系
  ///
  /// 返回四课列表
  List<RawEachClass> _calculateFourClasses(
    JiaZi dayJiaZi,
    Map<DiZhi, RawEachGong> panMapper,
  ) {
    List<RawEachClass> fourClasses = [];

    // 获取日干和日支
    TianGan riGan = dayJiaZi.tianGan;
    DiZhi riZhi = dayJiaZi.diZhi;

    // 第一课：找到日干的寄宫在地盘上对应的天盘地支
    DiZhi riGanJiGong = CalculateUponGanService.tianGanJiGongMapper[riGan]!;
    // DiZhi firstClassSky = tianDiPanMapper[riGanJiGong]!;

    RawEachGong firstClassGong = panMapper[riGanJiGong]!;
    fourClasses.add(RawFirstClass(
      tianGan: riGan,
      sky: firstClassGong.skyPanDiZhi,
      ground: riGanJiGong,
      guiRen: firstClassGong.guiRen,
    ));

    // 第二课：以第一课为起始，按照地支的顺序（顺时针）找到下一个地支
    // DiZhi secondClassGround = _getNextDiZhi(riGanJiGong);
    // DiZhi secondClassSky = tianDiPanMapper[secondClassGround]!;

    RawEachGong secondClassGong = panMapper[firstClassGong.skyPanDiZhi]!;
    fourClasses.add(RawEachClass(
      order: 2,
      sky: firstClassGong.skyPanDiZhi,
      ground: secondClassGong.skyPanDiZhi,
      guiRen: secondClassGong.guiRen,
    ));

    // 第三课：找到日支在地盘上的寄宫对应的天盘地支
    // 注意：日支本身就是地支，不需要寄宫转换
    DiZhi thirdClassGround = riZhi;
    RawEachGong thirdClassGong = panMapper[thirdClassGround]!;

    fourClasses.add(RawEachClass(
      order: 3,
      sky: thirdClassGong.skyPanDiZhi,
      ground: thirdClassGround,
      guiRen: thirdClassGong.guiRen,
    ));

    // 第四课：以第三课为起始，按照地支的顺序（顺时针）找到下一个地支

    DiZhi fourthClassGround = thirdClassGong.skyPanDiZhi;
    RawEachGong fourthClassGong = panMapper[fourthClassGround]!;

    fourClasses.add(RawEachClass(
      order: 4,
      sky: fourthClassGong.skyPanDiZhi,
      ground: fourthClassGround,
      guiRen: fourthClassGong.guiRen,
    ));

    return fourClasses;
  }
}
