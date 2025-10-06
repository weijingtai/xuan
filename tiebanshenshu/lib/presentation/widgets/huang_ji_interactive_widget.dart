/// 皇极交互主组件
///
/// 参考“多基础数选择”组件的布局与交互，封装当前步骤信息、
/// 候选项选择、以及选择进度与计算信息展示。
library;

import 'package:flutter/material.dart';

import '../../domain/models/huang_ji_interactive_step.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../viewmodels/huang_ji_interactive_view_model.dart';
import 'candidate_selection_widget.dart';

class HuangJiInteractiveWidget extends StatelessWidget {
  final HuangJiInteractiveViewModel provider;
  final Function(TiaoWenCandidate) onCandidateSelected;
  final bool showDetails;
  final bool enableAnimations;

  const HuangJiInteractiveWidget({
    super.key,
    required this.provider,
    required this.onCandidateSelected,
    this.showDetails = true,
    this.enableAnimations = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPhaseIndicator(context),

        const SizedBox(height: 16),

        _buildCurrentContent(context),

        if (showDetails) ...[
          const SizedBox(height: 24),
          _buildSelectionOverview(context),
        ],
      ],
    );
  }

  /// 阶段指示器（标题、描述、进度）
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
          Icon(_getPhaseIcon(provider.currentStep),
              color: theme.colorScheme.primary, size: 24),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.getCurrentStepDisplayText(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getPhaseDescription(provider.currentStep),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          _buildProgressIndicator(context),
        ],
      ),
    );
  }

  /// 当前阶段的主内容
  Widget _buildCurrentContent(BuildContext context) {
    if (provider.isCompleted) {
      return _buildCompletedContent(context);
    }

    if (provider.needsUserSelection) {
      return AnimatedContainer(
        duration: enableAnimations
            ? const Duration(milliseconds: 300)
            : Duration.zero,
        child: CandidateSelectionWidget(
          candidates: provider.currentCandidates,
          onCandidateSelected: (candidate) => onCandidateSelected(candidate),
          isLoading: provider.isProcessingSelection,
        ),
      );
    }

    if (provider.isLoading) {
      return _buildLoadingPlaceholder(context);
    }

    return _buildWaitingPlaceholder(context);
  }

  /// 选择概览与计算信息
  Widget _buildSelectionOverview(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline,
                  color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '计算信息',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCalculationInfo(context),
        ],
      ),
    );
  }

  /// 计算信息明细
  Widget _buildCalculationInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.initialNumber != null)
            _buildInfoRow(context, '初刻数', provider.initialNumber.toString()),
          if (provider.secondaryNumber != null) ...[
            const SizedBox(height: 4),
            _buildInfoRow(
                context, '次条文数', provider.secondaryNumber.toString()),
          ],
          if (provider.selectedBaseNumber != null) ...[
            const SizedBox(height: 4),
            _buildInfoRow(
                context, '选择的基础数', provider.selectedBaseNumber.toString()),
          ],
          if (provider.finalNumbers.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '最终条文数（预览）: ${provider.finalNumbers.join(', ')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  /// 进度指示器（线性）
  Widget _buildProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final value = _getProgressValue(provider.currentStep);
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          LinearProgressIndicator(
            value: value,
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(
            '${(value * 100).round()}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 完成占位（提示由页面负责展示结果组件）
  Widget _buildCompletedContent(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '计算已完成，可查看结果',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            _getLoadingMessage(),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_empty, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '正在准备皇极取数法计算...',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPhaseIcon(HuangJiInteractiveStep step) {
    switch (step) {
      case HuangJiInteractiveStep.initialization:
        return Icons.play_circle_fill;
      case HuangJiInteractiveStep.secondaryCalculation:
        return Icons.calculate;
      case HuangJiInteractiveStep.userSelection:
        return Icons.format_list_numbered;
      case HuangJiInteractiveStep.finalCalculation:
        return Icons.auto_awesome;
      case HuangJiInteractiveStep.completed:
        return Icons.check_circle;
    }
  }

  String _getPhaseDescription(HuangJiInteractiveStep step) {
    switch (step) {
      case HuangJiInteractiveStep.initialization:
        return '正在初始化皇极取数法计算，准备四柱数据...';
      case HuangJiInteractiveStep.secondaryCalculation:
        return '已完成初刻数计算，正在计算次条文数...';
      case HuangJiInteractiveStep.userSelection:
        return '请从下方候选项选择基础数以继续计算';
      case HuangJiInteractiveStep.finalCalculation:
        return '正在基于选择的基础数计算最终条文数列表...';
      case HuangJiInteractiveStep.completed:
        return '计算已完成，结果可在上方显示';
    }
  }

  double _getProgressValue(HuangJiInteractiveStep step) {
    switch (step) {
      case HuangJiInteractiveStep.initialization:
        return 0.15;
      case HuangJiInteractiveStep.secondaryCalculation:
        return 0.35;
      case HuangJiInteractiveStep.userSelection:
        return 0.6;
      case HuangJiInteractiveStep.finalCalculation:
        return 0.85;
      case HuangJiInteractiveStep.completed:
        return 1.0;
    }
  }

  String _getLoadingMessage() {
    if (provider.isStartingSession) {
      return '正在启动皇极取数法会话...';
    } else if (provider.isLoadingCandidates) {
      return '正在生成基础数选项...';
    } else if (provider.isProcessingSelection) {
      return '正在处理您的选择...';
    } else if (provider.isCalculating) {
      return '正在计算最终条文数...';
    }
    return '处理中...';
  }
}