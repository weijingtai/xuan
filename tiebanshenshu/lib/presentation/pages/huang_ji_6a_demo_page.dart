/// 皇极取数法6A功能演示页面
///
/// 演示如何使用多基础数选择功能
library;

import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:common/models/eight_chars.dart';
import '../../domain/models/huang_ji_number.dart';
import '../../domain/models/multi_base_number_selection.dart';
import '../../domain/models/yuan_hui_yun_shi.dart';
import '../../application/services/multi_base_number_selection_service.dart';
import '../../application/services/huang_ji_session_service.dart';
import '../../application/usecases/huang_ji_interactive_use_case.dart';
import '../viewmodels/multi_base_number_selection_view_model.dart';
import '../viewmodels/huang_ji_interactive_view_model.dart';
import 'multi_base_number_selection_page.dart';
import 'huang_ji_interactive_page.dart';

/// 皇极取数法6A功能演示页面
class HuangJi6ADemoPage extends StatefulWidget {
  const HuangJi6ADemoPage({super.key});

  @override
  State<HuangJi6ADemoPage> createState() => _HuangJi6ADemoPageState();
}

class _HuangJi6ADemoPageState extends State<HuangJi6ADemoPage> {
  // 示例数据
  late EightChars _sampleEightChars;
  late YuanHuiYunShi _sampleYuanHuiYunShi;

  // 选择结果
  Map<BaseNumberSelectionType, HuangJiBaseNumber>? _selectionResults;

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // 创建示例八字数据
    _sampleEightChars = EightChars(
      year: JiaZi.GUI_SI, // 癸巳
      month: JiaZi.JIA_ZI, // 甲子
      day: JiaZi.DING_YOU, // 丁酉
      time: JiaZi.GUI_MAO, // 癸卯
    );

