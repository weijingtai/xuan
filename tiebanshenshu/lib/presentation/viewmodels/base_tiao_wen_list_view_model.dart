/// 条文列表ViewModel基类
///
/// 提供条文列表相关的通用状态管理功能
library;

import 'package:flutter/foundation.dart';
import '../../domain/models/tiao_wen_list_state.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../models/ui_tiao_wen_list_result_model.dart';

/// 条文列表ViewModel基类
///
/// 继承自ChangeNotifier，提供条文列表的状态管理功能
/// 所有具体的条文列表ViewModel都应该继承此基类
abstract class BaseTiaoWenListViewModel extends ChangeNotifier {
  /// ViewModel名称
  String get name;

  /// ViewModel描述
  String get description;

  // 私有状态变量
  TiaoWenListState _state = TiaoWenListState.initial;
  UITiaoWenListResultModel? _result;
  String? _errorMessage;
  TiaoWenCalculationException? _lastException;

  /// 当前状态
  TiaoWenListState get state => _state;

  /// UI计算结果模型
  UITiaoWenListResultModel? get result => _result;

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

  /// 是否有结果数据
  bool get hasResult => _result != null;

  /// 条文数量
  int get tiaoWenCount => _result?.tiaoWenCount ?? 0;

  /// 设置加载状态
  ///
  /// 将状态设置为加载中，清除之前的错误信息
  @protected
  void setLoading() {
    _state = TiaoWenListState.loading;
    _errorMessage = null;
    _lastException = null;
    notifyListeners();
  }

  /// 设置成功状态
  ///
  /// [domainResult] Domain层计算结果
  @protected
  void setSuccess(MultiBaseNumberResult domainResult) {
    _state = TiaoWenListState.success;
    _result = UITiaoWenListResultModel.fromMultiBaseNumberResult(domainResult);
    _errorMessage = null;
    _lastException = null;
    notifyListeners();
  }

  /// 设置错误状态
  ///
  /// [exception] 异常对象
  /// [customMessage] 自定义错误消息（可选）
  @protected
  void setError(
    TiaoWenCalculationException exception, [
    String? customMessage,
  ]) {
    _state = TiaoWenListState.error;
    _lastException = exception;
    _errorMessage = customMessage ?? _getErrorMessage(exception);
    notifyListeners();
  }

  /// 重置状态
  ///
  /// 将状态重置为初始状态，清除所有数据
  void reset() {
    _state = TiaoWenListState.initial;
    _result = null;
    _errorMessage = null;
    _lastException = null;
    notifyListeners();
  }

  /// 刷新数据
  ///
  /// 子类需要实现此方法来重新加载数据
  Future<void> refresh();

  /// 获取用户友好的错误消息
  ///
  /// [exception] 异常对象
  /// 返回用户友好的错误消息
  String _getErrorMessage(TiaoWenCalculationException exception) {
    switch (exception.runtimeType) {
      case InputValidationException:
        final inputException = exception as InputValidationException;
        return '输入参数错误：${inputException.parameterName} - ${inputException.message}';

      case StrategyCalculationException:
        final strategyException = exception as StrategyCalculationException;
        return '计算策略错误：${strategyException.strategyName} - ${strategyException.message}';

      case TiaoWenListCalculationException:
        final calculationException =
            exception as TiaoWenListCalculationException;
        return '条文列表计算错误：${calculationException.message}';

      case TiaoWenDataException:
        final dataException = exception as TiaoWenDataException;
        return '条文数据获取错误：${dataException.message}';

      case UseCaseExecutionException:
        final useCaseException = exception as UseCaseExecutionException;
        return '业务逻辑执行错误：${useCaseException.useCaseName} - ${useCaseException.message}';

      // 皇极取数法特有异常处理
      case HuangJiCalculationException:
        final huangJiException = exception as HuangJiCalculationException;
        return '皇极取数法计算错误：${huangJiException.calculationStep ?? '未知步骤'} - ${huangJiException.message}';

      case TaiXuanNumberCalculationException:
        final taiXuanException = exception as TaiXuanNumberCalculationException;
        return '太玄数计算错误：${taiXuanException.calculationType ?? '未知类型'} - ${taiXuanException.message}';

      case InitialNumberCalculationException:
        final initialException = exception as InitialNumberCalculationException;
        return '初刻数计算错误：${initialException.message}';

      case SecondaryNumberCalculationException:
        final secondaryException = exception as SecondaryNumberCalculationException;
        return '次条文数计算错误：${secondaryException.message}';

      case BaseNumberSelectionException:
        final selectionException = exception as BaseNumberSelectionException;
        return '基础数选择错误：${selectionException.message}';

      case FinalNumbersCalculationException:
        final finalException = exception as FinalNumbersCalculationException;
        return '最终条文数计算错误：${finalException.message}';

      case HuangJiInteractiveSessionException:
        final sessionException = exception as HuangJiInteractiveSessionException;
        return '交互式会话错误：${sessionException.message}';

      default:
        return '未知错误：${exception.message}';
    }
  }

  /// 安全执行异步操作
  ///
  /// [operation] 要执行的异步操作
  /// 自动处理加载状态和异常捕获
  @protected
  Future<void> safeExecute(
    Future<MultiBaseNumberResult> Function() operation,
  ) async {
    try {
      setLoading();
      final result = await operation();
      if (result.isSuccess) {
        setSuccess(result);
      } else {
        // 处理MultiBaseNumberResult中的错误
        final wrappedException = UseCaseExecutionException(
          useCaseName: name,
          message: result.errorMessage ?? '计算失败',
          originalException: null,
        );
        setError(wrappedException);
      }
    } on TiaoWenCalculationException catch (e) {
      setError(e);
    } catch (e) {
      // 包装未知异常
      final wrappedException = UseCaseExecutionException(
        useCaseName: name,
        message: '执行过程中发生未知错误：${e.toString()}',
        originalException: e,
      );
      setError(wrappedException);
    }
  }

  @override
  void dispose() {
    // 清理资源
    _result = null;
    _errorMessage = null;
    _lastException = null;
    super.dispose();
  }

  @override
  String toString() {
    return '$runtimeType('
        'name: $name, '
        'state: $state, '
        'hasResult: $hasResult, '
        'tiaoWenCount: $tiaoWenCount'
        ')';
  }
}
