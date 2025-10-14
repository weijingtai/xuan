import 'package:flutter/material.dart';
import '../../domain/models/yuan_tang_base_number_model.dart';
import '../../service/strategy/yuan_tang_strategy.dart';
import '../models/yuan_tang_ui_model.dart';
import 'yuan_tang_dayun_widget.dart';
import 'yuan_tang_liuyun_section.dart';

/// 元堂卦结果展示卡片
///
/// 展示元堂卦取数法的完整计算结果和条文信息
class YuanTangCard extends StatefulWidget {
  final YuanTangUIModel model;
  final bool initiallyExpanded;

  /// 元堂卦基础数模型（可选，用于流运系统）
  final YuanTangBaseNumberModel? baseNumberModel;

  /// 出生年份（可选，用于流运系统）
  final int? birthYear;

  /// 元堂卦策略实例（可选，用于流运系统）
  final YuanTangStrategy? strategy;

  const YuanTangCard({
    super.key,
    required this.model,
    this.initiallyExpanded = true,
    this.baseNumberModel,
    this.birthYear,
    this.strategy,
  });

  @override
  State<YuanTangCard> createState() => _YuanTangCardState();
}

class _YuanTangCardState extends State<YuanTangCard> {
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
                          '元堂卦取数法',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '性别:${widget.model.gender} | 三元:${widget.model.threeYuan} | 节气:${widget.model.birthAfterZhi}',
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
                  // 先天卦和后天卦概览
                  _buildGuaSummary(theme),

                  const SizedBox(height: 16.0),

                  // 计算步骤详情
                  _buildCalculationSteps(theme),

                  const SizedBox(height: 16.0),

                  // 大运展示
                  _buildDayunSection(theme),

                  const SizedBox(height: 16.0),

                  // 流运系统展示（如果数据可用）
                  if (_canShowLiuyunSystem()) ...[
                    _buildLiuyunSystemSection(theme),
                    const SizedBox(height: 16.0),
                  ],

                  // 条文扩展展示
                  _buildTiaoWenExpansionSection(theme),

                  const SizedBox(height: 16.0),

                  // 条文编号方法
                  _buildTiaoWenMethods(theme),

