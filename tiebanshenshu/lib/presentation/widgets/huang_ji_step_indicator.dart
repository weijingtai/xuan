/// 皇极取数法步骤指示器组件
///
/// 显示皇极取数法的当前步骤进度和导航
library;

import 'package:flutter/material.dart';

import '../../domain/models/huang_ji_interactive_step.dart';
import '../viewmodels/huang_ji_interactive_view_model.dart';

/// 皇极取数法步骤指示器组件
class HuangJiStepIndicator extends StatelessWidget {
  /// Provider实例
  final HuangJiInteractiveViewModel provider;

  const HuangJiStepIndicator({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 1.0),
        ),
      ),
      child: Column(
        children: [
          // 进度条
          _buildProgressBar(theme),

          const SizedBox(height: 12.0),

          // 步骤列表
          _buildStepList(theme),
        ],
      ),
    );
  }

  /// 构建进度条
  Widget _buildProgressBar(ThemeData theme) {
    final currentStepIndex = provider.currentStep.index;
    final totalSteps = HuangJiInteractiveStep.values.length;
    final progress = (currentStepIndex + 1) / totalSteps;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '步骤 ${currentStepIndex + 1} / $totalSteps',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),

            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8.0),

        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      ],
    );
  }

  /// 构建步骤列表
  Widget _buildStepList(ThemeData theme) {
    final currentStepIndex = provider.currentStep.index;

    return SizedBox(
      height: 60.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: HuangJiInteractiveStep.values.length,
        itemBuilder: (context, index) {
          final step = HuangJiInteractiveStep.values[index];
          final isActive = index == currentStepIndex;
          final isCompleted = index < currentStepIndex;
          final isClickable = provider.canJump && index <= currentStepIndex;

          return GestureDetector(
            onTap: isClickable && !provider.isLoading
                ? () => _jumpToStep(index)
                : null,
            child: Container(
              width: 120.0,
              margin: const EdgeInsets.only(right: 8.0),
              child: _buildStepItem(
                theme,
                step.name,
                index + 1,
                isActive,
                isCompleted,
                isClickable,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建步骤项
  Widget _buildStepItem(
    ThemeData theme,
    String stepName,
    int stepNumber,
    bool isActive,
    bool isCompleted,
    bool isClickable,
  ) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isCompleted) {
      backgroundColor = theme.colorScheme.primary.withOpacity(0.1);
      textColor = theme.colorScheme.primary;
      borderColor = theme.colorScheme.primary;
    } else if (isActive) {
      backgroundColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.onPrimaryContainer;
      borderColor = theme.colorScheme.primary;
    } else {
      backgroundColor = theme.colorScheme.surface;
      textColor = theme.colorScheme.onSurface.withOpacity(0.6);
      borderColor = theme.colorScheme.outline.withOpacity(0.3);
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 步骤编号或完成图标
          Container(
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              color: isCompleted
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: isCompleted
                  ? null
                  : Border.all(color: borderColor, width: 1.0),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16.0,
                      color: theme.colorScheme.onPrimary,
                    )
                  : Text(
                      stepNumber.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 2.0),

          // 步骤名称
          Text(
            stepName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 跳转到指定步骤
  void _jumpToStep(int stepIndex) {
    provider.jumpToStep(stepIndex);
  }
}
