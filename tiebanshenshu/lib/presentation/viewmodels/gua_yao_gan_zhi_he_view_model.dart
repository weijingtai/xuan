import 'package:common/models/eight_chars.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../domain/models/gua_yao_gan_zhi_he_base_number_model.dart';
import '../../usecases/gua_yao_gan_zhi_he_tiao_wen_list_use_case.dart';
import 'base_tiao_wen_list_view_model.dart';

/// 卦爻干支和数法条文列表ViewModel
///
/// 负责管理卦爻干支和数法条文列表的UI状态和业务逻辑调用
/// 纳甲方法：固定使用内外卦法（传统纳甲法）
class GuaYaoGanZhiHeViewModel extends BaseTiaoWenListViewModel {
  final GuaYaoGanZhiHeTiaoWenListUseCase _useCase;

  /// 当前选择的八字
  EightChars? _currentEightChars;

  /// 纳甲方法：固定使用内外卦法
  static const GuaYaoGanZhiHeNaJiaMethod _naJiaMethod =
      GuaYaoGanZhiHeNaJiaMethod.innerOuterGua;

  /// Domain层结果（包含GuaYaoGanZhiHeBaseNumberModel）
  MultiBaseNumberResult? _domainResult;

  GuaYaoGanZhiHeViewModel(this._useCase);

  @override
  String get name => '卦爻干支和数法ViewModel';

  @override
  String get description => '基于卦爻干支和数法计算条文列表的ViewModel';

  /// 当前选择的四柱（返回 EightChars）
  EightChars? get currentFourZhu => _currentEightChars;

  /// 纳甲方法（固定为内外卦法）
  GuaYaoGanZhiHeNaJiaMethod get currentNaJiaMethod => _naJiaMethod;

  /// 获取当前domain结果
  MultiBaseNumberResult? get domainResult => _domainResult;

  /// 设置卦爻干支和数法参数并计算条文列表
  ///
  /// [eightChars] 八字信息
  Future<void> setParams({
    required EightChars eightChars,
  }) async {
    _currentEightChars = eightChars;
    await calculateTiaoWenList();
  }

  /// 计算条文列表
  ///
  /// 使用当前选择的八字和固定的纳甲方法（内外卦法）计算条文列表
  Future<void> calculateTiaoWenList() async {
    if (_currentEightChars == null) {
      return;
    }

    await safeExecute(() async {
      final params = GuaYaoGanZhiHeUseCaseParams(
        eightChars: _currentEightChars!,
      );
      final domainResult = await _useCase.execute(
        params,
        naJiaMethod: _naJiaMethod,
      );

      // 直接在safeExecute内部设置_domainResult
      // 这样可以确保如果operation成功执行，_domainResult就被设置
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

  @override
  void dispose() {
    clearSelection();
    super.dispose();
  }
}
