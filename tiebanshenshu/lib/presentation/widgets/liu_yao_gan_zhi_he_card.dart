import 'package:flutter/material.dart';
import '../viewmodels/liu_yao_gan_zhi_he_view_model.dart';

/// 先后天卦六爻干支和数法结果展示卡片
///
/// 展示先后天卦六爻干支和数法的完整计算结果和条文信息
class LiuYaoGanZhiHeCard extends StatefulWidget {
  final LiuYaoGanZhiHeViewModel viewModel;
  final bool initiallyExpanded;

  const LiuYaoGanZhiHeCard({
    super.key,
    required this.viewModel,
    this.initiallyExpanded = true,
  });

  @override
  State<LiuYaoGanZhiHeCard> createState() => _LiuYaoGanZhiHeCardState();
}

class _LiuYaoGanZhiHeCardState extends State<LiuYaoGanZhiHeCard> {
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
                    Icons.hexagon_outlined,
                    color: theme.colorScheme.primary,
                    size: 24.0,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '先后天卦六爻干支和数法',
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
    final model = widget.viewModel.liuYaoGanZhiHeModel;
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

          // 先后天卦
          Row(
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
                      model.xiantianGua.fullname,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    Text(
                      '基础数: ${model.xiantianBaseNumber}',
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
                      '后天卦',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      model.houtianGua.fullname,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    Text(
                      '基础数: ${model.houtianBaseNumber}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
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
    final model = widget.viewModel.liuYaoGanZhiHeModel;
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
                '性别: ${widget.viewModel.currentGender}',
                '上卦: ${model.upperGua}',
                '下卦: ${model.lowerGua}',
                '先天卦: ${model.xiantianGua}',
                '后天卦: ${model.houtianGua}',
              ]),

              const SizedBox(height: 12.0),

              // 步骤3-4：先天卦六爻纳甲和干支和数计算
              _buildLiuYaoNajiaCard(
                theme,
                '步骤3-4：先天卦六爻纳甲和干支和数计算',
                model.xiantianGua.fullname,
                widget.viewModel.xiantianYaoTianGanList,
                widget.viewModel.xiantianYaoDiZhiList,
                widget.viewModel.xiantianYaoSumList,
                model.xiantianUpperSum,
                model.xiantianLowerSum,
                model.xiantianBaseNumber,
                theme.colorScheme.primary,
              ),

              const SizedBox(height: 12.0),

              // 步骤5-6：后天卦六爻纳甲和干支和数计算
              _buildLiuYaoNajiaCard(
                theme,
                '步骤5-6：后天卦六爻纳甲和干支和数计算',
                model.houtianGua.fullname,
                widget.viewModel.houtianYaoTianGanList,
                widget.viewModel.houtianYaoDiZhiList,
                widget.viewModel.houtianYaoSumList,
                model.houtianUpperSum,
                model.houtianLowerSum,
                model.houtianBaseNumber,
                theme.colorScheme.secondary,
              ),
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

  /// 构建六爻纳甲详情卡片
  Widget _buildLiuYaoNajiaCard(
    ThemeData theme,
    String title,
    String guaName,
    List<String> tianGanList,
    List<String> diZhiList,
    List<int> yaoSumList,
    int upperSum,
    int lowerSum,
    int baseNumber,
    Color accentColor,
  ) {
    const yaoNames = ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];

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
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            '卦名: $guaName',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12.0),

          // 六爻列表
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Column(
              children: List.generate(6, (index) {
                // 反向显示（上爻在上，初爻在下）
                final yaoIndex = 5 - index;
                final isUpperYao = yaoIndex >= 3; // 上三爻（四、五、上爻）

                return Container(
                  margin: EdgeInsets.only(
                    bottom: index < 5 ? 4.0 : 0.0,
                    top: index == 3 ? 8.0 : 0.0, // 上下卦之间增加间距
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: isUpperYao
                        ? accentColor.withOpacity(0.1)
                        : theme.colorScheme.secondaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4.0),
                    border: isUpperYao
                        ? Border.all(color: accentColor.withOpacity(0.3))
                        : null,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          yaoNames[yaoIndex],
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          '${tianGanList[yaoIndex]} ${diZhiList[yaoIndex]}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'sans-serif',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: yaoSumList[yaoIndex] == 0
                              ? theme.colorScheme.error.withOpacity(0.2)
                              : accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          yaoSumList[yaoIndex] == 0
                              ? '不计'
                              : '${yaoSumList[yaoIndex]}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            color: yaoSumList[yaoIndex] == 0
                                ? theme.colorScheme.error
                                : accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 12.0),

          // 和数计算
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('上三爻和数（千百位）:', style: theme.textTheme.bodySmall),
                    Text(
                      '$upperSum',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('下三爻和数（十位个位）:', style: theme.textTheme.bodySmall),
                    Text(
                      '$lowerSum',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '基础数:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$baseNumber',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建条文扩展展示区域
  Widget _buildTiaoWenExpansionSection(ThemeData theme) {
    final model = widget.viewModel.liuYaoGanZhiHeModel;
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
              // 先天卦条文扩展（递增减96四次）
              _buildTiaoWenExpansionCard(
                theme,
                '先天卦条文扩展（递增减96四次）',
                '基础数 + [0, 96, 192, 288, 384, -96, -192, -288]',
                widget.viewModel.xiantianTiaoWenNumbers,
                theme.colorScheme.primary,
              ),
              const SizedBox(height: 12.0),
              // 后天卦条文扩展（递增减96四次）
              _buildTiaoWenExpansionCard(
                theme,
                '后天卦条文扩展（递增减96四次）',
                '基础数 + [0, 96, 192, 288, 384, -96, -192, -288]',
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
