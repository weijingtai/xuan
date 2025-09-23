/// 通用条文列表计算策略
///
/// 提供灵活的配置选项，兼容多种条文计算方法
library;

class TiaoWenListCalculationConfig {
  final TiaoWenCalculationListType type;
  final List<int> calculationList;
  final bool withSub;

  final String? desc;

  /// 私有构造函数
  const TiaoWenListCalculationConfig._({
    required this.type,
    required this.calculationList,
    required this.withSub,
    this.desc,
  });

  /// 基于基数和次数生成配置
  factory TiaoWenListCalculationConfig.loopAddTimes({
    required int baseNumber,
    required int times,
    bool withSub = false,
  }) {
    List<int> calculationList = List.generate(
      times,
      (index) => index * baseNumber,
    );

    List<String> descList = [];
    for (var i = 0; i < calculationList.length; i++) {
      String sign = calculationList[i] > 0 ? "+" : "";
      descList.add("$sign${calculationList[i]}(${sign}${i * baseNumber})");
    }

    if (withSub) {
      calculationList.addAll(calculationList.map((e) => -e).toList());
    }

    return TiaoWenListCalculationConfig._(
      type: TiaoWenCalculationListType.generator,
      calculationList: calculationList,
      withSub: withSub,
      desc: descList.join(", "),
    );
  }

  /// 基于倍数列表生成配置
  /// [multipleList] 建议使用正整数，通过 [withSub] 控制是否需要计算减法
  factory TiaoWenListCalculationConfig.fromMultiples({
    required int baseNumber,
    required List<int> multipleList,
    bool withSub = false,
  }) {
    var clonedList = multipleList.map((e) => e).toList();
    if (withSub) {
      clonedList.addAll(clonedList.map((e) => -e).toList());
    }
    List<int> calculationList = multipleList
        .map((e) => baseNumber * e)
        .toList();
    List<String> descList = [];
    for (var i = 0; i < calculationList.length; i++) {
      String sign = calculationList[i] > 0 ? "+" : "";
      descList.add(
        "$sign${calculationList[i]}(${sign}${multipleList[i] * baseNumber})",
      );
    }

    return TiaoWenListCalculationConfig._(
      type: TiaoWenCalculationListType.generator,
      calculationList: calculationList,
      withSub: withSub,
      desc: descList.join(", "),
    );
  }

  /// 制定没有个list表中计算的数字 - 四门法与八卦棍法，添加的长数
  factory TiaoWenListCalculationConfig.listAdd({
    required List<int> customList,
    bool withSub = false,
  }) {
    List<int> calculationList = List.from(customList);

    if (withSub) {
      calculationList.addAll(customList.map((e) => -e).toList());
    }

    return TiaoWenListCalculationConfig._(
      type: TiaoWenCalculationListType.customized,
      calculationList: calculationList,
      withSub: withSub,
      desc: customList.join(", "),
    );
  }
}

enum TiaoWenCalculationListType { generator, one_by_one, customized }

class TiaoWenListCalculator {
  TiaoWenListCalculationConfig config;

  TiaoWenListCalculator(this.config);

  TiaoWenListCalculationResult calculate(int baseNumber) {
    List<int> allTiaoWen = config.calculationList
        .map((e) => baseNumber + e)
        .toList();

    return TiaoWenListCalculationResult(
      config: config,
      withSub: config.withSub,
      baseNumber: baseNumber,
      tiaoWenNumbers: allTiaoWen,
    );
  }
}

class TiaoWenListCalculationResult {
  TiaoWenListCalculationConfig config;
  bool withSub;
  int baseNumber;
  List<int> tiaoWenNumbers;

  TiaoWenListCalculationResult({
    required this.config,
    required this.withSub,
    required this.baseNumber,
    required this.tiaoWenNumbers,
  });
}
