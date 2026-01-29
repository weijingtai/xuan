import 'package:common/models/eight_chars.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/tai_xuan_base_number_model.dart';
import '../../usecases/tai_xuan_four_zhu_tiao_wen_list_use_case.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../domain/models/tiao_wen_list_state.dart';
import '../../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../models/ui_tiao_wen_list_result_model.dart';

/// 太玄四柱条文列表ViewModel
///
/// 负责管理太玄四柱条文列表的UI状态和业务逻辑调用
/// 支持两种纳甲方案的同时计算和显示
class TaiXuanFourZhuViewModel extends ChangeNotifier {
  final TaiXuanFourZhuTiaoWenListUseCase _useCase;

  /// 当前选择的八字
  EightChars? _selectedEightChars;

  // 两种方法的计算结果
  MultiBaseNumberResult? _yearGanYinYangResult;
  MultiBaseNumberResult? _innerOuterGuaResult;

  // 两种方法的UI模型
  UITiaoWenListResultModel? _yearGanYinYangUIModel;
  UITiaoWenListResultModel? _innerOuterGuaUIModel;

  // 两种方法的显示状态（默认都为true）
  bool _showYearGanYinYang = true;
  bool _showInnerOuterGua = true;

  // 状态管理
  TiaoWenListState _state = TiaoWenListState.initial;
  String? _errorMessage;
  TiaoWenCalculationException? _lastException;

  TaiXuanFourZhuViewModel(this._useCase);

  String get name => '太玄四柱ViewModel';
  String get description => '基于太玄四柱计算条文列表的ViewModel（双纳甲方案）';

  // ==================== 基础状态 Getters ====================

  /// 当前状态
  TiaoWenListState get state => _state;

  /// 错误消息
  String? get errorMessage => _errorMessage;

  /// 最后一次异常
  TiaoWenCalculationException? get lastException => _lastException;

  /// 是否正在加载
  bool get isLoading => _state.isLoading;

  /// 是否加载成功
  bool get isSuccess => _state.isSuccess;

  /// 是否有错误
  bool get hasError => _state.isError;

  /// 是否为初始状态
  bool get isInitial => _state.isInitial;

  // ==================== 八字相关 ====================

  /// 当前选择的八字
  EightChars? get selectedEightChars => _selectedEightChars;

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

  // ==================== 年干阴阳纳甲方案 ====================

  /// 年干阴阳纳甲结果
  MultiBaseNumberResult? get yearGanYinYangResult => _yearGanYinYangResult;

  /// 年干阴阳纳甲UI模型
  UITiaoWenListResultModel? get yearGanYinYangUIModel => _yearGanYinYangUIModel;

  /// 是否显示年干阴阳纳甲方案
  bool get showYearGanYinYang => _showYearGanYinYang;

  /// 是否有年干阴阳纳甲结果
  bool get hasYearGanYinYangResult => _yearGanYinYangResult != null && _yearGanYinYangResult!.isSuccess;

  // ==================== 传统内外卦纳甲方案 ====================

  /// 传统内外卦纳甲结果
  MultiBaseNumberResult? get innerOuterGuaResult => _innerOuterGuaResult;

  /// 传统内外卦纳甲UI模型
  UITiaoWenListResultModel? get innerOuterGuaUIModel => _innerOuterGuaUIModel;

  /// 是否显示传统内外卦纳甲方案
  bool get showInnerOuterGua => _showInnerOuterGua;

  /// 是否有传统内外卦纳甲结果
  bool get hasInnerOuterGuaResult => _innerOuterGuaResult != null && _innerOuterGuaResult!.isSuccess;

  // ==================== 显示控制 ====================

  /// 切换年干阴阳纳甲方案显示
  void toggleYearGanYinYang(bool value) {
    _showYearGanYinYang = value;
    notifyListeners();
  }

  /// 切换传统内外卦纳甲方案显示
  void toggleInnerOuterGua(bool value) {
    _showInnerOuterGua = value;
    notifyListeners();
  }

  // ==================== 计算方法 ====================

  /// 设置八字并计算两种方案
  ///
  /// [eightChars] 八字
  Future<void> setEightChars(EightChars eightChars) async {
    _selectedEightChars = eightChars;
    await calculateBothMethods();
  }

