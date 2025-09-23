import 'package:common/models/eight_chars.dart';

import '../../usecases/four_zhu_tian_gan_tiao_wen_list_use_case.dart';
import 'base_tiao_wen_list_view_model.dart';

/// 四柱天干条文列表ViewModel
///
/// 负责管理四柱天干条文列表的UI状态和业务逻辑调用
/// 继承自BaseTiaoWenListViewModel，提供统一的状态管理
class FourZhuTianGanViewModel extends BaseTiaoWenListViewModel {
  final FourZhuTianGanTiaoWenListUseCase _useCase;

  /// 当前选择的八字
  EightChars? _selectedEightChars;

  FourZhuTianGanViewModel(this._useCase);

  @override
  String get name => '四柱天干ViewModel';

  @override
  String get description => '基于四柱天干计算条文列表的ViewModel';

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
      final params = FourZhuTianGanUseCaseParams(
        eightChars: _selectedEightChars!,
      );
      return await _useCase.execute(params);
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

  /// 获取年干显示文本
  String get yearTianGanText => _selectedEightChars?.yearTianGan.name ?? '';

  /// 获取月干显示文本
  String get monthTianGanText => _selectedEightChars?.monthTianGan.name ?? '';

  /// 获取日干显示文本
  String get dayTianGanText => _selectedEightChars?.dayTianGan.name ?? '';

  /// 获取时干显示文本
  String get hourTianGanText => _selectedEightChars?.hourTianGan.name ?? '';

  /// 获取所有天干显示文本
  List<String> get allTianGanTexts =>
      _selectedEightChars?.allTianGan.map((tg) => tg.name).toList() ?? [];

  @override
  void dispose() {
    _selectedEightChars = null;
    super.dispose();
  }

  @override
  String toString() {
    return 'FourZhuTianGanViewModel('
        'selectedEightChars: $_selectedEightChars, '
        'hasSelection: $hasSelection, '
        '${super.toString()}'
        ')';
  }
}
