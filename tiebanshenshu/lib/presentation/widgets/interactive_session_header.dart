/// 交互式会话头部组件
///
/// 显示会话基本信息和状态
library;

import 'package:flutter/material.dart';

import '../viewmodels/tai_xuan_four_zhu_interactive_view_model.dart';

/// 交互式会话头部组件
class InteractiveSessionHeader extends StatelessWidget {
  /// Provider实例
  final TaiXuanFourZhuInteractiveViewModel provider;

  const InteractiveSessionHeader({super.key, required this.provider});

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
          // 会话状态和八字信息
          Row(
            children: [
              // 状态指示器
              _buildStatusIndicator(theme),

              const SizedBox(width: 12.0),

              // 八字信息
              Expanded(child: _buildEightCharsInfo(theme)),
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
      statusColor = theme.colorScheme.secondary;
      statusIcon = Icons.hourglass_empty;
    } else if (provider.hasError) {
      statusColor = theme.colorScheme.error;
      statusIcon = Icons.error_outline;
    } else if (provider.isCompleted) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else if (provider.canInteract) {
      statusColor = theme.colorScheme.primary;
      statusIcon = Icons.touch_app;
    } else {
      statusColor = theme.colorScheme.onSurface.withOpacity(0.6);
      statusIcon = Icons.radio_button_unchecked;
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (provider.isLoading)
            SizedBox(
              width: 16.0,
              height: 16.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            )
          else
            Icon(statusIcon, size: 16.0, color: statusColor),

          const SizedBox(width: 6.0),

          Text(
            provider.getProviderStateDisplayText(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建八字信息
  Widget _buildEightCharsInfo(ThemeData theme) {
    final eightChars = provider.inputEightChars;
    if (eightChars == null) {
      return Text(
        '未设置八字',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '八字信息',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          eightChars.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
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
          provider.getSessionStatusDisplayText(),
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
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4.0),
        Text(
          '$label: $value',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
