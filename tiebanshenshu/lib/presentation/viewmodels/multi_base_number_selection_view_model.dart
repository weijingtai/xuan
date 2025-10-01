/// 多基础数选择ViewModel
///
/// 管理多基础数选择的UI状态和业务逻辑
library;

import 'package:flutter/foundation.dart';
import '../../domain/models/huang_ji_number.dart';
import '../../domain/models/multi_base_number_selection.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../../domain/models/yuan_hui_yun_shi.dart';
import '../../application/services/multi_base_number_selection_service.dart';

/// 多基础数选择状态
enum MultiSelectionViewState {
  /// 初始状态
  initial,

  /// 正在初始化
  initializing,

  /// 选择进行中
  selecting,

  /// 已完成
  completed,

  /// 出错
  error,
}

/// 多基础数选择ViewModel
class MultiBaseNumberSelectionViewModel extends ChangeNotifier {
  final MultiBaseNumberSelectionService _selectionService;

  // 状态管理
  MultiSelectionViewState _state = MultiSelectionViewState.initial;
  MultiBaseNumberSelectionManager? _selectionManager;
  String? _errorMessage;
  Exception? _lastException;

  // 配置
  List<BaseNumberSelectionType> _requiredTypes = [];
  List<BaseNumberSelectionType> _optionalTypes = [];
  YuanHuiYunShi? _yuanHuiYunShi;

  MultiBaseNumberSelectionViewModel(this._selectionService);

  // Getters
  MultiSelectionViewState get state => _state;
  MultiBaseNumberSelectionManager? get selectionManager => _selectionManager;
  String? get errorMessage => _errorMessage;
  Exception? get lastException => _lastException;

  /// 是否正在初始化
  bool get isInitializing => _state == MultiSelectionViewState.initializing;

  /// 是否正在选择
  bool get isSelecting => _state == MultiSelectionViewState.selecting;

  /// 是否已完成
  bool get isCompleted => _state == MultiSelectionViewState.completed;

  /// 是否有错误
  bool get hasError => _state == MultiSelectionViewState.error;

  /// 是否可以进行选择
  bool get canSelect => isSelecting && _selectionManager != null;

  /// 当前活跃的选择类型
  BaseNumberSelectionType? get currentActiveType =>
      _selectionManager?.currentActiveType;

  /// 当前阶段
  SelectionPhase? get currentPhase => _selectionManager?.currentPhase;

  /// 选择进度
  double get progress {
    if (_selectionManager == null) return 0.0;
    final total = _selectionManager!.selections.length;
    final completed = _selectionManager!.completedSelections.length;
    return total > 0 ? completed / total : 0.0;
  }

  /// 初始化多基础数选择
  Future<void> initialize({
    required List<BaseNumberSelectionType> requiredTypes,
    List<BaseNumberSelectionType> optionalTypes = const [],
    required YuanHuiYunShi yuanHuiYunShi,
  }) async {
    try {
      if (kDebugMode) {
        print('🚀 MultiBaseNumberSelectionViewModel: 开始初始化');
        print('📊 必需类型: ${requiredTypes.map((t) => t.displayName).join(', ')}');
        print('📊 可选类型: ${optionalTypes.map((t) => t.displayName).join(', ')}');
      }

      _setState(MultiSelectionViewState.initializing);
      _requiredTypes = requiredTypes;
      _optionalTypes = optionalTypes;
      _yuanHuiYunShi = yuanHuiYunShi;

      // 创建选择管理器
      _selectionManager = _selectionService.createSelectionManager(
        requiredTypes: requiredTypes,
        optionalTypes: optionalTypes,
      );

      // 初始化主基础数候选项
      _selectionManager = await _selectionService.initializePrimarySelections(
        _selectionManager!,
        yuanHuiYunShi,
      );

      _setState(MultiSelectionViewState.selecting);

      if (kDebugMode) {
        print('✅ MultiBaseNumberSelectionViewModel: 初始化完成');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ MultiBaseNumberSelectionViewModel: 初始化失败');
        print('❌ 错误: $e');
      }
      _handleError('初始化失败', e);
    }
  }

