import 'package:flutter/material.dart';
import '../viewmodels/xian_houtian_jia_ze_view_model.dart';

/// 先后天八卦加则法结果展示卡片
///
/// 展示先后天八卦加则法的完整计算结果和条文信息
class XianHoutianJiaZeCard extends StatefulWidget {
  final XianHoutianJiaZeViewModel viewModel;
  final bool initiallyExpanded;

  const XianHoutianJiaZeCard({
    super.key,
    required this.viewModel,
    this.initiallyExpanded = true,
  });

  @override
  State<XianHoutianJiaZeCard> createState() => _XianHoutianJiaZeCardState();
}

class _XianHoutianJiaZeCardState extends State<XianHoutianJiaZeCard> {
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部 - 可点击展开/收起
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: theme.colorScheme.primary,
                    size: 24.0,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '先后天八卦加则法',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          widget.viewModel.paramsDisplayText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),

          // 内容区域
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 卦象概览
                  _buildGuaSummary(theme),

                  const SizedBox(height: 16.0),

                  // 计算步骤详情
                  _buildCalculationSteps(theme),

                  const SizedBox(height: 16.0),

                  // 条文扩展展示
                  _buildTiaoWenExpansionSection(theme),

                  if (widget.viewModel.hasResult) ...[
                    const SizedBox(height: 16.0),

                    // 条文内容列表
                    _buildTiaoWenContentList(theme),

                    const SizedBox(height: 16.0),

                    // 条文数量统计
                    _buildTiaoWenStats(theme),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建卦象概览
  Widget _buildGuaSummary(ThemeData theme) {
    final model = widget.viewModel.xianHoutianModel;
    if (model == null) {
      return Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(child: Text('未计算')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 天地卦
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '天卦',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      model.tianGua.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '地卦',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      model.diGua.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12.0),
          const Divider(),
          const SizedBox(height: 12.0),

          // 先后天卦（相同）
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '先后天卦',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      model.xiantianGua.fullname,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    Text(
                      '${model.upperGua} ☰ ${model.lowerGua}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  '先后天卦相同',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontSize: 10.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建计算步骤详情
  Widget _buildCalculationSteps(ThemeData theme) {
    final model = widget.viewModel.xianHoutianModel;
    if (model == null) return const SizedBox.shrink();

    return ExpansionTile(
      title: Text(
        '计算步骤详情',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      initiallyExpanded: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 步骤1：天地卦
              _buildStepCard(theme, '步骤1：生成天地卦', [
                '天干数: ${model.ganNumList.join(", ")}',
                '地支数: ${model.zhiNumList.map((list) => "[${list.join(",")}]").join(", ")}',
                '奇数和: ${model.oddNumTotal}',
                '偶数和: ${model.evenNumTotal}',
                '天数: ${model.tianGuaNum} → 天卦: ${model.tianGua}',
                '地数: ${model.diGuaNum} → 地卦: ${model.diGua}',
                if (model.usedThreeYuanWuGong) '使用三元五宫',
              ]),

              const SizedBox(height: 12.0),

              // 步骤2：先后天卦
              _buildStepCard(theme, '步骤2：生成先后天卦', [
                '年份阴阳: ${model.yearYinYang}年',
                '性别: ${model.gender}',
                '上卦: ${model.upperGua}',
                '下卦: ${model.lowerGua}',
                '先天卦: ${model.xiantianGua}',
                '后天卦: ${model.houtianGua} (与先天卦相同)',
              ]),

              const SizedBox(height: 12.0),

              // 步骤3-4：互卦
              _buildStepCard(theme, '步骤3-4：计算互卦', [
                '先天卦互卦: ${model.xiantianGuaHu}',
                '后天卦互卦: ${model.houtianGuaHu}',
              ]),

              const SizedBox(height: 12.0),

              // 步骤5-6：加则法基础数
              _buildStepCard(theme, '步骤5-6：加则法计算基础数', [
                '先天卦基础数: ${model.xiantianBaseNumber}',
                '后天卦基础数: ${model.houtianBaseNumber}',
              ]),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建步骤卡片
  Widget _buildStepCard(ThemeData theme, String title, List<String> content) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8.0),
          ...content.map(
            (line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(line, style: theme.textTheme.bodySmall),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建条文扩展展示区域
  Widget _buildTiaoWenExpansionSection(ThemeData theme) {
    final model = widget.viewModel.xianHoutianModel;
    if (model == null) return const SizedBox.shrink();

    return ExpansionTile(
      title: Text(
        '条文编号扩展',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      initiallyExpanded: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 先天卦条文扩展（递增96四次）
              _buildTiaoWenExpansionCard(
                theme,
                '先天卦条文扩展（递增96四次）',
                model.xiantianCalculationFormula,
                widget.viewModel.xiantianTiaoWenNumbers,
                theme.colorScheme.primary,
              ),
              const SizedBox(height: 12.0),
              // 后天卦条文扩展（递减96四次）
              _buildTiaoWenExpansionCard(
                theme,
                '后天卦条文扩展（递减96四次）',
                model.houtianCalculationFormula,
                widget.viewModel.houtianTiaoWenNumbers,
                theme.colorScheme.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建条文扩展卡片
  Widget _buildTiaoWenExpansionCard(
    ThemeData theme,
    String title,
    String formula,
    List<int> numbers,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            '计算公式: $formula',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 6.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: numbers.map((number) {
              return Chip(
                label: Text(
                  number.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 构建条文统计
  Widget _buildTiaoWenStats(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '${widget.viewModel.allTiaoWenNumbers.length}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text('唯一条文编号', style: theme.textTheme.bodySmall),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
          Column(
            children: [
              Text(
                '${widget.viewModel.xiantianTiaoWenNumbers.length}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
              Text('先天卦条文', style: theme.textTheme.bodySmall),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
          Column(
            children: [
              Text(
                '${widget.viewModel.houtianTiaoWenNumbers.length}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              Text('后天卦条文', style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建条文内容列表
  Widget _buildTiaoWenContentList(ThemeData theme) {
    final xiantianModel = widget.viewModel.xiantianBaseNumberTiaoWen;
    final houtianModel = widget.viewModel.houtianBaseNumberTiaoWen;

    if (xiantianModel == null || houtianModel == null) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(child: Text('暂无条文内容')),
      );
    }

    final allTiaoWen = {
      ...xiantianModel.tiaoWenDataList,
      ...houtianModel.tiaoWenDataList,
    }.toList();

    if (allTiaoWen.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(child: Text('暂无条文内容')),
      );
    }

    return ExpansionTile(
      title: Text(
        '条文内容列表（共${allTiaoWen.length}条）',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      initiallyExpanded: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: allTiaoWen.map((tiaowen) {
              // 判断条文来源
              final isInXiantian = widget.viewModel.xiantianTiaoWenNumbers
                  .contains(tiaowen.id);
              final isInHoutian = widget.viewModel.houtianTiaoWenNumbers
                  .contains(tiaowen.id);

              final sources = <String>[];
              if (isInXiantian) sources.add('先天卦');
              if (isInHoutian) sources.add('后天卦');

              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 条文编号和地支标签
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            '${tiaowen.id}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Chip(
                          label: Text(tiaowen.setName.name),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),

                    // 条文来源标签
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: sources.map((source) {
                        final sourceColor = source.contains('先天卦')
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: sourceColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                              color: sourceColor.withOpacity(0.5),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            source,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: sourceColor,
                              fontSize: 10.0,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    if (tiaowen.content1.isNotEmpty) ...[
                      const SizedBox(height: 12.0),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          tiaowen.content1,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                    if (tiaowen.content2 != null &&
                        tiaowen.content2!.isNotEmpty) ...[
                      const SizedBox(height: 6.0),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          tiaowen.content2!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