    // 创建元会运世数据
    _sampleYuanHuiYunShi = YuanHuiYunShi.fromEightChars(_sampleEightChars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('皇极取数法6A功能演示'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 功能介绍
            _buildFeatureIntroduction(context),

            const SizedBox(height: 24),

            // 示例数据展示
            _buildSampleDataDisplay(context),

            const SizedBox(height: 24),

            // 功能演示按钮
            _buildDemoButtons(context),

            const SizedBox(height: 24),

            // 选择结果展示
            if (_selectionResults != null) ...[
              _buildSelectionResults(context),
              const SizedBox(height: 24),
            ],

            // 技术说明
            _buildTechnicalDescription(context),
          ],
        ),
      ),
    );
  }

  /// 构建功能介绍
  Widget _buildFeatureIntroduction(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  '皇极取数法6A功能',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            '6A功能支持同时选择多个基础数，包括：',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _buildFeatureList(context, [
            '✨ 元会基础数 & 运世基础数同时选择',
            '🔄 基于主基础数的派生数选择（元会基础数一、运世基础数一等）',
            '⚙️ 每个基础数提供 ±30、±60、±90 调整选项',
            '📊 分阶段选择流程，清晰的进度指示',
            '🎯 智能依赖管理，派生数基于主基础数生成',
          ]),
        ],
      ),
    );
  }

  /// 构建功能列表
  Widget _buildFeatureList(BuildContext context, List<String> features) {
    final theme = Theme.of(context);

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.substring(0, 2),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  feature.substring(2),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 构建示例数据展示
  Widget _buildSampleDataDisplay(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '示例数据',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildDataItem(
                  context,
                  '八字',
                  '${_sampleEightChars.year.name} '
                      '${_sampleEightChars.month.name} '
                      '${_sampleEightChars.day.name} '
                      '${_sampleEightChars.time.name}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildDataItem(
                  context,
                  '元会基础数',
                  '${_sampleYuanHuiYunShi.yuanHuiMergeNumber.number}',
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _buildDataItem(
                  context,
                  '运世基础数',
                  '${_sampleYuanHuiYunShi.yunShiMergeNumber.number}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建数据项
  Widget _buildDataItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  /// 构建演示按钮
  Widget _buildDemoButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '功能演示',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // 基础演示：元会+运世
            _buildDemoButton(
              context,
              title: '基础演示',
              subtitle: '元会基础数 + 运世基础数',
              icon: Icons.looks_one,
              onPressed: () => _startBasicDemo(context),
            ),

            // 完整演示：包含派生数
            _buildDemoButton(
              context,
              title: '完整演示',
              subtitle: '主基础数 + 派生基础数',
              icon: Icons.looks_two,
              onPressed: () => _startFullDemo(context),
            ),

            // 自定义演示
            _buildDemoButton(
              context,
              title: '自定义演示',
              subtitle: '选择特定的基础数类型',
              icon: Icons.tune,
              onPressed: () => _startCustomDemo(context),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建演示按钮
  Widget _buildDemoButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: (MediaQuery.of(context).size.width - 56) / 2,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icon, size: 32, color: theme.colorScheme.primary),

                const SizedBox(height: 8),

                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建选择结果展示
  Widget _buildSelectionResults(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),

              const SizedBox(width: 8),

              Text(
                '选择结果',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ..._selectionResults!.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      '${entry.value.number}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _continueToHuangJiCalculation(context);
                  },
                  icon: const Icon(Icons.calculate),
                  label: const Text('继续到皇极取数'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  _showDetailedResults(context);
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('查看详细'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建技术说明
  Widget _buildTechnicalDescription(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '技术实现说明',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '本功能基于以下技术架构实现：\n\n'
            '• MultiBaseNumberSelectionManager：管理多个基础数的选择状态\n'
            '• MultiBaseNumberSelectionService：处理选择逻辑和候选项生成\n'
            '• MultiBaseNumberSelectionWidget：提供分阶段的用户界面\n'
            '• 扩展的HuangJiSession：支持多基础数选择的会话管理\n'
            '• 智能依赖管理：派生数自动基于主基础数生成候选项',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 开始基础演示
  void _startBasicDemo(BuildContext context) {
    _navigateToSelection(
      context,
      requiredTypes: [
        BaseNumberSelectionType.yuanHui,
        BaseNumberSelectionType.yunShi,
      ],
      optionalTypes: [],
    );
  }

  /// 开始完整演示
  void _startFullDemo(BuildContext context) {
    _navigateToSelection(
      context,
      requiredTypes: [
        BaseNumberSelectionType.yuanHui,
        BaseNumberSelectionType.yunShi,
      ],
      optionalTypes: [
        BaseNumberSelectionType.yuanHuiOne,
        BaseNumberSelectionType.yunShiOne,
      ],
    );
  }

  /// 开始自定义演示
  void _startCustomDemo(BuildContext context) {
    _showCustomSelectionDialog(context);
  }

  /// 导航到选择页面
  void _navigateToSelection(
    BuildContext context, {
    required List<BaseNumberSelectionType> requiredTypes,
    required List<BaseNumberSelectionType> optionalTypes,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => MultiBaseNumberSelectionViewModel(
            context.read<MultiBaseNumberSelectionService>(),
          ),
          child: MultiBaseNumberSelectionPage(
            yuanHuiYunShi: _sampleYuanHuiYunShi,
            requiredTypes: requiredTypes,
            optionalTypes: optionalTypes,
            onCompleted: (results) {
              setState(() {
                _selectionResults = results;
              });
            },
          ),
        ),
      ),
    );
  }

  /// 显示自定义选择对话框
  void _showCustomSelectionDialog(BuildContext context) {
    // 这里可以实现一个自定义选择对话框
    // 让用户选择具体要演示哪些基础数类型
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自定义演示'),
        content: const Text('自定义选择功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 继续到皇极取数计算
  void _continueToHuangJiCalculation(BuildContext context) {
    if (_selectionResults == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先完成基础数选择')));
      return;
    }

    // 导航到皇极取数交互式页面
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HuangJiInteractivePage(
          eightChars: _sampleEightChars,
          // 可以在这里传递选择的基础数配置
        ),
      ),
    );
  }

  /// 显示详细结果对话框
  void _showDetailedResults(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('详细选择结果'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: _selectionResults!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('数值: ${entry.value.number}'),
                    Text('类型: ${entry.value.baseNumberType.name}'),
                    Text('来源: ${entry.value.numberSource.name}'),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
