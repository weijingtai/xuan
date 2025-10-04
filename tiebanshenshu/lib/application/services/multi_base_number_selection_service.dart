/// 多基础数选择服务
///
/// 职责：
/// - 创建并维护 `MultiBaseNumberSelectionManager`，用于管理多个基础数选择的生命周期与状态
/// - 基于 `YuanHuiYunShi` 生成主基础数（元会/运世）的候选项
/// - 在主基础数选定后，按依赖关系初始化并生成派生基础数的候选项
/// - 处理主/派生基础数的选择事件，更新选择状态并推进流程阶段
/// - 通过 `CandidateGenerationService` 访问 `TiaoWenRepository`，为候选项补充条文内容
///
/// 典型流程：
/// 1. `createSelectionManager` 创建管理器并声明必选/可选类型
/// 2. `initializePrimarySelections` 生成主基础数候选项（围绕合并数±调整）
/// 3. `selectPrimaryNumber` 用户选定主类型后，若主阶段完成则调用 `_initializeDerivedSelections`
/// 4. `selectDerivedNumber` 用户选定派生类型，完成后更新状态
///
/// 注意：
/// - 候选生成会查询条文仓库，若条文缺失或获取失败，仍会提供占位描述
/// - 派生生成严格依赖父类型选中，未满足依赖时置为 `waitingForDependency`
library;

import 'package:flutter/foundation.dart';
import '../../domain/models/multi_base_number_selection.dart';
import '../../domain/models/huang_ji_number.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../../domain/models/yuan_hui_yun_shi.dart';
import 'candidate_generation_service.dart';

/// 多基础数选择服务
class MultiBaseNumberSelectionService {
  final CandidateGenerationService _candidateService;

  MultiBaseNumberSelectionService(this._candidateService);

  /// 获取候选项生成服务
  CandidateGenerationService get _candidateGenerationService =>
      _candidateService;

  /// 创建多基础数选择管理器
  ///
  /// 入参：
  /// - `requiredTypes` 必选的基础数类型集合
  /// - `optionalTypes` 可选的基础数类型集合（默认空）
  /// 返回：初始化后的 `MultiBaseNumberSelectionManager`
  /// 副作用：调试模式下打印类型信息
  MultiBaseNumberSelectionManager createSelectionManager({
    required List<BaseNumberSelectionType> requiredTypes,
    List<BaseNumberSelectionType> optionalTypes = const [],
  }) {
    if (kDebugMode) {
      print('🚀 创建多基础数选择管理器');
      print('📊 必需类型: ${requiredTypes.map((t) => t.displayName).join(', ')}');
      print('📊 可选类型: ${optionalTypes.map((t) => t.displayName).join(', ')}');
    }

    return MultiBaseNumberSelectionManager.create(
      requiredTypes: requiredTypes,
      optionalTypes: optionalTypes,
    );
  }

