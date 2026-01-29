/// 交互式步骤指示器组件
///
/// 显示当前步骤进度和导航
library;

import 'package:flutter/material.dart';

import '../viewmodels/tai_xuan_four_zhu_interactive_view_model.dart';

/// 交互式步骤指示器组件
class InteractiveStepIndicator extends StatelessWidget {
  /// Provider实例
  final TaiXuanFourZhuInteractiveViewModel provider;

  const InteractiveStepIndicator({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = provider.currentSession!;

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
          if (session.steps.isNotEmpty) _buildStepList(theme),
        ],
      ),
    );
  }

  /// 构建进度条
  Widget _buildProgressBar(ThemeData theme) {
    return Column(
      children: [
        // 进度信息
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '进度',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            Text(
              provider.getStepProgressText(),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8.0),

        // 进度条
        LinearProgressIndicator(
          value: provider.sessionProgress,
          backgroundColor: theme.colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      ],
    );
  }

  /// 构建步骤列表
  Widget _buildStepList(ThemeData theme) {
    final session = provider.currentSession!;
    final steps = session.steps;
    final currentIndex = session.currentStepIndex;

    return SizedBox(
      height: 60.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          final isActive = index == currentIndex;
          final isCompleted = index < currentIndex;
          final isClickable = provider.canJump && index <= currentIndex;

          return GestureDetector(
            onTap: isClickable && !provider.isLoading
                ? () => _jumpToStep(index)
                : null,
            child: Container(
              width: 120.0,
              margin: const EdgeInsets.only(right: 8.0),
              child: _buildStepItem(
                theme,
                step.stepName,
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
    IconData? icon;

    if (isCompleted) {
      backgroundColor = theme.colorScheme.primary.withOpacity(0.1);
      textColor = theme.colorScheme.primary;
      borderColor = theme.colorScheme.primary;
      icon = Icons.check;
    } else if (isActive) {
      backgroundColor = theme.colorScheme.secondary.withOpacity(0.1);
      textColor = theme.colorScheme.secondary;
      borderColor = theme.colorScheme.secondary;
      icon = Icons.radio_button_checked;
    } else {
      backgroundColor = theme.colorScheme.surfaceVariant;
      textColor = theme.colorScheme.onSurface.withOpacity(0.6);
      borderColor = theme.colorScheme.outline.withOpacity(0.3);
      icon = Icons.radio_button_unchecked;
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
          // 步骤图标和编号
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, size: 16.0, color: textColor),
              const SizedBox(width: 4.0),
              Text(
                '$stepNumber',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4.0),

          // 步骤名称
          Text(
            stepName,
            style: theme.textTheme.bodySmall?.copyWith(color: textColor),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 跳转到指定步骤
  Future<void> _jumpToStep(int stepIndex) async {
    try {
      await provider.jumpToStep(stepIndex);
    } catch (e) {
      // 错误处理由Provider负责
    }
  }
}
