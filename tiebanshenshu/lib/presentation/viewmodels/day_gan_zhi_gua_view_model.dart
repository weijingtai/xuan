import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';

import '../../usecases/day_gan_zhi_gua_tiao_wen_list_use_case.dart';
import 'base_tiao_wen_list_view_model.dart';

/// 日干支卦条文列表ViewModel
///
/// 负责管理日干支卦条文列表的UI状态和业务逻辑调用
/// 继承自BaseTiaoWenListViewModel，提供统一的状态管理
class DayGanZhiGuaViewModel extends BaseTiaoWenListViewModel {
  final DayGanZhiGuaTiaoWenListUseCase _useCase;

  /// 当前选择的日干支
  JiaZi? _selectedDayGanZhi;

  DayGanZhiGuaViewModel(this._useCase);

  @override
  String get name => '日干支卦ViewModel';

  @override
  String get description => '基于日干支计算条文列表的ViewModel';

  /// 当前选择的日干支
  JiaZi? get selectedDayGanZhi => _selectedDayGanZhi;

  /// 设置日干支并计算条文列表
  ///
  /// [dayGanZhi] 日干支
  Future<void> setDayGanZhi(JiaZi dayGanZhi) async {
    _selectedDayGanZhi = dayGanZhi;
    await calculateTiaoWenList();
  }

  /// 从八字中提取日干支并计算条文列表
  ///
  /// [eightChars] 八字
  Future<void> setFromEightChars(EightChars eightChars) async {
    await setDayGanZhi(eightChars.day);
  }

  /// 计算条文列表
  ///
  /// 使用当前选择的日干支计算条文列表
  Future<void> calculateTiaoWenList() async {
    if (_selectedDayGanZhi == null) {
      return;
    }

    await safeExecute(() async {
      final params = DayGanZhiGuaUseCaseParams(dayGanZhi: _selectedDayGanZhi!);
      return await _useCase.execute(params);
    });
  }

  @override
  Future<void> refresh() async {
    await calculateTiaoWenList();
  }

  /// 清除选择的日干支
  void clearSelection() {
    _selectedDayGanZhi = null;
    reset();
  }

  /// 是否已选择日干支
  bool get hasSelection => _selectedDayGanZhi != null;

  /// 获取日干支显示文本
  String get dayGanZhiDisplayText => _selectedDayGanZhi?.name ?? '未选择';

  @override
  void dispose() {
    _selectedDayGanZhi = null;
    super.dispose();
  }

  @override
  String toString() {
    return 'DayGanZhiGuaViewModel('
        'selectedDayGanZhi: $_selectedDayGanZhi, '
        'hasSelection: $hasSelection, '
        '${super.toString()}'
        ')';
  }
}
