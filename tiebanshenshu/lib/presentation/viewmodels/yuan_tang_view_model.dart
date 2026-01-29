import 'package:common/enums.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/enums.dart';
import '../../domain/models/base_number_tiao_wen_list_model.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../domain/models/yuan_tang_base_number_model.dart';
import '../../features/yuan_tang_gua/yuan_tang_calculator.dart';
import '../../usecases/yuan_tang_tiao_wen_list_use_case.dart';
import 'base_tiao_wen_list_view_model.dart';

/// 元堂卦条文列表ViewModel
///
/// 负责管理元堂卦条文列表的UI状态和业务逻辑调用
/// 继承自BaseTiaoWenListViewModel，提供统一的状态管理
class YuanTangViewModel extends BaseTiaoWenListViewModel {
  final YuanTangTiaoWenListUseCase _useCase;

  /// 当前选择的八字
  EightChars? _currentEightChars;

  /// 当前选择的性别
  Gender? _currentGender;

  /// 当前选择的三元
  YuanYunOrder? _currentThreeYuan;

  /// 当前选择的出生节气后
  TwentyFourJieQi? _currentBirthAfterZhi;

  /// 当前选择的月份类型
  YuanTangMonthType _currentMonthType = YuanTangMonthType.monthYinYan;

  /// 当前选择的历法类型
  CalanderType _currentCalanderType = CalanderType.solar;

  /// Domain层结果（包含YuanTangBaseNumberModel）
  MultiBaseNumberResult? _domainResult;

  YuanTangViewModel(this._useCase);

  @override
  String get name => '元堂卦ViewModel';

  @override
  String get description => '基于元堂卦取数法计算条文列表的ViewModel';

  /// 当前选择的八字
  EightChars? get currentEightChars => _currentEightChars;

  /// 当前选择的性别
  Gender? get currentGender => _currentGender;

  /// 当前选择的三元
  YuanYunOrder? get currentThreeYuan => _currentThreeYuan;

  /// 当前选择的出生节气后
  TwentyFourJieQi? get currentBirthAfterZhi => _currentBirthAfterZhi;

  /// 当前选择的月份类型
  YuanTangMonthType get currentMonthType => _currentMonthType;

  /// 当前选择的历法类型
  CalanderType get currentCalanderType => _currentCalanderType;

  /// 设置元堂卦参数并计算条文列表
  ///
  /// [eightChars] 八字信息
  /// [gender] 性别（"男" / "女"）
  /// [threeYuan] 三元（"上" / "中" / "下"）
  /// [birthAfterZhi] 出生节气后（"夏至" / "冬至"）
  /// [monthType] 月份类型（可选，默认为monthYinYan）
  /// [calanderType] 历法类型（可选，默认为solar）
  Future<void> setYuanTangParams({
    required EightChars eightChars,
    required Gender gender,
    required YuanYunOrder threeYuan,
    required TwentyFourJieQi birthAfterZhi,
    YuanTangMonthType? monthType,
    CalanderType? calanderType,
  }) async {
    _currentEightChars = eightChars;
    _currentGender = gender;
    _currentThreeYuan = threeYuan;
    _currentBirthAfterZhi = birthAfterZhi;
    if (monthType != null) _currentMonthType = monthType;
    if (calanderType != null) _currentCalanderType = calanderType;
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
      final params = YuanTangUseCaseParams(
        eightChars: _currentEightChars!,
        gender: _currentGender!,
        threeYuan: _currentThreeYuan!,
        birthAfterZhi: _currentBirthAfterZhi!,
        monthType: _currentMonthType,
        calanderType: _currentCalanderType,
      );
      final domainResult = await _useCase.execute(params);
      // 保存domain结果以便访问YuanTangBaseNumberModel
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

  /// 获取YuanTangBaseNumberModel（完整的中间结果）
  YuanTangBaseNumberModel? get yuanTangModel {
    if (!hasResult || _domainResult == null) return null;

    // 从sourceData中获取YuanTangBaseNumberModel
    final sourceData = _domainResult!.sourceData;
    if (sourceData.containsKey('yuanTangBaseNumberModel')) {
      return sourceData['yuanTangBaseNumberModel'] as YuanTangBaseNumberModel?;
    }

    return null;
  }

  /// 是否有YuanTangModel
  bool get hasYuanTangModel => yuanTangModel != null;

  /// 获取BaseNumberTiaoWenListModel列表（包含先天和后天条文）
  List<BaseNumberTiaoWenListModel> get baseNumberTiaoWenList {
    if (!hasResult || _domainResult == null) return [];
    return _domainResult!.baseNumberTiaoWenList;
  }

  /// 获取所有条文编号
  List<int> get allTiaoWenNumbers {
    if (!hasResult || _domainResult == null) return [];
    if (_domainResult!.baseNumberTiaoWenList.isEmpty) return [];
    return _domainResult!.baseNumberTiaoWenList.first.tiaoWenNumbers;
  }

  /// 获取参数显示文本
  String get paramsDisplayText {
    if (!hasSelection) return '未选择';
    return '性别:$_currentGender, 三元:$_currentThreeYuan, 节气:$_currentBirthAfterZhi';
  }

  /// 获取四柱显示文本
  String get fourZhuDisplayText {
    if (_currentEightChars == null) return '未选择';
    return _currentEightChars.toString();
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
    return 'YuanTangViewModel('
        'fourZhu: $_currentEightChars, '
        'gender: $_currentGender, '
        'threeYuan: $_currentThreeYuan, '
        'birthAfterZhi: $_currentBirthAfterZhi, '
        'hasSelection: $hasSelection, '
        '${super.toString()}'
        ')';
  }
}
