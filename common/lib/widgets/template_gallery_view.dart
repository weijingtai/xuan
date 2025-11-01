import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/four_zhu_editor_view_model.dart';
import '../models/template_preset.dart';
import '../enums/layout_template_enums.dart';

/// 模板预设画廊视图
///
/// 在编辑器顶部横向展示预设模板卡片:
/// - 流年盘
/// - 大运盘
/// - 胎元分析
/// 用户可点击快速应用预设配置
class TemplateGalleryView extends StatelessWidget {
  const TemplateGalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FourZhuEditorViewModel>(
      builder: (context, viewModel, _) {
        // 使用常量预设列表
        final presets = TemplatePresets.allPresets;
        final selectedPresetId = viewModel.selectedPresetId;

        return Container(
          height: 140,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
              ),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < presets.length; i++) ...[
                  _PresetCard(
                    preset: presets[i],
                    isSelected: selectedPresetId == presets[i].id,
                    onTap: () async {
                      // Task 2.1.4 - 应用预设
                      await viewModel.applyPreset(presets[i]);

                      // 显示成功提示
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('已应用预设: ${presets[i].name}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  if (i < presets.length - 1) const SizedBox(width: 12),
                ],
                const SizedBox(width: 12),
                // Task 2.1.5 - 添加预设按钮
                _AddPresetCard(
                  onTap: () => _showAddPresetDialog(context, viewModel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 显示添加预设对话框 (Task 2.1.5)
  void _showAddPresetDialog(
    BuildContext context,
    FourZhuEditorViewModel viewModel,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final nameController = TextEditingController();
        final descController = TextEditingController();

        // 过滤掉分隔符
        final availablePillars = PillarType.values
            .where((p) => p != PillarType.separator)
            .toList(growable: false);
        final Set<PillarType> selectedPillars = {
          PillarType.year,
          PillarType.month,
          PillarType.day,
          PillarType.hour,
        };

        // 常用行可见性
        final commonRows = const [
          RowType.heavenlyStem,
          RowType.earthlyBranch,
          RowType.tenGod,
          RowType.naYin,
        ];
        final Set<RowType> visibleRows = {...commonRows};

        String pillarLabel(PillarType type) {
          switch (type) {
            case PillarType.year:
              return '年柱';
            case PillarType.month:
              return '月柱';
            case PillarType.day:
              return '日柱';
            case PillarType.hour:
              return '时柱';
            case PillarType.ke:
              return '刻柱';
            case PillarType.taiMeta:
              return '胎命';
            case PillarType.taiMonth:
              return '胎月';
            case PillarType.taiDay:
              return '胎日';
            case PillarType.lifeHouse:
              return '命宫';
            case PillarType.luckCycle:
              return '大运';
            case PillarType.annual:
              return '流年';
            case PillarType.monthly:
              return '流月';
            case PillarType.daily:
              return '流日';
            case PillarType.hourly:
              return '流时';
            case PillarType.separator:
              return '列分隔符';
            case PillarType.rowTitleColumn:
              return '行标题列';
          }
        }

        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.add_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text('创建自定义预设'),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: '预设名称',
                          hintText: '例如：我的四柱模板',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: '预设描述（可选）',
                          hintText: '例如：年月日时 + 常用行',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '选择柱位',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final p in availablePillars)
                            FilterChip(
                              label: Text(pillarLabel(p)),
                              selected: selectedPillars.contains(p),
                              onSelected: (value) {
                                setState(() {
                                  if (value) {
                                    selectedPillars.add(p);
                                  } else {
                                    selectedPillars.remove(p);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '常用行可见性',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('天干'),
                            selected:
                                visibleRows.contains(RowType.heavenlyStem),
                            onSelected: (v) => setState(() {
                              if (v) {
                                visibleRows.add(RowType.heavenlyStem);
                              } else {
                                visibleRows.remove(RowType.heavenlyStem);
                              }
                            }),
                          ),
                          FilterChip(
                            label: const Text('地支'),
                            selected:
                                visibleRows.contains(RowType.earthlyBranch),
                            onSelected: (v) => setState(() {
                              if (v) {
                                visibleRows.add(RowType.earthlyBranch);
                              } else {
                                visibleRows.remove(RowType.earthlyBranch);
                              }
                            }),
                          ),
                          FilterChip(
                            label: const Text('十神'),
                            selected: visibleRows.contains(RowType.tenGod),
                            onSelected: (v) => setState(() {
                              if (v) {
                                visibleRows.add(RowType.tenGod);
                              } else {
                                visibleRows.remove(RowType.tenGod);
                              }
                            }),
                          ),
                          FilterChip(
                            label: const Text('纳音'),
                            selected: visibleRows.contains(RowType.naYin),
                            onSelected: (v) => setState(() {
                              if (v) {
                                visibleRows.add(RowType.naYin);
                              } else {
                                visibleRows.remove(RowType.naYin);
                              }
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('取消'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请填写预设名称')),
                      );
                      return;
                    }
                    if (selectedPillars.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请至少选择一个柱位')),
                      );
                      return;
                    }

                    final preset = TemplatePreset(
                      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      description: descController.text.trim().isEmpty
                          ? '自定义预设'
                          : descController.text.trim(),
                      defaultPillars: List<PillarType>.from(selectedPillars),
                      defaultVisibleRows: List<RowType>.from(visibleRows),
                      category: TemplatePresetCategory.other,
                    );

                    await viewModel.applyPreset(preset);

                    if (context.mounted) {
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已应用自定义预设: $name')),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('应用到当前模板'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// 预设卡片组件
class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final TemplatePreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                  ]
                : [
                    theme.colorScheme.surfaceContainerHighest,
                    theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 标题
              Text(
                preset.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
              ),

              // 柱位数量指示器
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.view_column_outlined,
                      size: 24,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${preset.defaultPillars.length}柱',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.8)
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // 描述
              Text(
                preset.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                          .withValues(alpha: 0.8)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 添加预设按钮卡片 (Task 2.1.5)
class _AddPresetCard extends StatelessWidget {
  const _AddPresetCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        height: 120,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            Text(
              '自定义预设',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
