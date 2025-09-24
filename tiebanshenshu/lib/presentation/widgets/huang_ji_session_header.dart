/// 皇极取数法会话头部组件
///
/// 显示皇极取数法会话的基本信息和状态
library;

import 'package:flutter/material.dart';

import '../viewmodels/huang_ji_interactive_view_model.dart';

/// 皇极取数法会话头部组件
class HuangJiSessionHeader extends StatelessWidget {
  /// Provider实例
  final HuangJiInteractiveViewModel provider;

  const HuangJiSessionHeader({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 会话状态和四柱信息
          Row(
            children: [
              // 状态指示器
              _buildStatusIndicator(theme),

              const SizedBox(width: 12.0),

              // 四柱信息
              Expanded(child: _buildFourZhuInfo(theme)),
            ],
          ),

          if (provider.hasSession) ...[
            const SizedBox(height: 8.0),

            // 会话详细信息
            _buildSessionDetails(theme),
          ],
        ],
      ),
    );
  }

  /// 构建状态指示器
  Widget _buildStatusIndicator(ThemeData theme) {
    Color statusColor;
    IconData statusIcon;

    if (provider.isLoading) {
      statusColor = theme.colorScheme.primary;
      statusIcon = Icons.hourglass_empty;
    } else if (provider.hasError) {
      statusColor = theme.colorScheme.error;
      statusIcon = Icons.error_outline;
    } else if (provider.isCompleted) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else if (provider.isCancelled) {
      statusColor = theme.colorScheme.outline;
      statusIcon = Icons.cancel_outlined;
    } else {
      statusColor = theme.colorScheme.primary;
      statusIcon = Icons.play_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.0),
      ),
      child: Icon(statusIcon, color: statusColor, size: 20.0),
    );
  }

  /// 构建四柱信息
  Widget _buildFourZhuInfo(ThemeData theme) {
    final fourZhu = provider.inputEightChars;
    if (fourZhu == null) {
      return Text(
        '四柱信息未加载',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '皇极取数法',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4.0),

        Text(
          '${fourZhu.year.name} ${fourZhu.month.name} ${fourZhu.day.name} ${fourZhu.time.name}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  /// 构建会话详细信息
  Widget _buildSessionDetails(ThemeData theme) {
    return Row(
      children: [
        // 会话ID（简短显示）
        _buildDetailItem(
          theme,
          '会话',
          provider.currentSession!.sessionId.substring(0, 8),
          Icons.fingerprint,
        ),

        const SizedBox(width: 16.0),

        // 会话状态
        _buildDetailItem(
          theme,
          '状态',
          provider.getStateDisplayText(),
          Icons.info_outline,
        ),

        const SizedBox(width: 16.0),

        // 持续时间
        _buildDetailItem(
          theme,
          '时长',
          provider.getSessionDurationText(),
          Icons.access_time,
        ),
      ],
    );
  }

  /// 构建详细信息项
  Widget _buildDetailItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14.0,
          color: theme.colorScheme.onPrimaryContainer.withOpacity(0.6),
        ),

        const SizedBox(width: 4.0),

        Text(
          '$label: $value',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
