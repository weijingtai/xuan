import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import '../../domain/models/base_number_tiao_wen_list_model.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../domain/models/qian_hou_gua_base_number_model.dart';
import '../../usecases/qian_hou_gua_tiao_wen_list_use_case.dart';
import 'base_tiao_wen_list_view_model.dart';

/// 前后卦取数法条文列表ViewModel
///
/// 负责管理前后卦取数法条文列表的UI状态和业务逻辑调用
/// 继承自BaseTiaoWenListViewModel，提供统一的状态管理
class QianHouGuaViewModel extends BaseTiaoWenListViewModel {
  final QianHouGuaTiaoWenListUseCase _useCase;

  /// 当前选择的八字
  EightChars? _currentEightChars;

  /// 当前选择的性别
  Gender? _currentGender;

  /// 当前选择的三元
  YuanYunOrder? _currentThreeYuan;

  /// 当前选择的出生节气后
  TwentyFourJieQi? _currentBirthAfterZhi;

  /// Domain层结果（包含QianHouGuaBaseNumberModel）
  MultiBaseNumberResult? _domainResult;

  QianHouGuaViewModel(this._useCase);

  @override
  String get name => '前后卦取数法ViewModel';

  @override
  String get description => '基于前后卦取数法计算条文列表的ViewModel';

  /// 当前选择的四柱（返回 EightChars）
  EightChars? get currentFourZhu => _currentEightChars;

  /// 当前选择的性别
  Gender? get currentGender => _currentGender;

  /// 当前选择的三元
  YuanYunOrder? get currentThreeYuan => _currentThreeYuan;

  /// 当前选择的出生节气后
  TwentyFourJieQi? get currentBirthAfterZhi => _currentBirthAfterZhi;

  /// 设置前后卦取数法参数并计算条文列表
  ///
  /// [eightChars] 八字信息
  /// [gender] 性别（"男" / "女"）
  /// [threeYuan] 三元（"上" / "中" / "下"）
  /// [birthAfterZhi] 出生节气后（"夏至" / "冬至"）
  Future<void> setParams({
    required EightChars eightChars,
    required Gender gender,
    required YuanYunOrder threeYuan,
    required TwentyFourJieQi birthAfterZhi,
  }) async {
    _currentEightChars = eightChars;
    _currentGender = gender;
    _currentThreeYuan = threeYuan;
    _currentBirthAfterZhi = birthAfterZhi;
    await calculateTiaoWenList();
  }

  /// 计算条文列表
  ///
  /// 使用当前选择的参数计算条文列表
  Future<void> calculateTiaoWenList() async {
    if (_currentEightChars == null ||
        _currentGender == null ||
        _currentThreeYuan == null ||
        _currentBirthAfterZhi == null) {
      return;
    }

    await safeExecute(() async {
      final params = QianHouGuaUseCaseParams(
        eightChars: _currentEightChars!,
        gender: _currentGender!,
        threeYuan: _currentThreeYuan!,
        birthAfterZhi: _currentBirthAfterZhi!,
      );
      final domainResult = await _useCase.execute(params);
      // 保存domain结果以便访问QianHouGuaBaseNumberModel
      _domainResult = domainResult;
      return domainResult;
    });
  }

  @override
  Future<void> refresh() async {
    await calculateTiaoWenList();
  }

  /// 清除选择
  void clearSelection() {
    _currentEightChars = null;
    _currentGender = null;
    _currentThreeYuan = null;
    _currentBirthAfterZhi = null;
    _domainResult = null;
    reset();
  }

  /// 是否已选择参数
  bool get hasSelection =>
      _currentEightChars != null &&
      _currentGender != null &&
      _currentThreeYuan != null &&
      _currentBirthAfterZhi != null;

  /// 获取QianHouGuaBaseNumberModel（完整的中间结果）
  QianHouGuaBaseNumberModel? get qianHouModel {
    if (!hasResult || _domainResult == null) return null;

    // 从sourceData中获取QianHouGuaBaseNumberModel
    final sourceData = _domainResult!.sourceData;
    if (sourceData.containsKey('qianHouGuaBaseNumberModel')) {
      return sourceData['qianHouGuaBaseNumberModel']
          as QianHouGuaBaseNumberModel?;
    }

    return null;
  }

