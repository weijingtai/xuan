/// 多基础数选择UI组件
///
/// 支持同时选择多个基础数的用户界面
library;

import 'package:flutter/material.dart';
import '../../domain/models/multi_base_number_selection.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import 'candidate_selection_widget.dart';

/// 多基础数选择主组件
class MultiBaseNumberSelectionWidget extends StatelessWidget {
  /// 选择管理器
  final MultiBaseNumberSelectionManager manager;

  /// 选择回调
  final Function(BaseNumberSelectionType type, TiaoWenCandidate candidate)
  onSelectionChanged;

  /// 是否显示详细信息
  final bool showDetails;

  /// 是否启用动画
  final bool enableAnimations;

  const MultiBaseNumberSelectionWidget({
    super.key,
    required this.manager,
    required this.onSelectionChanged,
    this.showDetails = true,
    this.enableAnimations = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 阶段指示器
        _buildPhaseIndicator(context),

        const SizedBox(height: 16),

        // 当前阶段的选择内容
        _buildCurrentPhaseContent(context),

        if (showDetails) ...[
          const SizedBox(height: 24),

          // 选择进度概览
          _buildSelectionOverview(context),
        ],
      ],
    );
  }

  /// 构建阶段指示器
  Widget _buildPhaseIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            _getPhaseIcon(manager.currentPhase),
            color: theme.colorScheme.primary,
            size: 24,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPhaseTitle(manager.currentPhase),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _getPhaseDescription(manager.currentPhase),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // 进度指示
          _buildProgressIndicator(context),
        ],
      ),
    );
  }

  /// 构建当前阶段内容
  Widget _buildCurrentPhaseContent(BuildContext context) {
    final currentSelections = manager.currentPhaseSelections;

    if (currentSelections.isEmpty) {
      return _buildCompletedContent(context);
    }

    return Column(
      children: currentSelections.map((selection) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildSelectionCard(context, selection),
        );
      }).toList(),
    );
  }

  /// 构建单个选择卡片
  Widget _buildSelectionCard(
    BuildContext context,
    BaseNumberSelection selection,
  ) {
    final theme = Theme.of(context);
    final isActive = manager.currentActiveType == selection.type;

    return AnimatedContainer(
      duration: enableAnimations
          ? const Duration(milliseconds: 300)
          : Duration.zero,
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 选择标题和状态
          _buildSelectionHeader(context, selection, isActive),

          // 选择内容
          if (selection.canSelect) ...[
            const Divider(height: 1),
            _buildSelectionContent(context, selection),
          ] else if (selection.isCompleted) ...[
            const Divider(height: 1),
            _buildCompletedSelection(context, selection),
          ] else if (selection.status == BaseNumberSelectionStatus.loading) ...[
            const Divider(height: 1),
            _buildLoadingContent(context),
          ] else if (selection.status == BaseNumberSelectionStatus.error) ...[
            const Divider(height: 1),
            _buildErrorContent(context, selection.errorMessage),
          ] else if (selection.isWaitingForDependency) ...[
            const Divider(height: 1),
            _buildWaitingContent(context, selection),
          ],
        ],
      ),
    );
  }

  /// 构建选择标题
  Widget _buildSelectionHeader(
    BuildContext context,
    BaseNumberSelection selection,
    bool isActive,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 状态图标
          _buildStatusIcon(context, selection.status),

          const SizedBox(width: 12),

          // 标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selection.type.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isActive ? theme.colorScheme.primary : null,
                  ),
                ),

                if (selection.dependsOn != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '基于 ${selection.dependsOn!.displayName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 必需标识
          if (selection.isRequired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '必需',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建选择内容
  Widget _buildSelectionContent(
    BuildContext context,
    BaseNumberSelection selection,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CandidateSelectionWidget(
        candidates: selection.candidates,
        onCandidateSelected: (candidate) {
          onSelectionChanged(selection.type, candidate);
        },
        isLoading: false,
        // showAnimation: enableAnimations,
      ),
    );
  }

  /// 构建已完成选择
  Widget _buildCompletedSelection(
    BuildContext context,
    BaseNumberSelection selection,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 20,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                '已选择: ${selection.selectedNumber?.number}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建等待内容
  Widget _buildWaitingContent(
    BuildContext context,
    BaseNumberSelection selection,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                '等待 ${selection.dependsOn?.displayName} 选择完成',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建加载内容
  Widget _buildLoadingContent(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '正在生成候选项...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建错误内容
  Widget _buildErrorContent(BuildContext context, String? errorMessage) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: theme.colorScheme.error, size: 20),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                errorMessage ?? '发生未知错误',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建完成内容
  Widget _buildCompletedContent(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: theme.colorScheme.primary,
            size: 48,
          ),

          const SizedBox(height: 16),

          Text(
            '所有基础数选择已完成',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '您可以继续进行下一步操作',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建选择概览
  Widget _buildSelectionOverview(BuildContext context) {
    final theme = Theme.of(context);
    final completedSelections = manager.completedSelections;

    if (completedSelections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '已完成的选择',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...completedSelections.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    '${entry.key.displayName}: ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '${entry.value.number}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 构建进度指示器
  Widget _buildProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final totalSelections = manager.selections.length;
    final completedCount = manager.completedSelections.length;
    final progress = totalSelections > 0
        ? completedCount / totalSelections
        : 0.0;

    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          '$completedCount/$totalSelections',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 构建状态图标
  Widget _buildStatusIcon(
    BuildContext context,
    BaseNumberSelectionStatus status,
  ) {
    final theme = Theme.of(context);

    switch (status) {
      case BaseNumberSelectionStatus.pending:
        return Icon(
          Icons.radio_button_unchecked,
          color: theme.colorScheme.outline,
          size: 20,
        );
      case BaseNumberSelectionStatus.waitingForDependency:
        return Icon(
          Icons.schedule,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        );
      case BaseNumberSelectionStatus.ready:
        return Icon(
          Icons.radio_button_unchecked,
          color: theme.colorScheme.primary,
          size: 20,
        );
      case BaseNumberSelectionStatus.loading:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        );
      case BaseNumberSelectionStatus.completed:
        return Icon(
          Icons.check_circle,
          color: theme.colorScheme.primary,
          size: 20,
        );
      case BaseNumberSelectionStatus.error:
        return Icon(Icons.error, color: theme.colorScheme.error, size: 20);
    }
  }

  /// 获取阶段图标
  IconData _getPhaseIcon(SelectionPhase phase) {
    switch (phase) {
      case SelectionPhase.primaryNumbers:
        return Icons.looks_one;
      case SelectionPhase.derivedNumbers:
        return Icons.looks_two;
      case SelectionPhase.completed:
        return Icons.check_circle;
    }
  }

  /// 获取阶段标题
  String _getPhaseTitle(SelectionPhase phase) {
    switch (phase) {
      case SelectionPhase.primaryNumbers:
        return '第一阶段：主基础数选择';
      case SelectionPhase.derivedNumbers:
        return '第二阶段：派生基础数选择';
      case SelectionPhase.completed:
        return '选择完成';
    }
  }

  /// 获取阶段描述
  String _getPhaseDescription(SelectionPhase phase) {
    switch (phase) {
      case SelectionPhase.primaryNumbers:
        return '请选择元会基础数和运世基础数';
      case SelectionPhase.derivedNumbers:
        return '基于已选择的主基础数，选择派生基础数';
      case SelectionPhase.completed:
        return '所有基础数选择已完成，可以继续下一步';
    }
  }
}
