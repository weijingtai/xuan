import 'package:json_annotation/json_annotation.dart';

import '../../domain/four_zhu.dart';
import '../calculation_strategy.dart';

@JsonSerializable()
class CorrectifiedTiaoWenNumberInfo {
  final int numberFrom; // 基本数
  final int algorithmNumber; // 通常为 考时定刻中多为 "+" 或 "-"

  final int number; // 条文数
  final String? description;
  final String? denyReason;
  final String? acceptReason;
  final bool? isAcceptable;
  CorrectifiedTiaoWenNumberInfo({
    required this.number,
    required this.numberFrom,
    required this.algorithmNumber,
    this.description,
    this.denyReason,
    this.acceptReason,
    this.isAcceptable,
  });

  // factory CorrectifiedTiaoWenNumberInfo.fromJson(Map<String, dynamic> json) =>
  // _$CorrectifiedTiaoWenNumberInfoFromJson(json);

  // Map<String, dynamic> toJson() => _$CorrectifiedTiaoWenNumberInfoToJson(this);
}

class HuangJiBasicNumberInfo {
  final int order; // primary or secondary 之类的排名
  //correctification order, 根据条文内容矫正的排名
  // 0 为基本数，标识为从未进行过修正
  final int number;
  final int base; // 基础数
  final String baseDesc; // 基数描述

  final int added; // 加成数
  final String addedDesc; // 加成数描述
  final String? description; // 描述

  int get normalizedNumber => HuangJiBaseCalculation.normalizeNumber(number);
  HuangJiBasicNumberInfo({
    required this.order,
    required this.number,
    required this.base,
    required this.baseDesc,
    required this.added,
    required this.addedDesc,
    required this.description,
  });
}

class HuangJiTiaoWenNumberInfo {
  /// 皇极取数法 取到的条文数，以及取数时用到的各数字
  final int number;
  bool get isNeedNormalize => number > 13000;
  int get normalizedNumber => HuangJiBaseCalculation.normalizeNumber(number);
  final int base;
  final int added;
  final String description;
  HuangJiTiaoWenNumberInfo({
    required this.number,
    required this.base,
    required this.added,
    required this.description,
  });
}