  /// 是否有QianHouModel
  bool get hasQianHouModel => qianHouModel != null;

  /// 获取BaseNumberTiaoWenListModel列表（包含前卦和后卦条文）
  List<BaseNumberTiaoWenListModel> get baseNumberTiaoWenList {
    if (!hasResult || _domainResult == null) return [];
    return _domainResult!.baseNumberTiaoWenList;
  }

  /// 获取前卦BaseNumberTiaoWenListModel
  BaseNumberTiaoWenListModel? get qianGuaBaseNumberTiaoWen {
    if (baseNumberTiaoWenList.isEmpty) return null;
    return baseNumberTiaoWenList[0]; // 第一个是前卦
  }

  /// 获取后卦BaseNumberTiaoWenListModel
  BaseNumberTiaoWenListModel? get houGuaBaseNumberTiaoWen {
    if (baseNumberTiaoWenList.length < 2) return null;
    return baseNumberTiaoWenList[1]; // 第二个是后卦
  }

  /// 获取前卦条文编号列表
  List<int> get qianGuaTiaoWenNumbers {
    final qianGua = qianGuaBaseNumberTiaoWen;
    if (qianGua == null) return [];
    return qianGua.tiaoWenNumbers;
  }

  /// 获取后卦条文编号列表
  List<int> get houGuaTiaoWenNumbers {
    final houGua = houGuaBaseNumberTiaoWen;
    if (houGua == null) return [];
    return houGua.tiaoWenNumbers;
  }

  /// 获取所有条文编号（前卦 + 后卦，去重）
  List<int> get allTiaoWenNumbers {
    if (!hasResult || _domainResult == null) return [];
    return {...qianGuaTiaoWenNumbers, ...houGuaTiaoWenNumbers}.toList();
  }

  /// 获取参数显示文本
  String get paramsDisplayText {
    if (!hasSelection) return '未选择';
    return '性别:$_currentGender, 三元:$_currentThreeYuan, 节气:$_currentBirthAfterZhi';
  }

  /// 获取四柱显示文本
  String get fourZhuDisplayText {
    if (_currentEightChars == null) return '未选择';
    return _currentEightChars!.toString();
  }

  /// 获取前卦显示文本
  String get qianGuaDisplayText {
    final model = qianHouModel;
    if (model == null) return '未计算';
    return '${model.qianGuaName}（基础数:${model.qianGuaBaseNumber}）';
  }

  /// 获取后卦显示文本
  String get houGuaDisplayText {
    final model = qianHouModel;
    if (model == null) return '未计算';
    return '${model.houGuaName}（基础数:${model.houGuaBaseNumber}）';
  }

  /// 获取先天卦显示文本
  String get xiantianGuaDisplayText {
    final model = qianHouModel;
    if (model == null) return '未计算';
    return '${model.xiantianGua}（上:${model.upperGua} 下:${model.lowerGua}）';
  }

  /// 获取后天卦显示文本
  String get houtianGuaDisplayText {
    final model = qianHouModel;
    if (model == null) return '未计算';
    return model.houtianGua.fullname;
  }

  /// 获取天地卦显示文本
  String get tianDiGuaDisplayText {
    final model = qianHouModel;
    if (model == null) return '未计算';
    return '天卦:${model.tianGua} 地卦:${model.diGua}';
  }

  /// 获取完整基础数（四位数）
  String get fullBaseNumberDisplayText {
    final model = qianHouModel;
    if (model == null) return '未计算';
    return model.fullBaseNumber.toString();
  }

  @override
  void dispose() {
    _currentEightChars = null;
    _currentGender = null;
    _currentThreeYuan = null;
    _currentBirthAfterZhi = null;
    _domainResult = null;
    super.dispose();
  }

  @override
  String toString() {
    return 'QianHouGuaViewModel('
        'fourZhu: $_currentEightChars, '
        'gender: $_currentGender, '
        'threeYuan: $_currentThreeYuan, '
        'birthAfterZhi: $_currentBirthAfterZhi, '
        'hasSelection: $hasSelection, '
        '${super.toString()}'
        ')';
  }
}
