import 'package:flutter/material.dart';

/// 卦象变化可视化组件
///
/// 展示单个卦象及其变化信息，包括：
/// - 六爻展示（从下到上：初、二、三、四、五、上）
/// - 变爻高亮标注
/// - 变化说明文字
class GuaChangeVisualization extends StatelessWidget {
  /// 卦象（如"震坤"）
  final String gua;

  /// 变换的爻位索引（0-5，-1表示无变换）
  final int? changedYaoIndex;

  /// 变化说明文字（如"变换五爻"）
  final String? changeDescription;

  /// 是否显示卦名
  final bool showGuaName;

  /// 卦象来源标签（如"先天卦"、"后天卦"）
  final String? sourceLabel;

  /// 自定义颜色
  final Color? accentColor;

  const GuaChangeVisualization({
    super.key,
    required this.gua,
    this.changedYaoIndex,
    this.changeDescription,
    this.showGuaName = true,
    this.sourceLabel,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 卦名和来源标签
        if (showGuaName) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                gua,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (sourceLabel != null) ...[
                const SizedBox(width: 6.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(
                      color: color.withOpacity(0.5),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    sourceLabel!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontSize: 10.0,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8.0),
        ],

        // 六爻展示
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildYaoLines(theme, color),
          ),
        ),

        // 变化说明
        if (changeDescription != null && changeDescription!.isNotEmpty) ...[
          const SizedBox(height: 6.0),
          Text(
            changeDescription!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  /// 构建六爻线条列表（从上到下显示：上、五、四、三、二、初）
  List<Widget> _buildYaoLines(ThemeData theme, Color accentColor) {
    final yaoNames = ['上', '五', '四', '三', '二', '初'];
    final yaoList = <Widget>[];

    // 将卦象转换为二进制列表
    final binaryList = _guaToBinaryList(gua);

    // 从上到下遍历（索引0=上卦第1爻，索引5=下卦第3爻）
    for (int i = 0; i < 6; i++) {
      final yaoIndex = 5 - i; // 转换为从下到上的索引（0=初爻，5=上爻）
      final isYang = binaryList[i] == 1;
      final isChanged = changedYaoIndex != null && changedYaoIndex == yaoIndex;

      yaoList.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 爻位标签
              SizedBox(
                width: 24.0,
                child: Text(
                  yaoNames[i],
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: isChanged ? FontWeight.bold : FontWeight.normal,
                    color: isChanged ? accentColor : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 6.0),

              // 爻线
              Container(
                width: 80.0,
                height: 6.0,
                decoration: BoxDecoration(
                  color: isChanged
                      ? accentColor
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(3.0),
                ),
                child: isYang
                    ? null
                    : Center(
                        child: Container(
                          width: 20.0,
                          height: 6.0,
                          color: theme.colorScheme.surface,
                        ),
                      ),
              ),

              // 变换标记
              const SizedBox(width: 6.0),
              SizedBox(
                width: 20.0,
                child: isChanged
                    ? Icon(
                        Icons.change_circle,
                        size: 16.0,
                        color: accentColor,
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    }

    return yaoList;
  }

  /// 将卦名转换为二进制列表
  ///
  /// 返回6位二进制列表，从上到下（索引0=上卦第1爻，索引5=下卦第3爻）
  List<int> _guaToBinaryList(String gua) {
    if (gua.length != 2) return [0, 0, 0, 0, 0, 0];

    final upper = gua[0];
    final lower = gua[1];

    // 八经卦二进制映射（阳爻=1，阴爻=0）
    const guaBinaryMapper = {
      '乾': [1, 1, 1], // ☰
      '兑': [0, 1, 1], // ☱
      '离': [1, 0, 1], // ☲
      '震': [0, 0, 1], // ☳
      '巽': [1, 1, 0], // ☴
      '坎': [0, 1, 0], // ☵
      '艮': [1, 0, 0], // ☶
      '坤': [0, 0, 0], // ☷
    };

    final upperBinary = guaBinaryMapper[upper] ?? [0, 0, 0];
    final lowerBinary = guaBinaryMapper[lower] ?? [0, 0, 0];

    return [...upperBinary, ...lowerBinary];
  }
}
