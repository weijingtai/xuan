import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter/material.dart';
import '../../constant/kao_ke_constants.dart';
import '../../domain/models/tiao_wen_result.dart';
import 'kao_ke_session_models.dart';
import 'kao_ke_use_case.dart';

/// 考刻ViewModel
///
/// 负责管理考刻功能的UI状态和用户交互
class KaoKeViewModel extends ChangeNotifier {
  final KaoKeUseCase _useCase;

  /// 当前会话
  KaoKeSession? _session;

  /// 加载状态
  bool _isLoading = false;

  /// 错误信息
  String? _error;

  /// 12时辰×8刻的完整数据
  Map<DiZhi, List<KaoEigthKeNumber>>? _keSelectionData;

  /// 斗甲乙宫刻数据（按出生时辰所属宫返回的四支 × 1-5）
  Map<DiZhi, List<DouJiaYiNumber>>? _douJiaYiSelectionData;

  KaoKeViewModel({
    required KaoKeUseCase useCase,
  }) : _useCase = useCase;

  // ==================== Getters ====================

  KaoKeSession? get session => _session;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<DiZhi, List<KaoEigthKeNumber>>? get keSelectionData => _keSelectionData;
  Map<DiZhi, List<DouJiaYiNumber>>? get douJiaYiSelectionData => _douJiaYiSelectionData;

  /// 当前阶段
  KaoKeSessionPhase? get currentPhase => _session?.currentPhase;

  /// 当前状态
  KaoKeSessionStatus? get status => _session?.status;

  /// 是否可以回滚
  bool get canRollback => _session?.canRollback ?? false;

  /// 是否已完成
  bool get isCompleted => _session?.isCompleted ?? false;

  /// 用户出生时辰
  DiZhi? get birthShiChen => _session?.birthShiChen;

  /// 已选择的刻记录（八刻）
  KeSelectionRecord? get keSelection => _session?.keSelection;

  /// 已选择的刻记录（斗甲乙宫）
  DouJiaYiSelectionRecord? get douJiaYiSelection => _session?.douJiaYiSelection;

  /// 卦象计算结果
  GuaCalculationResult? get guaResult => _session?.guaResult;

  /// 选择的计算方法
  Set<KaoKeCalculationMethod> get selectedMethods =>
      _session?.selectedMethods ?? {};

  /// 最终条文结果
  Map<KaoKeCalculationMethod, List<TiaoWenResult>>? get finalResults =>
      _session?.finalResults;

  // ==================== Actions ====================

  /// 初始化会话
  ///
  /// [eightChars] 用户八字
  /// [sessionName] 会话名称(可选)
  Future<void> initialize({
    required EightChars eightChars,
    String? sessionName,
  }) async {
    await _executeWithLoading(() async {
      // 创建并初始化会话
      _session = await _useCase.initializeSession(
        eightChars: eightChars,
        sessionName: sessionName,
      );

      // 加载刻选择数据（八刻）
      _keSelectionData = _useCase.prepareKeSelectionData();

      // 加载斗甲乙宫刻数据（按出生时辰所属宫）
      final birth = _session!.birthShiChen;
      _douJiaYiSelectionData =
          _useCase.prepareDouJiaYiSelectionDataForBirthShiChen(birth);
    });
  }

  /// 选择刻（八刻）
  ///
  /// [selectedKe] 用户选择的刻
  Future<void> selectKe(KaoEigthKeNumber selectedKe) async {
    if (_session == null) {
      _error = '会话未初始化';
      notifyListeners();
      return;
    }

    await _executeWithLoading(() async {
      // 提交选择
      _session = await _useCase.submitKeSelection(
        session: _session!,
        selectedKe: selectedKe,
      );

      // 自动计算卦象
      _session = await _useCase.calculateGua(_session!);
    });
  }

  /// 选择刻（斗甲乙宫：按条文编号提交）
  Future<void> selectDouJiaYiByNumber(int selectedTiaoWenNumber) async {
    if (_session == null) {
      _error = '会话未初始化';
      notifyListeners();
      return;
    }

    await _executeWithLoading(() async {
      // 提交斗甲乙宫选择
      _session = await _useCase.submitDouJiaYiSelection(
        session: _session!,
        selectedTiaoWenNumber: selectedTiaoWenNumber,
      );

      // 自动计算卦象（与八刻一致）
      _session = await _useCase.calculateGua(_session!);
    });
  }

  /// 切换计算方法
  ///
  /// [method] 要切换的计算方法
  Future<void> toggleCalculationMethod(
    KaoKeCalculationMethod method,
  ) async {
    if (_session == null) {
      _error = '会话未初始化';
      notifyListeners();
      return;
    }

    // 创建新的方法集合
    final newMethods = Set<KaoKeCalculationMethod>.from(selectedMethods);

    if (newMethods.contains(method)) {
      // 如果已存在,则移除(但至少保留一个)
      if (newMethods.length > 1) {
        newMethods.remove(method);
      } else {
        _error = '至少需要选择一个计算方法';
        notifyListeners();
        return;
      }
    } else {
      // 如果不存在,则添加
      newMethods.add(method);
    }

    await _executeWithLoading(() async {
      _session = await _useCase.updateCalculationMethods(
        session: _session!,
        methods: newMethods,
      );
    });
  }

  /// 计算最终结果
  Future<void> calculateFinalResults() async {
    if (_session == null) {
      _error = '会话未初始化';
      notifyListeners();
      return;
    }

    await _executeWithLoading(() async {
      _session = await _useCase.calculateFinalTiaoWen(_session!);
    });
  }

  /// 回滚到指定阶段
  ///
  /// [targetPhase] 目标阶段
  Future<void> rollbackToPhase(KaoKeSessionPhase targetPhase) async {
    if (_session == null) {
      _error = '会话未初始化';
      notifyListeners();
      return;
    }

    await _executeWithLoading(() async {
      _session = await _useCase.rollbackToPhase(
        session: _session!,
        targetPhase: targetPhase,
      );
    });
  }

  /// 回滚到上一阶段
  Future<void> rollbackToPrevious() async {
    if (_session == null) {
      _error = '会话未初始化';
      notifyListeners();
      return;
    }

    await _executeWithLoading(() async {
      _session = await _useCase.rollbackToPreviousPhase(_session!);
    });
  }

  /// 判断某个时辰是否为用户出生时辰
  ///
  /// [shiChen] 时辰
  bool isUserBirthShiChen(DiZhi shiChen) {
    return birthShiChen == shiChen;
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==================== Private Methods ====================

  /// 执行操作并管理加载状态
  Future<void> _executeWithLoading(Future<void> Function() action) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await action();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}
