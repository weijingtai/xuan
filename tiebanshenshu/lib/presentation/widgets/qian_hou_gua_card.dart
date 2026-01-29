import 'package:flutter/material.dart';
import '../viewmodels/qian_hou_gua_view_model.dart';

/// 前后卦取数法结果展示卡片
///
/// 展示前后卦取数法的完整计算结果和条文信息
class QianHouGuaCard extends StatefulWidget {
  final QianHouGuaViewModel viewModel;
  final bool initiallyExpanded;

  const QianHouGuaCard({
    super.key,
    required this.viewModel,
    this.initiallyExpanded = true,
  });

  @override
  State<QianHouGuaCard> createState() => _QianHouGuaCardState();
}

class _QianHouGuaCardState extends State<QianHouGuaCard> {
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
                          '前后卦取数法',
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
    final model = widget.viewModel.qianHouModel;
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
                      model.tianGua,
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
                      model.diGua,
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

          // 前后卦
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '前卦',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      model.qianGuaName.fullname,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    Text(
                      '基础数: ${model.qianGuaBaseNumber}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '后卦',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      model.houGuaName.fullname,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    Text(
                      '基础数: ${model.houGuaBaseNumber}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // 完整基础数
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '完整基础数: ',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                Text(
                  '${model.fullBaseNumber}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建计算步骤详情
  Widget _buildCalculationSteps(ThemeData theme) {
    final model = widget.viewModel.qianHouModel;
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

              // 步骤3：互卦
              _buildStepCard(theme, '步骤3：计算互卦', [
                '先天卦互卦: ${model.xiantianGuaHu}',
                '后天卦互卦: ${model.houtianGuaHu}',
              ]),

              const SizedBox(height: 12.0),

              // 步骤4-5：前后卦取数
              _buildStepCard(theme, '步骤4-5：前后卦取数', [
                '前卦取数: ${model.qianGuaDescription}',
                '后卦取数: ${model.houGuaDescription}',
                '完整基础数: ${model.fullBaseNumber} (${model.qianGuaBaseNumber}${model.houGuaBaseNumber})',
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
    final model = widget.viewModel.qianHouModel;
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
              // 前卦条文扩展（递增96四次）
              _buildTiaoWenExpansionCard(
                theme,
                '前卦条文扩展（递增96四次）',
                model.qianGuaCalculationFormula,
                widget.viewModel.qianGuaTiaoWenNumbers,
                theme.colorScheme.primary,
              ),
              const SizedBox(height: 12.0),
              // 后卦条文扩展（递减96四次）
              _buildTiaoWenExpansionCard(
                theme,
                '后卦条文扩展（递减96四次）',
                model.houGuaCalculationFormula,
                widget.viewModel.houGuaTiaoWenNumbers,
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
                '${widget.viewModel.qianGuaTiaoWenNumbers.length}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
              Text('前卦条文', style: theme.textTheme.bodySmall),
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
                '${widget.viewModel.houGuaTiaoWenNumbers.length}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              Text('后卦条文', style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建条文内容列表
  Widget _buildTiaoWenContentList(ThemeData theme) {
    final qianGuaModel = widget.viewModel.qianGuaBaseNumberTiaoWen;
    final houGuaModel = widget.viewModel.houGuaBaseNumberTiaoWen;

    if (qianGuaModel == null || houGuaModel == null) {
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
      ...qianGuaModel.tiaoWenDataList,
      ...houGuaModel.tiaoWenDataList,
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
              final isInQianGua = widget.viewModel.qianGuaTiaoWenNumbers
                  .contains(tiaowen.id);
              final isInHouGua = widget.viewModel.houGuaTiaoWenNumbers.contains(
                tiaowen.id,
              );

              final sources = <String>[];
              if (isInQianGua) sources.add('前卦');
              if (isInHouGua) sources.add('后卦');

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
                        final sourceColor = source.contains('前卦')
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