/// 皇极取数法基础策略抽象类
abstract class HuangJiBaseCalculation
    extends CalculationStrategy<FourZhu, List<int>> {
  final FourZhu fourZhu;

  /// 年干太玄数
  late final int yearGanTaiXuanNum;

  /// 年支太玄数
  late final int yearZhiTaiXuanNum;

  /// 月干太玄数
  late final int monthGanTaiXuanNum;

  /// 月支太玄数
  late final int monthZhiTaiXuanNum;

  /// 日干太玄数
  late final int dayGanTaiXuanNum;

  /// 日支太玄数
  late final int dayZhiTaiXuanNum;

  /// 时干太玄数
  late final int timeGanTaiXuanNum;

  /// 时支太玄数
  late final int timeZhiTaiXuanNum;

  late final int yuanHuiNumber;
  // late final int _originalPrimaryNumber;
  late HuangJiBasicNumberInfo _originalPrimaryNumberInfo;

  late final int yunShiNumber;
  // late final int _originalSecondaryNumber;
  late HuangJiBasicNumberInfo _originalSecondaryNumberInfo;

  int get originalPrimaryNumber => _originalPrimaryNumberInfo.normalizedNumber;
  int get originalSecondaryNumber =>
      _originalSecondaryNumberInfo.normalizedNumber;

  // int? _primaryBaseNumber;
  // int? _primaryBaseTimes;

  List<CorrectifiedTiaoWenNumberInfo> primaryCorrectifiedTiaoWenNumberInfos =
      [];
  List<CorrectifiedTiaoWenNumberInfo> secondaryCorrectifiedTiaoWenNumberInfos =
      [];

  // int? _secondaryBaseNumber;
  // int? _secondaryBaseTimes;
  HuangJiBasicNumberInfo get primaryBaseNumberInfo {
    // primaryCorrectifiedTiaoWenNumberInfos 是否不存在，是否为空
    if (primaryCorrectifiedTiaoWenNumberInfos.isEmpty) {
      return _originalPrimaryNumberInfo;
    }
    // 取其中 isAccepted == true 的
    final acceptedList = primaryCorrectifiedTiaoWenNumberInfos
        .where((element) => element.isAcceptable == true)
        .toList();
    if (acceptedList.isEmpty) {
      return _originalPrimaryNumberInfo;
    }
    var accepted = acceptedList.first;
    // 根据 accepted 创建 HuangJiBasicNumberInfo
    return HuangJiBasicNumberInfo(
      order: 1,
      number: accepted.number,
      base: accepted.numberFrom,
      baseDesc: '基本数一 (元会基本数 + 千位年干太玄数)',
      added: accepted.algorithmNumber,
      addedDesc: '根据原始基本数一，条文匹配而来',
      description: accepted.acceptReason,
    );
  }

  HuangJiBasicNumberInfo get secondaryBaseNumberInfo {
    // secondaryCorrectifiedTiaoWenNumberInfos 是否不存在，是否为空
    if (secondaryCorrectifiedTiaoWenNumberInfos.isEmpty) {
      return _originalSecondaryNumberInfo;
    }
    // 取其中 isAccepted == true 的
    final acceptedList = secondaryCorrectifiedTiaoWenNumberInfos
        .where((element) => element.isAcceptable == true)
        .toList();
    if (acceptedList.isEmpty) {
      return _originalSecondaryNumberInfo;
    }
    var accepted = acceptedList.first;
    // 根据 accepted 创建 HuangJiBasicNumberInfo
    return HuangJiBasicNumberInfo(
      order: 2,
      number: accepted.number,
      base: accepted.numberFrom,
      baseDesc: '基本数二 (运势基本数 + 千位年干太玄数)',
      added: accepted.algorithmNumber,
      addedDesc: '根据原始基本数二，条文匹配而来',
      description: accepted.acceptReason,
    );
  }

  HuangJiBaseCalculation(this.fourZhu) {
    yearGanTaiXuanNum = fourZhu.yearGanTaixuanNum;
    yearZhiTaiXuanNum = fourZhu.yearZhiTaixuanNum;
    monthGanTaiXuanNum = fourZhu.monthGanTaixuanNum;
    monthZhiTaiXuanNum = fourZhu.monthZhiTaixuanNum;
    dayGanTaiXuanNum = fourZhu.dayGanTaixuanNum;
    dayZhiTaiXuanNum = fourZhu.dayZhiTaixuanNum;
    timeGanTaiXuanNum = fourZhu.timeGanTaixuanNum;
    timeZhiTaiXuanNum = fourZhu.timeZhiTaixuanNum;

    yuanHuiNumber = _calculateYuanHuiNumber(fourZhu);
    yunShiNumber = _calculateYunShiNumber(fourZhu);

    _originalPrimaryNumberInfo = HuangJiBasicNumberInfo(
      order: 1,
      number: yuanHuiNumber + yearGanTaiXuanNum * 1000,
      base: yuanHuiNumber,
      baseDesc: '元会基本数',
      added: yearGanTaiXuanNum * 1000,
      addedDesc: '年干太玄数（千位数）',
      description: '元会基本数 + 年干太玄数（千位）',
    );
    // _originalPrimaryNumber = yuanHuiNumber + fourZhu.yearGanTaixuanNum * 1000;
    // _originalSecondaryNumber = yunShiNumber + fourZhu.yearGanTaixuanNum * 1000;
    _originalSecondaryNumberInfo = HuangJiBasicNumberInfo(
      order: 2,
      base: yunShiNumber,
      number: yunShiNumber + yearGanTaiXuanNum * 1000,
      baseDesc: '运势基本数',
      added: yearGanTaiXuanNum * 1000,
      addedDesc: '年干太玄数（千位数）',
      description: '运势基本数 + 年干太玄数（千位）',
    );
    // _primaryBaseNumber = originalPrimaryNumber;
    // _primaryBaseTimes = 0;

    // _secondaryBaseNumber = originalSecondaryNumber;
    // _secondaryBaseTimes = 0;
    // _initializeNumbers();
  }

  /// 计算元会数
  static int _calculateYuanHuiNumber(FourZhu fourZhu) {
    final yuanNumber = fourZhu.yearGanTaixuanNum + fourZhu.yearZhiTaixuanNum;
    final monthNumber = fourZhu.monthGanTaixuanNum + fourZhu.monthZhiTaixuanNum;

    int tmpYuanNumber = yuanNumber;
    if (tmpYuanNumber < 10) {
      tmpYuanNumber = tmpYuanNumber * 10;
    }
    int tmpMonthNumber = monthNumber;
    if (tmpMonthNumber < 10) {
      tmpMonthNumber = tmpMonthNumber * 10;
    }

    // 左旋
    int yuanHuiNumber = int.parse('$tmpYuanNumber$tmpMonthNumber');
    if (yuanHuiNumber > 13000) {
      yuanHuiNumber = yuanHuiNumber - 12000;
    }
    return yuanHuiNumber;
  }

  /// 计算运世数
  static int _calculateYunShiNumber(FourZhu fourZhu) {
    final dayNumber = fourZhu.dayGanTaixuanNum + fourZhu.dayZhiTaixuanNum;
    final timeNumber = fourZhu.timeGanTaixuanNum + fourZhu.timeZhiTaixuanNum;

    int tmpDayNumber = dayNumber;
    if (dayNumber < 10) {
      tmpDayNumber = tmpDayNumber * 10;
    }

    // 右旋
    final tmpDayStr = tmpDayNumber.toString();
    tmpDayNumber = int.parse(
      '${tmpDayStr[tmpDayStr.length - 1]}${tmpDayStr.substring(0, tmpDayStr.length - 1)}',
    );

    int tmpTimeNumber = timeNumber;
    if (timeNumber < 10) {
      tmpTimeNumber = tmpTimeNumber * 10;
    }
    final tmpTimeStr = tmpTimeNumber.toString();
    tmpTimeNumber = int.parse(
      '${tmpTimeStr[tmpTimeStr.length - 1]}${tmpTimeStr.substring(0, tmpTimeStr.length - 1)}',
    );

    return int.parse('$tmpDayNumber$tmpTimeNumber');
  }

  @override
  String get school => "皇极取数法";

  void addPrimaryCorrectifyList(List<CorrectifiedTiaoWenNumberInfo> list) {
    primaryCorrectifiedTiaoWenNumberInfos.addAll(list);
  }

  void addSecondaryCorrectifyList(List<CorrectifiedTiaoWenNumberInfo> list) {
    secondaryCorrectifiedTiaoWenNumberInfos.addAll(list);
  }

  /// 获取主要基础数
  int get primaryBaseNumber => primaryBaseNumberInfo.number;

  /// 获取次要基础数
  int get secondaryBaseNumber => secondaryBaseNumberInfo.number;

  /// 处理超过13000的数字
  static int normalizeNumber(int number) {
    return number > 13000 ? number - 12000 : number;
  }

  /// 获取所有条文数列表 - 抽象方法，子类必须实现
  List<int> get allTiaowenNumbers;

  @override
  List<int> calculate(FourZhu params) {
    return allTiaowenNumbers;
  }
}
