import 'package:flutter/material.dart';
import '../kao_ke_session_models.dart';

/// 计算方法选择器Widget
///
/// 允许用户选择需要使用的计算方法
/// 支持多选,至少需要选择一个方法
class MethodSelectorWidget extends StatelessWidget {
  /// 当前选择的方法集合
  final Set<KaoKeCalculationMethod> selectedMethods;

  /// 用户切换方法的回调
  final Function(KaoKeCalculationMethod) onMethodToggled;

  /// 是否禁用
  final bool disabled;

  const MethodSelectorWidget({
    super.key,
    required this.selectedMethods,
    required this.onMethodToggled,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '选择计算方法',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '至少选择一种计算方法',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // 方法选择列表
            ...KaoKeCalculationMethod.values.map((method) {
              final isSelected = selectedMethods.contains(method);
              return _buildMethodCard(
                context,
                method,
                isSelected,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard(
    BuildContext context,
    KaoKeCalculationMethod method,
    bool isSelected,
  ) {
    final methodInfo = _getMethodInfo(method);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: disabled ? null : () => onMethodToggled(method),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                : null,
          ),
          child: Row(
            children: [
              // 复选框
              Checkbox(
                value: isSelected,
                onChanged: disabled ? null : (_) => onMethodToggled(method),
              ),
              const SizedBox(width: 12),

              // 图标
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: methodInfo.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  methodInfo.icon,
                  color: methodInfo.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // 方法信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      methodInfo.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),

              // 选中标记
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  _MethodInfo _getMethodInfo(KaoKeCalculationMethod method) {
    switch (method) {
      case KaoKeCalculationMethod.baGuaJiaZe:
        return _MethodInfo(
          icon: Icons.hub,
          color: Colors.orange,
          description: '使用先后天八卦加则法进行计算,递增96四次',
        );
      case KaoKeCalculationMethod.liuYaoGanZhiHe:
        return _MethodInfo(
          icon: Icons.balance,
          color: Colors.purple,
          description: '使用六爻干支和数法进行计算,递增减96四次',
        );
    }
  }
}

class _MethodInfo {
  final IconData icon;
  final Color color;
  final String description;

  _MethodInfo({
    required this.icon,
    required this.color,
    required this.description,
  });
}
