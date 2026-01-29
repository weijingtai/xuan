import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/enums.dart';
import 'huang_ji_formula_v2.dart';
import '../../domain/models/base_number_selection_batch.dart';
import './huang_ji_v2_session_models.dart';
import '../../features/huang_ji_formula_manager.dart';
import './huang_ji_v2_view_model.dart';

/// HuangJi V2 Demo Page
///
/// Demonstrates the complete workflow of the new V2 architecture:
/// 1. Initialize session
/// 2. Show deduplication results
/// 3. Allow user selection
/// 4. Display final results
class HuangJiV2DemoPage extends StatefulWidget {
  const HuangJiV2DemoPage({super.key});

  @override
  State<HuangJiV2DemoPage> createState() => _HuangJiV2DemoPageState();
}

class _HuangJiV2DemoPageState extends State<HuangJiV2DemoPage> {
  final Map<String, int> _userSelections = {};

  @override
  void initState() {
    super.initState();
    // Auto-initialize with a test case
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTestSession();
    });
  }

  Future<void> _initializeTestSession() async {
    final viewModel = context.read<HuangJiV2ViewModel>();

    // Initialize formula manager first
    await HuangJiFormulaManager.instance.initialize();

    // Test case: 癸巳年 甲子月 丁酉日 癸卯时
    final eightChars = EightChars(
      year: JiaZi.GUI_SI,
      month: JiaZi.JIA_ZI,
      day: JiaZi.DING_YOU,
      time: JiaZi.GUI_MAO,
    );

    // 加载所有可用的公式
    final allFormulas = HuangJiFormulaManager.instance.getAllFormulas();

    if (allFormulas.isEmpty) {
      viewModel.resetSession();
      return;
    }

    print('📚 加载了 ${allFormulas.length} 个公式:');
    for (final f in allFormulas) {
      print('  - ${f.name} (ID: ${f.id})');
    }

    await viewModel.initializeSession(
      eightChars: eightChars,
      formulas: allFormulas,
      sessionName: '测试会话 - 所有公式',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('皇极取数法 V2 演示 - 所有公式'),
        actions: [
          Consumer<HuangJiV2ViewModel>(
            builder: (context, viewModel, _) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: viewModel.isLoading
                    ? null
                    : () {
                        viewModel.resetSession();
                        _userSelections.clear();
                        _initializeTestSession();
                      },
              );
            },
          ),
        ],
      ),
      body: Consumer<HuangJiV2ViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (viewModel.currentSession == null) {
            return const Center(child: Text('会话未初始化'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhaseIndicator(viewModel),
                const SizedBox(height: 24),
                _buildSessionInfo(viewModel),
                const SizedBox(height: 24),
                _buildPhaseContent(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhaseIndicator(HuangJiV2ViewModel viewModel) {
    final phase = viewModel.currentPhase;
    final phases = [
      SessionPhase.initialized,
      SessionPhase.yuanHuiYunShiCalculated,
      SessionPhase.baseNumberSelectionReady,
      SessionPhase.baseNumberSelected,
      SessionPhase.finalCalculationComplete,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当前阶段',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: phases.map((p) {
                final isCurrent = p == phase;
                final isCompleted = phases.indexOf(p) < phases.indexOf(phase!);
                return Chip(
                  label: Text(_getPhaseLabel(p)),
                  backgroundColor: isCurrent
                      ? Colors.blue
                      : isCompleted
                      ? Colors.green
                      : Colors.grey[300],
                  labelStyle: TextStyle(
                    color: isCurrent || isCompleted
                        ? Colors.white
                        : Colors.black,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo(HuangJiV2ViewModel viewModel) {
    final session = viewModel.currentSession!;
    final yhys = session.yuanHuiYunShi;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '会话信息: ${session.sessionName ?? session.sessionId}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (yhys != null) ...[
              Text('元: ${yhys.yuanNumber}'),
              Text('会: ${yhys.huiNumber}'),
              Text('运: ${yhys.yunNumber}'),
              Text('世: ${yhys.shiNumber}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseContent(HuangJiV2ViewModel viewModel) {
    switch (viewModel.currentPhase) {
      case SessionPhase.yuanHuiYunShiCalculated:
        return _buildReadyForSelection(viewModel);
      case SessionPhase.baseNumberSelectionReady:
        return _buildSelectionUI(viewModel);
      case SessionPhase.baseNumberSelected:
        return _buildReadyForCalculation(viewModel);
      case SessionPhase.finalCalculationComplete:
        return _buildFinalResults(viewModel);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildReadyForSelection(HuangJiV2ViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '元会运世已计算完成',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.prepareBaseNumberSelection(),
              child: const Text('准备基础数选择'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionUI(HuangJiV2ViewModel viewModel) {
    final batch = viewModel.selectionBatch;

    print('🎨 _buildSelectionUI 被调用');
    print('🎨 batch: ${batch != null ? "存在" : "null"}');
    print('🎨 batch.items.length: ${batch?.items.length ?? 0}');

    if (batch == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('批次数据为空，请检查'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '需要选择 ${batch.items.length} 个基础数（已去重）',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...batch.items.map((item) => _buildSelectionItem(item)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _userSelections.length == batch.items.length
              ? () => viewModel.submitSelections(_userSelections)
              : null,
          child: Text('提交选择 (${_userSelections.length}/${batch.items.length})'),
        ),
      ],
    );
  }

  Widget _buildSelectionItem(BaseNumberSelectionItem item) {
    final selectedNumber = _userSelections[item.definitionId];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(item.description, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              '推导链: ${item.derivationChain.getFullPath()}',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            Text(
              '应用于组: ${item.relatedGroupIds.join(", ")}',
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
            const SizedBox(height: 12),
            Text(
              '请从以下条文中选择一个 (共 ${item.candidates.length} 个候选):',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            // 使用列表显示条文内容
            ...item.candidates.map((candidate) {
              final isSelected = selectedNumber == candidate.number;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected ? Colors.blue[50] : null,
                ),
                child: RadioListTile<int>(
                  value: candidate.number,
                  groupValue: selectedNumber,
                  onChanged: (value) {
                    setState(() {
                      if (value != null) {
                        _userSelections[item.definitionId] = value;
                      }
                    });
                  },
                  title: Text(
                    '编号: ${candidate.number}',
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    candidate.tiaoWenContent,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  dense: false,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyForCalculation(HuangJiV2ViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '基础数已选择完成',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.calculateFinalTiaoWenList(),
              child: const Text('计算最终条文'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalResults(HuangJiV2ViewModel viewModel) {
    final results = viewModel.currentSession?.finalTiaoWenList ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '计算完成！共 ${results.length} 条结果',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...results.map(
          (result) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(result.formulaName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('基础数: ${result.baseNumber}'),
                  Text('条文数: ${result.tiaoWenNumber}'),
                  Text('条文内容: ${result.tiaoWenContent}'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getPhaseLabel(SessionPhase phase) {
    switch (phase) {
      case SessionPhase.initialized:
        return '初始化';
      case SessionPhase.yuanHuiYunShiCalculated:
        return '元会运世';
      case SessionPhase.baseNumberSelectionReady:
        return '准备选择';
      case SessionPhase.baseNumberSelected:
        return '已选择';
      case SessionPhase.finalCalculationComplete:
        return '完成';
    }
  }
}
