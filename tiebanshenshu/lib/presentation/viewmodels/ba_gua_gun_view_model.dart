import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../domain/models/ba_gua_gun_base_number_model.dart';
import '../../usecases/ba_gua_gun_tiao_wen_list_use_case.dart';
import '../models/ba_gua_gun_ui_model.dart';
import 'base_tiao_wen_list_view_model.dart';

/// 八卦滚法条文列表ViewModel
///
/// 负责管理八卦滚法条文列表的UI状态和业务逻辑调用
/// 继承自BaseTiaoWenListViewModel，提供统一的状态管理
class BaGuaGunViewModel extends BaseTiaoWenListViewModel {
  final BaGuaGunTiaoWenListUseCase _useCase;

  /// 当前选择的八字
  EightChars? _selectedEightChars;

  /// 当前选择的性别
  Gender? _currentGender;

  /// 当前选择的三元
  YuanYunOrder? _currentThreeYuan;

  /// Domain层结果（包含BaGuaGunBaseNumberModel）
  MultiBaseNumberResult? _domainResult;

  /// UI层模型（包含展示所需的格式化数据）
  BaGuaGunUIModel? _uiModel;

  BaGuaGunViewModel(this._useCase);

  @override
  String get name => '八卦滚法ViewModel';

  @override
  String get description => '基于八卦滚法计算条文列表的ViewModel';

  /// 当前选择的八字
  EightChars? get selectedEightChars => _selectedEightChars;

  /// 当前选择的性别
  Gender? get currentGender => _currentGender;

  /// 当前选择的三元
  YuanYunOrder? get currentThreeYuan => _currentThreeYuan;

  /// UI层模型
  BaGuaGunUIModel? get uiModel => _uiModel;

  /// 设置八卦滚法参数并计算条文列表
  ///
  /// [eightChars] 八字信息
  /// [gender] 性别（"男" / "女"）
  /// [threeYuan] 三元（"上" / "中" / "下"）
  Future<void> setEightChars({
    required EightChars eightChars,
    required Gender gender,
    required YuanYunOrder threeYuan,
  }) async {
    _selectedEightChars = eightChars;
    _currentGender = gender;
    _currentThreeYuan = threeYuan;
    await calculateTiaoWenList();
  }

  /// 计算条文列表
  ///
  /// 使用当前选择的参数计算条文列表
  Future<void> calculateTiaoWenList() async {
    if (_selectedEightChars == null ||
        _currentGender == null ||
        _currentThreeYuan == null) {
      return;
    }

    await safeExecute(() async {
      final params = BaGuaGunUseCaseParams(
        eightChars: _selectedEightChars!,
        gender: _currentGender!,
        threeYuan: _currentThreeYuan!,
      );
      final domainResult = await _useCase.execute(params);

      // 保存domain结果
      _domainResult = domainResult;

      // 创建UI模型
      if (domainResult.isSuccess &&
          domainResult.sourceData.containsKey('baGuaGunBaseNumberModel')) {
        final baGuaGunModel =
            domainResult.sourceData['baGuaGunBaseNumberModel']
                as BaGuaGunBaseNumberModel;
        _uiModel = BaGuaGunUIModel.fromDomain(
          baGuaGunModel,
          domainResult.tiaoWenEntities ?? [],
        );
      }

      return domainResult;
    });
  }

  @override
  Future<void> refresh() async {
    await calculateTiaoWenList();
  }

  /// 清除选择
  void clearSelection() {
    _selectedEightChars = null;
    _currentGender = null;
    _currentThreeYuan = null;
    _domainResult = null;
    _uiModel = null;
    reset();
  }

  /// 是否已选择参数
  bool get hasSelection =>
      _selectedEightChars != null &&
      _currentGender != null &&
      _currentThreeYuan != null;

  /// 获取BaGuaGunBaseNumberModel（完整的中间结果）
  BaGuaGunBaseNumberModel? get baGuaGunModel {
    if (!hasResult || _domainResult == null) return null;

    // 从sourceData中获取BaGuaGunBaseNumberModel
    final sourceData = _domainResult!.sourceData;
    if (sourceData.containsKey('baGuaGunBaseNumberModel')) {
      return sourceData['baGuaGunBaseNumberModel'] as BaGuaGunBaseNumberModel?;
    }

    return null;
  }

  /// 是否有BaGuaGunModel
  bool get hasBaGuaGunModel => baGuaGunModel != null;

  /// 是否有UI Model
  bool get hasUIModel => _uiModel != null;

  /// 获取参数显示文本
  String get paramsDisplayText {
    if (!hasSelection) return '未选择';
    return '性别:$_currentGender, 三元:$_currentThreeYuan';
  }

  /// 获取四柱显示文本
  String get fourZhuDisplayText {
    if (_selectedEightChars == null) return '未选择';
    return _selectedEightChars.toString();
  }

  /// 获取基本卦显示文本
  String get basicGuaDisplayText {
    final model = baGuaGunModel;
    if (model == null) return '未计算';
    return '${model.basicGua.fullname}（基本数:${model.basicNumber}）';
  }

  /// 获取变爻基数显示文本
  String get variationBaseDisplayText {
    final model = baGuaGunModel;
    if (model == null) return '未计算';
    return '变爻基数: ${model.variationBase}';
  }

  /// 获取前四卦简要信息
  String get firstFourGuaSummary {
    final model = baGuaGunModel;
    if (model == null) return '未计算';
    return model.firstFourGuaList.map((g) => g.name).join(' → ');
  }

  /// 获取后四卦简要信息
  String get lastFourGuaSummary {
    final model = baGuaGunModel;
    if (model == null) return '未计算';
    return model.lastFourGuaList.map((g) => g.name).join(' → ');
  }

  /// 获取八卦简要信息
  String get eightGuaSummary {
    final model = baGuaGunModel;
    if (model == null) return '未计算';
    return model.eightGuaList.map((g) => g.name).join(' → ');
  }

  /// 获取条文总数
  int get tiaoWenTotalCount {
    final model = baGuaGunModel;
    if (model == null) return 0;
    return model.finalTiaowenList.length;
  }

  /// 获取卦数量
  int get guaCount {
    final model = baGuaGunModel;
    if (model == null) return 0;
    return model.eightGuaList.length;
  }

  @override
  void dispose() {
    _selectedEightChars = null;
    _currentGender = null;
    _currentThreeYuan = null;
    _domainResult = null;
    _uiModel = null;
    super.dispose();
  }

  @override
  String toString() {
    return 'BaGuaGunViewModel('
        'eightChars: $_selectedEightChars, '
        'gender: $_currentGender, '
        'threeYuan: $_currentThreeYuan, '
        'hasSelection: $hasSelection, '
        'guaCount: $guaCount, '
        'tiaoWenCount: $tiaoWenTotalCount, '
        '${super.toString()}'
        ')';
  }
}
