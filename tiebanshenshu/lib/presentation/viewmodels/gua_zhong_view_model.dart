import 'package:common/models/eight_chars.dart';
import '../../domain/models/base_number_tiao_wen_list_model.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../domain/models/gua_zhong_base_number_model.dart';
import '../../usecases/gua_zhong_tiao_wen_list_use_case.dart';
import 'base_tiao_wen_list_view_model.dart';

/// 卦中取数法条文列表ViewModel
///
/// 负责管理卦中取数法条文列表的UI状态和业务逻辑调用
/// 继承自BaseTiaoWenListViewModel，提供统一的状态管理
///
/// **支持三种千位计算方案**:
/// - 方案1（推荐）: 取1代替0，保持四位数格式
/// - 方案2: 取卦先天数代替，保留卦象特征
/// - 方案3: 保留10，允许五位数
///
/// 用户可通过UI多选按钮选择显示哪些方案的条文编号
class GuaZhongViewModel extends BaseTiaoWenListViewModel {
  final GuaZhongTiaoWenListUseCase _useCase;

  /// 当前选择的八字
  EightChars? _currentEightChars;

  /// Domain层结果（包含GuaZhongBaseNumberModel）
  MultiBaseNumberResult? _domainResult;

  /// 当前选中的方案（1, 2, 3）
  /// 默认全部选中
  Set<int> _selectedPlans = {1, 2, 3};

  GuaZhongViewModel(this._useCase);

  @override
  String get name => '卦中取数法ViewModel（三种方案）';

  @override
  String get description => '基于卦中取数法计算条文列表的ViewModel，支持三种千位计算方案';

  /// 当前选择的八字
  EightChars? get currentEightChars => _currentEightChars;

  /// 当前选中的方案集合
  Set<int> get selectedPlans => Set.unmodifiable(_selectedPlans);

  /// 是否选中方案1
  bool get isPlan1Selected => _selectedPlans.contains(1);

  /// 是否选中方案2
  bool get isPlan2Selected => _selectedPlans.contains(2);

  /// 是否选中方案3
  bool get isPlan3Selected => _selectedPlans.contains(3);

  /// 切换方案选择状态
  ///
  /// [planNumber] 方案编号：1, 2, 或 3
  void togglePlan(int planNumber) {
    if (planNumber < 1 || planNumber > 3) return;

    if (_selectedPlans.contains(planNumber)) {
      // 至少保留一个方案
      if (_selectedPlans.length > 1) {
        _selectedPlans.remove(planNumber);
        notifyListeners();
      }
    } else {
      _selectedPlans.add(planNumber);
      notifyListeners();
    }
  }

  /// 设置选中的方案
  ///
  /// [plans] 方案编号集合
  void setSelectedPlans(Set<int> plans) {
    if (plans.isEmpty) return; // 至少保留一个方案
    _selectedPlans = plans.where((p) => p >= 1 && p <= 3).toSet();
    notifyListeners();
  }

  /// 重置为全部方案
  void resetPlans() {
    _selectedPlans = {1, 2, 3};
    notifyListeners();
  }

  /// 设置卦中取数法参数并计算条文列表
  ///
  /// [eightChars] 八字信息
  Future<void> setParams({required EightChars eightChars}) async {
    _currentEightChars = eightChars;
    await calculateTiaoWenList();
  }

