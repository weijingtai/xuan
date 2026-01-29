import 'package:flutter/material.dart';

/// 单个条文项组件
///
/// 显示条文编号、内容、年龄信息等
class TiaoWenItem extends StatelessWidget {
  /// 条文编号
  final int number;

  /// 条文内容
  final String content;

  /// 年龄信息
  final String ageInfo;

  /// 分类信息
  final String? category;

  /// 是否为最后一项
  final bool isLast;

  const TiaoWenItem({
    super.key,
    required this.number,
    required this.content,
    required this.ageInfo,
    this.category,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 条文编号
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16.0),

            // 条文内容和信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 条文内容
                  Text(
                    content,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),

                  const SizedBox(height: 8.0),

                  // 年龄和分类信息
                  Row(
                    children: [
                      // 年龄信息
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14.0,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              ageInfo,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 分类信息
                      if (category != null) ...[
                        const SizedBox(width: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            category!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 紧凑型条文项组件
class CompactTiaoWenItem extends StatelessWidget {
  final int number;
  final String content;
  final String ageInfo;

  const CompactTiaoWenItem({
    super.key,
    required this.number,
    required this.content,
    required this.ageInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // 编号
          Container(
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12.0),

          // 内容
          Expanded(
            child: Text(
              content,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 8.0),

          // 年龄
          Text(
            ageInfo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