  /// 同时计算两种纳甲方案
  Future<void> calculateBothMethods() async {
    if (_selectedEightChars == null) {
      return;
    }

    await _safeExecuteBothMethods(() async {
      final params = TaiXuanFourZhuUseCaseParams(
        eightChars: _selectedEightChars!,
      );
      return await _useCase.calculateBothMethods(params);
    });
  }

  /// 只计算年干阴阳纳甲方案
  Future<void> calculateYearGanYinYang() async {
    if (_selectedEightChars == null) {
      return;
    }

    await _safeExecuteSingleMethod(() async {
      final params = TaiXuanFourZhuUseCaseParams(
        eightChars: _selectedEightChars!,
      );
      final result = await _useCase.execute(
        params,
        naJiaMethod: TaiXuanNaJiaMethod.yearGanYinYang,
      );
      return {TaiXuanNaJiaMethod.yearGanYinYang: result};
    });
  }

  /// 只计算传统内外卦纳甲方案
  Future<void> calculateInnerOuterGua() async {
    if (_selectedEightChars == null) {
      return;
    }

    await _safeExecuteSingleMethod(() async {
      final params = TaiXuanFourZhuUseCaseParams(
        eightChars: _selectedEightChars!,
      );
      final result = await _useCase.execute(
        params,
        naJiaMethod: TaiXuanNaJiaMethod.innerOuterGua,
      );
      return {TaiXuanNaJiaMethod.innerOuterGua: result};
    });
  }

  /// 刷新
  Future<void> refresh() async {
    await calculateBothMethods();
  }

  /// 清除选择的八字
  void clearSelection() {
    _selectedEightChars = null;
    reset();
  }

  /// 重置状态
  void reset() {
    _state = TiaoWenListState.initial;
    _yearGanYinYangResult = null;
    _innerOuterGuaResult = null;
    _yearGanYinYangUIModel = null;
    _innerOuterGuaUIModel = null;
    _errorMessage = null;
    _lastException = null;
    notifyListeners();
  }

  // ==================== 内部辅助方法 ====================

  /// 安全执行双方案计算
  @protected
  Future<void> _safeExecuteBothMethods(
    Future<Map<TaiXuanNaJiaMethod, MultiBaseNumberResult>> Function() operation,
  ) async {
    try {
      _state = TiaoWenListState.loading;
      _errorMessage = null;
      _lastException = null;
      notifyListeners();

      final results = await operation();

      // 处理年干阴阳纳甲结果
      final yearGanResult = results[TaiXuanNaJiaMethod.yearGanYinYang];
      if (yearGanResult != null) {
        _yearGanYinYangResult = yearGanResult;
        if (yearGanResult.isSuccess) {
          _yearGanYinYangUIModel = UITiaoWenListResultModel.fromMultiBaseNumberResult(yearGanResult);
        }
      }

      // 处理传统内外卦纳甲结果
      final innerOuterResult = results[TaiXuanNaJiaMethod.innerOuterGua];
      if (innerOuterResult != null) {
        _innerOuterGuaResult = innerOuterResult;
        if (innerOuterResult.isSuccess) {
          _innerOuterGuaUIModel = UITiaoWenListResultModel.fromMultiBaseNumberResult(innerOuterResult);
        }
      }

      // 检查是否至少有一个成功
      final hasAnySuccess = (yearGanResult?.isSuccess ?? false) || (innerOuterResult?.isSuccess ?? false);

      if (hasAnySuccess) {
        _state = TiaoWenListState.success;
      } else {
        _state = TiaoWenListState.error;
        _errorMessage = '所有纳甲方案计算失败';
      }

      notifyListeners();
    } on TiaoWenCalculationException catch (e) {
      _state = TiaoWenListState.error;
      _lastException = e;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    } catch (e) {
      _state = TiaoWenListState.error;
      final wrappedException = UseCaseExecutionException(
        useCaseName: name,
        message: '执行过程中发生未知错误：${e.toString()}',
        originalException: e,
      );
      _lastException = wrappedException;
      _errorMessage = _getErrorMessage(wrappedException);
      notifyListeners();
    }
  }