  /// 处理基础数选择
  Future<void> selectBaseNumber(
    BaseNumberSelectionType type,
    TiaoWenCandidate candidate,
  ) async {
    try {
      if (_selectionManager == null) {
        throw StateError('选择管理器未初始化');
      }

      if (kDebugMode) {
        print('🎯 MultiBaseNumberSelectionViewModel: 选择基础数');
        print('📊 类型: ${type.displayName}');
        print('📊 候选项: ${candidate.description}');
      }

      // 根据类型选择相应的处理方法
      if (type.isPrimary) {
        _selectionManager = await _selectionService.selectPrimaryNumber(
          _selectionManager!,
          type,
          candidate,
        );
      } else {
        _selectionManager = await _selectionService.selectDerivedNumber(
          _selectionManager!,
          type,
          candidate,
        );
      }

      // 检查是否完成
      if (_selectionManager!.isCompleted) {
        _setState(MultiSelectionViewState.completed);

        if (kDebugMode) {
          print('🎉 MultiBaseNumberSelectionViewModel: 所有选择已完成');
          print('📊 完成的选择: ${_selectionManager!.completedSelections}');
        }
      } else {
        notifyListeners();
      }

      if (kDebugMode) {
        print('✅ MultiBaseNumberSelectionViewModel: 选择处理完成');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ MultiBaseNumberSelectionViewModel: 选择处理失败');
        print('❌ 错误: $e');
      }
      _handleError('选择处理失败', e);
    }
  }

  /// 重置选择
  Future<void> reset() async {
    try {
      if (kDebugMode) {
        print('🔄 MultiBaseNumberSelectionViewModel: 重置选择');
      }

      _selectionManager = null;
      _setState(MultiSelectionViewState.initial);

      if (kDebugMode) {
        print('✅ MultiBaseNumberSelectionViewModel: 重置完成');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ MultiBaseNumberSelectionViewModel: 重置失败');
        print('❌ 错误: $e');
      }
      _handleError('重置失败', e);
    }
  }

  /// 重新初始化（保持当前配置）
  Future<void> reinitialize() async {
    if (_yuanHuiYunShi != null) {
      await initialize(
        requiredTypes: _requiredTypes,
        optionalTypes: _optionalTypes,
        yuanHuiYunShi: _yuanHuiYunShi!,
      );
    }
  }

  /// 获取指定类型的选择状态
  BaseNumberSelection? getSelection(BaseNumberSelectionType type) {
    return _selectionManager?.getSelection(type);
  }

  /// 获取已完成的选择结果
  Map<BaseNumberSelectionType, HuangJiBaseNumber> get completedSelections {
    return _selectionManager?.completedSelections ?? {};
  }

  /// 获取当前阶段的选择
  List<BaseNumberSelection> get currentPhaseSelections {
    return _selectionManager?.currentPhaseSelections ?? [];
  }

  /// 获取主基础数选择
  List<BaseNumberSelection> get primarySelections {
    return _selectionManager?.primarySelections ?? [];
  }

  /// 获取派生基础数选择
  List<BaseNumberSelection> get derivedSelections {
    return _selectionManager?.derivedSelections ?? [];
  }

  /// 是否主基础数阶段已完成
  bool get isPrimaryPhaseCompleted {
    return _selectionManager?.isPrimaryPhaseCompleted ?? false;
  }

  /// 是否派生基础数阶段已完成
  bool get isDerivedPhaseCompleted {
    return _selectionManager?.isDerivedPhaseCompleted ?? false;
  }

  /// 设置状态
  void _setState(MultiSelectionViewState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// 处理错误
  void _handleError(String message, dynamic error) {
    _errorMessage = message;
    _lastException = error is Exception ? error : Exception(error.toString());
    _setState(MultiSelectionViewState.error);
  }

  /// 清除错误
  void clearError() {
    _errorMessage = null;
    _lastException = null;
    if (_state == MultiSelectionViewState.error) {
      _setState(MultiSelectionViewState.initial);
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('🗑️ MultiBaseNumberSelectionViewModel: 销毁');
    }
    super.dispose();
  }
}