  /// 初始化主基础数的候选项
  ///
  /// 入参：
  /// - `manager` 已创建的选择管理器
  /// - `yuanHuiYunShi` 包含元会/运世合并数的模型
  /// 行为：
  /// - 遍历所有主类型，基于合并数生成围绕±30/60/90的候选项
  /// - 通过仓库获取条文内容，填充候选的展示/描述
  /// - 成功置为 `ready`，失败置为 `error` 并写入错误信息
  /// 返回：更新后的管理器
  Future<MultiBaseNumberSelectionManager> initializePrimarySelections(
    MultiBaseNumberSelectionManager manager,
    YuanHuiYunShi yuanHuiYunShi,
  ) async {
    if (kDebugMode) {
      print('🔄 初始化主基础数候选项');
    }

    MultiBaseNumberSelectionManager updatedManager = manager;

    // 为每个主基础数生成候选项
    for (final selection in manager.primarySelections) {
      try {
        final candidates = await _generatePrimaryCandidates(
          selection.type,
          yuanHuiYunShi,
        );

        final updatedSelection = selection.copyWith(
          candidates: candidates,
          status: BaseNumberSelectionStatus.ready,
        );

        updatedManager = updatedManager.updateSelection(
          selection.type,
          updatedSelection,
        );

        if (kDebugMode) {
          print(
            '✅ ${selection.type.displayName} 候选项生成完成: ${candidates.length}个',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ ${selection.type.displayName} 候选项生成失败: $e');
        }

        final errorSelection = selection.copyWith(
          status: BaseNumberSelectionStatus.error,
          errorMessage: '候选项生成失败: $e',
        );

        updatedManager = updatedManager.updateSelection(
          selection.type,
          errorSelection,
        );
      }
    }

    return updatedManager;
  }

  /// 处理主基础数选择
  ///
  /// 入参：
  /// - `manager` 当前选择管理器
  /// - `type` 主类型（如：元会/运世）
  /// - `selectedCandidate` 用户选中的候选项
  /// 行为：
  /// - 将候选项封装为 `HuangJiBaseNumber` 并标记该选择为完成
  /// - 若所有主类型完成，初始化派生类型的候选项
  /// 返回：更新后的管理器
  Future<MultiBaseNumberSelectionManager> selectPrimaryNumber(
    MultiBaseNumberSelectionManager manager,
    BaseNumberSelectionType type,
    TiaoWenCandidate selectedCandidate,
  ) async {
    if (kDebugMode) {
      print('🎯 选择主基础数: ${type.displayName}');
      print('📊 选择的候选项: ${selectedCandidate.description}');
    }

    final selection = manager.getSelection(type);
    if (selection == null) {
      throw ArgumentError('选择类型不存在: $type');
    }

    // 创建基础数对象
    final baseNumber = HuangJiBaseNumber(
      name: type.displayName,
      description: selectedCandidate.description,
      orinialNumber: selectedCandidate.value,
      baseNumberType: _getBaseNumberType(type),
      numberSource: _getNumberSource(type),
    );

    // 更新选择状态
    final updatedSelection = selection.copyWith(
      selectedNumber: baseNumber,
      status: BaseNumberSelectionStatus.completed,
    );

    var updatedManager = manager.updateSelection(type, updatedSelection);

    // 如果主基础数阶段完成，初始化派生基础数
    if (updatedManager.isPrimaryPhaseCompleted) {
      updatedManager = await _initializeDerivedSelections(updatedManager);
    }

    return updatedManager;
  }

  /// 处理派生基础数选择
  ///
  /// 入参：同上，但 `type` 为派生类型（如：元会一、运世二）
  /// 行为：封装为 `HuangJiBaseNumber`，标记该派生选择完成
  /// 返回：更新后的管理器
  Future<MultiBaseNumberSelectionManager> selectDerivedNumber(
    MultiBaseNumberSelectionManager manager,
    BaseNumberSelectionType type,
    TiaoWenCandidate selectedCandidate,
  ) async {
    if (kDebugMode) {
      print('🎯 选择派生基础数: ${type.displayName}');
      print('📊 选择的候选项: ${selectedCandidate.description}');
    }

    final selection = manager.getSelection(type);
    if (selection == null) {
      throw ArgumentError('选择类型不存在: $type');
    }

    // 创建基础数对象
    final baseNumber = HuangJiBaseNumber(
      name: type.displayName, // 使用选择类型的显示名称
      description: selectedCandidate.description, // 使用候选项的描述
      orinialNumber: selectedCandidate.value, // 使用候选项的数值
      baseNumberType: _getBaseNumberType(type), // 通过辅助方法获取基础数类型
      numberSource: _getNumberSource(type), // 通过辅助方法获取数字来源
    );

    // 更新选择状态
    final updatedSelection = selection.copyWith(
      selectedNumber: baseNumber,
      status: BaseNumberSelectionStatus.completed,
    );

    return manager.updateSelection(type, updatedSelection);
  }

  /// 生成主基础数候选项
  ///
  /// 根据类型分发到具体生成函数：
  /// - `yuanHui` → `_generateYuanHuiCandidates`
  /// - `yunShi` → `_generateYunShiCandidates`
  Future<List<TiaoWenCandidate>> _generatePrimaryCandidates(
    BaseNumberSelectionType type,
    YuanHuiYunShi yuanHuiYunShi,
  ) async {
    switch (type) {
      case BaseNumberSelectionType.yuanHui:
        return _generateYuanHuiCandidates(yuanHuiYunShi);
      case BaseNumberSelectionType.yunShi:
        return _generateYunShiCandidates(yuanHuiYunShi);
      default:
        throw ArgumentError('不支持的主基础数类型: $type');
    }
  }

  /// 生成元会基础数候选项
  ///
  /// 行为：读取 `yuanHuiMergeNumber`，围绕其±调整生成候选项并填充条文内容
  Future<List<TiaoWenCandidate>> _generateYuanHuiCandidates(
    YuanHuiYunShi yuanHuiYunShi,
  ) async {
    final baseNumber = yuanHuiYunShi.yuanHuiMergeNumber.number;
    return _generateCandidatesAroundNumber(baseNumber, '元会基础数');
  }

  /// 生成运世基础数候选项
  ///
  /// 行为：读取 `yunShiMergeNumber`，围绕其±调整生成候选项并填充条文内容
  Future<List<TiaoWenCandidate>> _generateYunShiCandidates(
    YuanHuiYunShi yuanHuiYunShi,
  ) async {
    final baseNumber = yuanHuiYunShi.yunShiMergeNumber.number;
    return _generateCandidatesAroundNumber(baseNumber, '运世基础数');
  }

  /// 在指定数字周围生成候选项
  ///
  /// 入参：`baseNumber` 基础数、`prefix` 展示前缀（类型名）
  /// 行为：生成 [-90, -60, -30, 0, 30, 60, 90] 调整列表，对每个数：
  /// - 查询条文仓库补充 `displayName/description`
  /// - 构造 `TiaoWenCandidate`，附带元数据（原始数、调整值、类型、条文编号）
  /// 容错：仓库获取失败或未找到内容时提供占位描述，不中断生成
  /// 返回：候选项列表
  Future<List<TiaoWenCandidate>> _generateCandidatesAroundNumber(
    int baseNumber,
    String prefix,
  ) async {
    final List<TiaoWenCandidate> candidates = [];

    // 生成 ±30, ±60, ±90 的候选项
    final adjustments = [-90, -60, -30, 0, 30, 60, 90];

    for (final adjustment in adjustments) {
      final number = baseNumber + adjustment;
      final adjustmentText = adjustment == 0
          ? ''
          : adjustment > 0
          ? '+$adjustment'
          : '$adjustment';

      // 尝试获取条文内容
      String displayName;
      String description;

      try {
        final tiaoWen = await _candidateGenerationService.tiaoWenRepository
            .getById(number);
        if (tiaoWen != null) {
          // 使用真实的条文内容
          displayName = '条文$number: ${tiaoWen.content1}';
          description = adjustment == 0
              ? '原始$prefix (条文$number)'
              : '$prefix 调整$adjustmentText (条文$number)';

          // 如果有第二部分内容，添加到描述中
          if (tiaoWen.content2 != null && tiaoWen.content2!.isNotEmpty) {
            description += '\n${tiaoWen.content2}';
          }
        } else {
          // 如果没有找到条文数据，使用默认格式
          displayName = '条文$number (未找到内容)';
          description = adjustment == 0
              ? '原始$prefix (条文$number)'
              : '$prefix 调整$adjustmentText (条文$number)';
        }
      } catch (e) {
        // 如果获取条文失败，使用默认格式
        displayName = '条文$number (获取失败)';
        description = adjustment == 0
            ? '原始$prefix (条文$number)'
            : '$prefix 调整$adjustmentText (条文$number)';
      }

      candidates.add(
        TiaoWenCandidate(
          id: '${prefix}_${number}',
          displayName: displayName,
          description: description,
          isEnabled: true,
          metadata: {
            'baseNumber': baseNumber,
            'adjustment': adjustment,
            'type': prefix,
            'tiaoWenNumber': number,
          },
          type: TiaoWenCandidateType.baseNumber,
          value: number,
        ),
      );
    }

    return candidates;
  }

  /// 初始化派生基础数选择
  ///
  /// 行为：
  /// - 遍历所有派生选择，若依赖父类型未完成置为 `waitingForDependency`
  /// - 若依赖满足，则以父类型的选中数为中心生成候选并置为 `ready`
  /// - 异常时置为 `error` 并记录错误信息
  /// 返回：更新后的管理器
  Future<MultiBaseNumberSelectionManager> _initializeDerivedSelections(
    MultiBaseNumberSelectionManager manager,
  ) async {
    if (kDebugMode) {
      print('🔄 初始化派生基础数选择');
    }

    MultiBaseNumberSelectionManager updatedManager = manager;

    for (final selection in manager.derivedSelections) {
      try {
        // 检查依赖是否满足
        final parentType = selection.dependsOn;
        if (parentType != null) {
          final parentSelection = manager.getSelection(parentType);
          if (parentSelection?.isCompleted != true) {
            // 依赖未满足，设置为等待状态
            final waitingSelection = selection.copyWith(
              status: BaseNumberSelectionStatus.waitingForDependency,
            );
            updatedManager = updatedManager.updateSelection(
              selection.type,
              waitingSelection,
            );
            continue;
          }

          // 基于父基础数生成候选项
          final parentNumber = parentSelection!.selectedNumber!.orinialNumber;
          final candidates = await _generateDerivedCandidates(
            selection.type,
            parentNumber,
          );

          final readySelection = selection.copyWith(
            candidates: candidates,
            status: BaseNumberSelectionStatus.ready,
          );

          updatedManager = updatedManager.updateSelection(
            selection.type,
            readySelection,
          );

          if (kDebugMode) {
            print(
              '✅ ${selection.type.displayName} 候选项生成完成: ${candidates.length}个',
            );
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ ${selection.type.displayName} 候选项生成失败: $e');
        }

        final errorSelection = selection.copyWith(
          status: BaseNumberSelectionStatus.error,
          errorMessage: '候选项生成失败: $e',
        );

        updatedManager = updatedManager.updateSelection(
          selection.type,
          errorSelection,
        );
      }
    }

    return updatedManager;
  }

  /// 生成派生基础数候选项
  ///
  /// 行为：以 `parentNumber` 为中心生成围绕±调整的候选，`prefix` 使用类型显示名
  Future<List<TiaoWenCandidate>> _generateDerivedCandidates(
    BaseNumberSelectionType type,
    int parentNumber,
  ) async {
    final prefix = type.displayName;
    return _generateCandidatesAroundNumber(parentNumber, prefix);
  }

  /// 获取基础数类型
  ///
  /// 皇极场景中所有选择类型均为 `BaseNumberType.tiaoWen`
  BaseNumberType _getBaseNumberType(BaseNumberSelectionType selectionType) {
    switch (selectionType) {
      case BaseNumberSelectionType.yuanHui:
      case BaseNumberSelectionType.yuanHuiOne:
      case BaseNumberSelectionType.yuanHuiTwo:
        return BaseNumberType.tiaoWen;
      case BaseNumberSelectionType.yunShi:
      case BaseNumberSelectionType.yunShiOne:
      case BaseNumberSelectionType.yunShiTwo:
        return BaseNumberType.tiaoWen;
    }
  }

  /// 获取数字来源
  ///
  /// 将选择类型映射到 `NumberSource.yuanHui | yunShi`
  NumberSource _getNumberSource(BaseNumberSelectionType selectionType) {
    switch (selectionType) {
      case BaseNumberSelectionType.yuanHui:
      case BaseNumberSelectionType.yuanHuiOne:
      case BaseNumberSelectionType.yuanHuiTwo:
        return NumberSource.yuanHui;
      case BaseNumberSelectionType.yunShi:
      case BaseNumberSelectionType.yunShiOne:
      case BaseNumberSelectionType.yunShiTwo:
        return NumberSource.yunShi;
    }
  }
}