  /// 安全执行单方案计算
  @protected
  Future<void> _safeExecuteSingleMethod(
    Future<Map<TaiXuanNaJiaMethod, MultiBaseNumberResult>> Function() operation,
  ) async {
    try {
      _state = TiaoWenListState.loading;
      _errorMessage = null;
      notifyListeners();

      final results = await operation();

      // 处理结果
      if (results.containsKey(TaiXuanNaJiaMethod.yearGanYinYang)) {
        final result = results[TaiXuanNaJiaMethod.yearGanYinYang]!;
        _yearGanYinYangResult = result;
        if (result.isSuccess) {
          _yearGanYinYangUIModel = UITiaoWenListResultModel.fromMultiBaseNumberResult(result);
          _state = TiaoWenListState.success;
        } else {
          _state = TiaoWenListState.error;
          _errorMessage = result.errorMessage ?? '年干阴阳纳甲计算失败';
        }
      } else if (results.containsKey(TaiXuanNaJiaMethod.innerOuterGua)) {
        final result = results[TaiXuanNaJiaMethod.innerOuterGua]!;
        _innerOuterGuaResult = result;
        if (result.isSuccess) {
          _innerOuterGuaUIModel = UITiaoWenListResultModel.fromMultiBaseNumberResult(result);
          _state = TiaoWenListState.success;
        } else {
          _state = TiaoWenListState.error;
          _errorMessage = result.errorMessage ?? '传统内外卦纳甲计算失败';
        }
      }

      notifyListeners();
    } on TiaoWenCalculationException catch (e) {
      _state = TiaoWenListState.error;
      _lastException = e;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    } catch (e) {
      _state = TiaoWenListState.error;
      final wrappedException = UseCaseExecutionException(
        useCaseName: name,
        message: '执行过程中发生未知错误：${e.toString()}',
        originalException: e,
      );
      _lastException = wrappedException;
      _errorMessage = _getErrorMessage(wrappedException);
      notifyListeners();
    }
  }

  /// 获取用户友好的错误消息
  String _getErrorMessage(TiaoWenCalculationException exception) {
    return switch (exception) {
      InputValidationException() => '输入参数错误：${exception.parameterName} - ${exception.message}',
      StrategyCalculationException() => '计算策略错误：${exception.strategyName} - ${exception.message}',
      UseCaseExecutionException() => '业务逻辑执行错误：${exception.useCaseName} - ${exception.message}',
      _ => '未知错误：${exception.message}',
    };
  }

  // ==================== 统计信息 ====================

  /// 是否有任何结果
  bool get hasAnyResult => hasYearGanYinYangResult || hasInnerOuterGuaResult;

  /// 总条文数量
  int get totalTiaoWenCount {
    int count = 0;
    if (hasYearGanYinYangResult) {
      count += _yearGanYinYangUIModel?.tiaoWenCount ?? 0;
    }
    if (hasInnerOuterGuaResult) {
      count += _innerOuterGuaUIModel?.tiaoWenCount ?? 0;
    }
    return count;
  }

  /// 年干阴阳纳甲条文数量
  int get yearGanYinYangTiaoWenCount => _yearGanYinYangUIModel?.tiaoWenCount ?? 0;

  /// 传统内外卦纳甲条文数量
  int get innerOuterGuaTiaoWenCount => _innerOuterGuaUIModel?.tiaoWenCount ?? 0;

  @override
  void dispose() {
    _selectedEightChars = null;
    _yearGanYinYangResult = null;
    _innerOuterGuaResult = null;
    _yearGanYinYangUIModel = null;
    _innerOuterGuaUIModel = null;
    super.dispose();
  }

  @override
  String toString() {
    return 'TaiXuanFourZhuViewModel('
        'selectedEightChars: $_selectedEightChars, '
        'hasSelection: $hasSelection, '
        'state: $state, '
        'hasYearGanYinYangResult: $hasYearGanYinYangResult, '
        'hasInnerOuterGuaResult: $hasInnerOuterGuaResult, '
        'totalTiaoWenCount: $totalTiaoWenCount'
        ')';
  }
}