  /// 计算条文列表
  ///
  /// 使用当前选择的参数计算条文列表
  Future<void> calculateTiaoWenList() async {
    if (_currentEightChars == null) {
      return;
    }

    await safeExecute(() async {
      final params = GuaZhongUseCaseParams(eightChars: _currentEightChars!);
      final domainResult = await _useCase.execute(params);
      // 保存domain结果以便访问GuaZhongBaseNumberModel
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
    _domainResult = null;
    reset();
  }

  /// 是否已选择参数
  bool get hasSelection => _currentEightChars != null;

  /// 获取GuaZhongBaseNumberModel（完整的中间结果）
  GuaZhongBaseNumberModel? get guaZhongModel {
    if (!hasResult || _domainResult == null) return null;

    // 从sourceData中获取GuaZhongBaseNumberModel
    final sourceData = _domainResult!.sourceData;
    if (sourceData.containsKey('guaZhongBaseNumberModel')) {
      return sourceData['guaZhongBaseNumberModel'] as GuaZhongBaseNumberModel?;
    }

    return null;
  }

  /// 是否有GuaZhongModel
  bool get hasGuaZhongModel => guaZhongModel != null;

  /// 获取BaseNumberTiaoWenListModel列表（包含年月卦和日时卦条文）
  List<BaseNumberTiaoWenListModel> get baseNumberTiaoWenList {
    if (!hasResult || _domainResult == null) return [];
    return _domainResult!.baseNumberTiaoWenList;
  }

  /// 获取年月卦BaseNumberTiaoWenListModel
  BaseNumberTiaoWenListModel? get nianYueBaseNumberTiaoWen {
    if (baseNumberTiaoWenList.isEmpty) return null;
    return baseNumberTiaoWenList[0]; // 第一个是年月卦
  }

  /// 获取日时卦BaseNumberTiaoWenListModel
  BaseNumberTiaoWenListModel? get riShiBaseNumberTiaoWen {
    if (baseNumberTiaoWenList.length < 2) return null;
    return baseNumberTiaoWenList[1]; // 第二个是日时卦
  }

  /// 获取所有条文编号（年月卦 + 日时卦，根据选中方案过滤，去重）
  List<int> get allTiaoWenNumbers {
    final model = guaZhongModel;
    if (model == null) return [];

    final numbers = <int>[];
    for (final plan in _selectedPlans) {
      numbers.addAll(model.getAllTiaoWenNumbersByPlan(plan));
    }
    return numbers.toSet().toList();
  }

  /// 获取带方案标签的条文编号列表（根据选中方案过滤）
  List<(int tiaoWenNumber, int planNumber, String position)>
  get filteredTiaoWenNumbersWithLabel {
    final model = guaZhongModel;
    if (model == null) return [];

    return model.tiaoWenNumbersWithPlanLabel
        .where((item) => _selectedPlans.contains(item.$2))
        .toList();
  }

  /// 获取年月卦条文编号列表（根据选中方案）
  List<int> get nianYueTiaoWenNumbers {
    final model = guaZhongModel;
    if (model == null) return [];

    final numbers = <int>[];
    for (final plan in _selectedPlans) {
      numbers.add(model.getNianYueZhuGuaTiaoWenNumber(plan));
      numbers.add(model.getNianYueHuGuaTiaoWenNumber(plan));
    }
    return numbers;
  }

  /// 获取日时卦条文编号列表（根据选中方案）
  List<int> get riShiTiaoWenNumbers {
    final model = guaZhongModel;
    if (model == null) return [];

    final numbers = <int>[];
    for (final plan in _selectedPlans) {
      numbers.add(model.getRiShiZhuGuaTiaoWenNumber(plan));
      numbers.add(model.getRiShiHuGuaTiaoWenNumber(plan));
    }
    return numbers;
  }

  /// 获取八字显示文本
  String get fourZhuDisplayText {
    if (_currentEightChars == null) return '未选择';
    return _currentEightChars!.toString();
  }

  /// 获取年月卦显示文本（显示所有选中方案）
  String get nianYueGuaDisplayText {
    final model = guaZhongModel;
    if (model == null) return '未计算';

    final parts = <String>[];
    parts.add(model.nianYueZhuGuaName.name);

    for (final plan in _selectedPlans.toList()..sort()) {
      final zhuNumber = model.getNianYueZhuGuaTiaoWenNumber(plan);
      final huNumber = model.getNianYueHuGuaTiaoWenNumber(plan);
      parts.add('方案$plan: 主卦$zhuNumber, 互卦$huNumber');
    }

    return parts.join(' | ');
  }

  /// 获取日时卦显示文本（显示所有选中方案）
  String get riShiGuaDisplayText {
    final model = guaZhongModel;
    if (model == null) return '未计算';

    final parts = <String>[];
    parts.add(model.riShiZhuGuaName.name);

    for (final plan in _selectedPlans.toList()..sort()) {
      final zhuNumber = model.getRiShiZhuGuaTiaoWenNumber(plan);
      final huNumber = model.getRiShiHuGuaTiaoWenNumber(plan);
      parts.add('方案$plan: 主卦$zhuNumber, 互卦$huNumber');
    }

    return parts.join(' | ');
  }

  /// 获取年月卦上卦显示文本
  String get nianYueUpperGuaDisplayText {
    final model = guaZhongModel;
    if (model == null) return '未计算';
    return model.nianYueUpperGuaDisplayText;
  }

  /// 获取年月卦下卦显示文本
  String get nianYueLowerGuaDisplayText {
    final model = guaZhongModel;
    if (model == null) return '未计算';
    return model.nianYueLowerGuaDisplayText;
  }

  /// 获取日时卦上卦显示文本
  String get riShiUpperGuaDisplayText {
    final model = guaZhongModel;
    if (model == null) return '未计算';
    return model.riShiUpperGuaDisplayText;
  }

  /// 获取日时卦下卦显示文本
  String get riShiLowerGuaDisplayText {
    final model = guaZhongModel;
    if (model == null) return '未计算';
    return model.riShiLowerGuaDisplayText;
  }

  /// 获取年月卦计算说明
  String get nianYueGuaDescription {
    final model = guaZhongModel;
    if (model == null) return '未计算';
    return model.nianYueGuaDescription;
  }

  /// 获取日时卦计算说明
  String get riShiGuaDescription {
    final model = guaZhongModel;
    if (model == null) return '未计算';
    return model.riShiGuaDescription;
  }

  @override
  void dispose() {
    _currentEightChars = null;
    _domainResult = null;
    _selectedPlans.clear();
    super.dispose();
  }

  @override
  String toString() {
    return 'GuaZhongViewModel('
        'eightChars: $_currentEightChars, '
        'hasSelection: $hasSelection, '
        'selectedPlans: $_selectedPlans, '
        '${super.toString()}'
        ')';
  }
}