                  if (widget.model.hasTiaoWen) ...[
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
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '先天卦',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  widget.model.xiantianGua.fullname,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '${widget.model.upperGuaDisplay} ☰ ${widget.model.lowerGuaDisplay}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '后天卦',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  widget.model.houtianGua.fullname,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                Text(
                  '${widget.model.houtianUpperGuaDisplay} ☰ ${widget.model.houtianLowerGuaDisplay}',
                  style: theme.textTheme.bodySmall,
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
                '天卦: ${widget.model.tianGua}',
                '地卦: ${widget.model.diGua}',
                widget.model.tianDiGuaFormula,
              ]),

              const SizedBox(height: 12.0),

              // 步骤2：上下卦
              _buildStepCard(theme, '步骤2：生成先天卦', [
                '上卦: ${widget.model.upperGuaDisplay}',
                '下卦: ${widget.model.lowerGuaDisplay}',
                '先天卦: ${widget.model.xiantianGua}',
              ]),

              const SizedBox(height: 12.0),

              // 步骤3：元堂装卦
              _buildStepCard(theme, '步骤3：元堂装卦', [
                '元堂爻: ${widget.model.yuantangYaoLabel}爻',
                '六爻地支配置（见下方详情）',
              ]),

              // 显示六爻详情
              const SizedBox(height: 8.0),
              _buildYaoDetails(theme),

              const SizedBox(height: 12.0),

              // 步骤4：后天卦
              _buildStepCard(theme, '步骤4：生成后天卦', [
                '元堂爻爻变',
                '上下卦互换',
                '后天卦: ${widget.model.houtianGua}',
              ]),

              const SizedBox(height: 12.0),

              // 步骤4.5：后天卦元堂装卦
              _buildStepCard(theme, '步骤4.5：后天卦元堂装卦', [
                '后天卦元堂爻: ${widget.model.houtianYuantangYaoLabel}爻',
                '后天卦六爻地支配置（见下方详情）',
              ]),

              // 显示后天卦六爻详情
              const SizedBox(height: 8.0),
              _buildHoutianYaoDetails(theme),

              const SizedBox(height: 12.0),

              // 步骤5：互卦
              _buildStepCard(theme, '步骤5：计算互卦', [
                '先天卦互卦: ${widget.model.xiantianGuaHu}',
                '后天卦互卦: ${widget.model.houtianGuaHu}',
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

  /// 构建六爻详情
  Widget _buildYaoDetails(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '六爻地支详情',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          ...widget.model.yaoList.reversed.map((yao) {
            final isYuanTang = yao.isYuanTangYao;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 2.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: isYuanTang
                    ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40.0,
                    child: Text(
                      '${yao.positionLabel}爻',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: isYuanTang
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30.0,
                    child: Text(
                      yao.yinYang,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      yao.diZhiList.isEmpty ? '---' : yao.diZhiList.join(', '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  if (isYuanTang)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        '元堂',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 构建条文编号方法
  Widget _buildTiaoWenMethods(ThemeData theme) {
    return ExpansionTile(
      title: Text(
        '条文编号方法（8种）',
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
            children: widget.model.tiaoWenByMethod.entries.map((entry) {
              final methodName = entry.key;
              final numbers = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        methodName,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        numbers.join(', '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
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
                '${widget.model.allTiaoWenNumbers.length}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text('条文编号', style: theme.textTheme.bodySmall),
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
                '${widget.model.tiaoWenCount}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
              Text('条文内容', style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建后天卦六爻详情
  Widget _buildHoutianYaoDetails(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '后天卦六爻地支详情',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          ...widget.model.houtianYaoList.reversed.map((yao) {
            final isYuanTang = yao.isYuanTangYao;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 2.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: isYuanTang
                    ? theme.colorScheme.secondaryContainer.withOpacity(0.5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40.0,
                    child: Text(
                      '${yao.positionLabel}爻',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: isYuanTang
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30.0,
                    child: Text(
                      yao.yinYang,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      yao.diZhiList.isEmpty ? '---' : yao.diZhiList.join(', '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  if (isYuanTang)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        '元堂',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondary,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 构建大运展示区域
  Widget _buildDayunSection(ThemeData theme) {
    return ExpansionTile(
      title: Text(
        '大运计算（先天卦+后天卦）',
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
              // 先天卦大运
              YuanTangDayunWidget(
                title: '先天卦大运（${widget.model.xiantianGua}）',
                dayunList: widget.model.xiantianDayunList,
                showTitle: true,
              ),
              const SizedBox(height: 16.0),
              const Divider(),
              const SizedBox(height: 16.0),
              // 后天卦大运
              YuanTangDayunWidget(
                title: '后天卦大运（${widget.model.houtianGua}）',
                dayunList: widget.model.houtianDayunList,
                showTitle: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建条文扩展展示区域
  Widget _buildTiaoWenExpansionSection(ThemeData theme) {
    return ExpansionTile(
      title: Text(
        '条文编号扩展（递加96四次）',
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
              // 先天卦条文扩展
              _buildTiaoWenExpansionCard(
                theme,
                '先天卦条文扩展',
                widget.model.xiantianCalculationFormula,
                widget.model.xiantianTiaoWenNumbers,
              ),
              const SizedBox(height: 12.0),
              // 后天卦条文扩展
              _buildTiaoWenExpansionCard(
                theme,
                '后天卦条文扩展',
                widget.model.houtianCalculationFormula,
                widget.model.houtianTiaoWenNumbers,
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
              color: theme.colorScheme.primary,
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

  /// 构建条文内容列表
  Widget _buildTiaoWenContentList(ThemeData theme) {
    if (widget.model.tiaoWenDataList.isEmpty) {
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
        '条文内容列表（共${widget.model.tiaoWenCount}条）',
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
            children: widget.model.tiaoWenDataList.map((tiaowen) {
              // 获取条文来源信息
              final sources = widget.model.getTiaoWenSources(tiaowen.id);

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
                        // 根据来源类型使用不同颜色
                        Color sourceColor;
                        if (source.contains('先天卦扩展')) {
                          sourceColor = theme.colorScheme.primary;
                        } else if (source.contains('后天卦扩展')) {
                          sourceColor = theme.colorScheme.secondary;
                        } else if (source.contains('先天卦')) {
                          sourceColor = theme.colorScheme.tertiary;
                        } else if (source.contains('后天卦')) {
                          sourceColor = Colors.orange;
                        } else {
                          sourceColor = theme.colorScheme.outline;
                        }

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

  /// 检查是否可以显示流运系统
  bool _canShowLiuyunSystem() {
    return widget.baseNumberModel != null &&
        widget.birthYear != null &&
        widget.strategy != null;
  }

  /// 构建流运系统展示区域
  Widget _buildLiuyunSystemSection(ThemeData theme) {
    // 确保所有必需数据都可用
    if (!_canShowLiuyunSystem()) {
      return const SizedBox.shrink();
    }

    return ExpansionTile(
      title: Row(
        children: [
          Icon(Icons.insights, color: theme.colorScheme.primary, size: 20.0),
          const SizedBox(width: 8.0),
          Text(
            '流运系统（大运→流年→流月）',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      subtitle: Text(
        '点击展开查看完整流运系统：先天卦流运 + 后天卦流运',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      initiallyExpanded: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: YuanTangLiuyunSection(
            model: widget.baseNumberModel!,
            birthYear: widget.birthYear!,
            strategy: widget.strategy!,
          ),
        ),
      ],
    );
  }
}
