import 'package:common/models/eight_chars.dart';

import '../../usecases/tai_xuan_four_zhu_tiao_wen_list_use_case.dart';
import 'base_tiao_wen_list_view_model.dart';

/// 太玄四柱条文列表ViewModel
///
/// 负责管理太玄四柱条文列表的UI状态和业务逻辑调用
/// 继承自BaseTiaoWenListViewModel，提供统一的状态管理
class TaiXuanFourZhuViewModel extends BaseTiaoWenListViewModel {
  final TaiXuanFourZhuTiaoWenListUseCase _useCase;

  /// 当前选择的八字
  EightChars? _selectedEightChars;

  TaiXuanFourZhuViewModel(this._useCase);

  @override
  String get name => '太玄四柱ViewModel';

  @override
  String get description => '基于太玄四柱计算条文列表的ViewModel';

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
      final params = TaiXuanFourZhuUseCaseParams(
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

  /// 获取年柱显示文本
  String get yearPillarText => _selectedEightChars?.year.name ?? '';

  /// 获取月柱显示文本
  String get monthPillarText => _selectedEightChars?.month.name ?? '';

  /// 获取日柱显示文本
  String get dayPillarText => _selectedEightChars?.day.name ?? '';

  /// 获取时柱显示文本
  String get hourPillarText => _selectedEightChars?.time.name ?? '';

  /// 获取所有柱显示文本
  List<String> get allPillarTexts =>
      _selectedEightChars?.allJiaZi.map((jz) => jz.name).toList() ?? [];

  /// 是否有多个条文结果
  /// 太玄四柱可能产生多个基础数，因此可能有多个条文
  bool get hasMultipleResults => result?.tiaoWenNumbers.length != null;

  /// 获取条文数量
  int get resultCount => result?.tiaoWenNumbers.length ?? 0;

  /// 获取条文编号列表的显示文本
  String get tiaoWenNumbersDisplayText {
    if (result?.tiaoWenNumbers.isEmpty ?? true) {
      return '无结果';
    }
    return result!.tiaoWenNumbers.join(', ');
  }

  @override
  void dispose() {
    _selectedEightChars = null;
    super.dispose();
  }

  @override
  String toString() {
    return 'TaiXuanFourZhuViewModel('
        'selectedEightChars: $_selectedEightChars, '
        'hasSelection: $hasSelection, '
        'resultCount: $resultCount, '
        '${super.toString()}'
        ')';
  }
}
