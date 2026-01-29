import 'package:common/models/eight_chars.dart';

import '../../domain/models/multi_base_number_result.dart';
import '../../usecases/ba_gua_jia_ze_tiao_wen_list_use_case.dart';
import 'base_tiao_wen_list_view_model.dart';

/// 八卦加则条文列表ViewModel
///
/// 负责管理八卦加则条文列表的UI状态和业务逻辑调用
/// 继承自BaseTiaoWenListViewModel，提供统一的状态管理
class BaGuaJiaZeViewModel extends BaseTiaoWenListViewModel {
  final BaGuaJiaZeTiaoWenListUseCase _useCase;

  /// 当前选择的八字
  EightChars? _selectedEightChars;

  /// Domain层结果（包含baseNumberTiaoWenList）
  MultiBaseNumberResult? _domainResult;

  BaGuaJiaZeViewModel(this._useCase);

  @override
  String get name => '八卦加则ViewModel';

  @override
  String get description => '基于八卦加则计算条文列表的ViewModel';

  /// 当前选择的八字
  EightChars? get selectedEightChars => _selectedEightChars;

  /// 设置八字并计算条文列表
  ///
  /// [eightChars] 八字
  Future<void> setEightChars(EightChars eightChars) async {
    _selectedEightChars = eightChars;
    await calculateTiaoWenList();
  }

  /// 计算条文列表
  ///
  /// 使用当前选择的八字计算条文列表
  Future<void> calculateTiaoWenList() async {
    if (_selectedEightChars == null) {
      return;
    }

    await safeExecute(() async {
      final params = BaGuaJiaZeUseCaseParams(
        eightChars: _selectedEightChars!,
      );
      final domainResult = await _useCase.execute(params);
      // 保存domain结果以便访问baseNumberTiaoWenList
      _domainResult = domainResult;
      return domainResult;
    });
  }

  @override
  Future<void> refresh() async {
    await calculateTiaoWenList();
  }

  /// 清除选择的八字
  void clearSelection() {
    _selectedEightChars = null;
    reset();
  }

  /// 是否已选择八字
  bool get hasSelection => _selectedEightChars != null;

  /// 获取八字显示文本
  String get eightCharsDisplayText => _selectedEightChars?.toString() ?? '未选择';

  /// 获取按柱分组的结果
  ///
  /// 返回 Map<柱名, List<结果>>
  /// 例如: {"年柱": [年柱-爻序法结果, 年柱-纳甲法结果], ...}
  Map<String, List<dynamic>> get groupedResults {
    if (!hasResult || _domainResult == null) return {};

    final grouped = <String, List<dynamic>>{};

    for (final item in _domainResult!.baseNumberTiaoWenList) {
      // 从name中提取柱名（如"年柱-爻序法" -> "年柱"）
      final parts = item.name.split('-');
      final pillarName = parts.isNotEmpty ? parts[0] : item.name;

      if (!grouped.containsKey(pillarName)) {
        grouped[pillarName] = [];
      }

      grouped[pillarName]!.add(item);
    }

    return grouped;
  }

  /// 获取所有结果列表（按顺序）
  List<dynamic> get allResults {
    if (!hasResult || _domainResult == null) return [];
    return _domainResult!.baseNumberTiaoWenList;
  }

  /// 获取结果总数
  int get resultCount => _domainResult?.baseNumberTiaoWenList.length ?? 0;

  /// 获取年柱结果
  List<dynamic> get yearResults {
    return groupedResults['年柱'] ?? [];
  }

  /// 获取月柱结果
  List<dynamic> get monthResults {
    return groupedResults['月柱'] ?? [];
  }

  /// 获取日柱结果
  List<dynamic> get dayResults {
    return groupedResults['日柱'] ?? [];
  }

  /// 获取时柱结果
  List<dynamic> get timeResults {
    return groupedResults['时柱'] ?? [];
  }

  @override
  void dispose() {
    _selectedEightChars = null;
    _domainResult = null;
    super.dispose();
  }

  @override
  String toString() {
    return 'BaGuaJiaZeViewModel('
        'selectedEightChars: $_selectedEightChars, '
        'hasSelection: $hasSelection, '
        'resultCount: $resultCount, '
        '${super.toString()}'
        ')';
  }
}
