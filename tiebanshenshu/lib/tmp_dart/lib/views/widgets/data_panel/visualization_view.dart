import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/atom_operation.dart';
import '../../../viewmodels/data_panel_viewmodel.dart';

class VisualizationView extends StatelessWidget {
  const VisualizationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataPanelViewModel>(
      builder: (context, viewModel, child) {
        final pageViewState = viewModel.pageViewState;

        if (pageViewState.operations.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildPageNavigation(viewModel),
            Expanded(child: _buildPageContent(viewModel)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.visibility_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('暂无数据处理步骤', style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 8),
          Text('开始构建算法流程', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPageNavigation(DataPanelViewModel viewModel) {
    final pageViewState = viewModel.pageViewState;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          // 页面指示器
          _buildPageIndicators(viewModel),
          const SizedBox(height: 12),
          // 导航按钮和页面信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: pageViewState.currentPage > 0
                    ? () => viewModel.previousPage()
                    : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: '上一页',
              ),
              Text(
                viewModel.getPageInfo(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed:
                    pageViewState.currentPage < pageViewState.totalPages - 1
                    ? () => viewModel.nextPage()
                    : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: '下一页',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators(DataPanelViewModel viewModel) {
    final pageViewState = viewModel.pageViewState;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageViewState.totalPages, (index) {
        final isActive = index == pageViewState.currentPage;
        return GestureDetector(
          onTap: () => viewModel.goToPage(index),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF3B82F6) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPageContent(DataPanelViewModel viewModel) {
    final pageViewState = viewModel.pageViewState;
    final currentOperation =
        pageViewState.operations[pageViewState.currentPage];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOperationCard(currentOperation),
          const SizedBox(height: 16),
          _buildDataFlowVisualization(currentOperation),
          const SizedBox(height: 16),
          _buildProcessSteps(currentOperation),
        ],
      ),
    );
  }

  Widget _buildOperationCard(AtomOperation operation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getCategoryColor(operation.category).withOpacity(0.1),
            _getCategoryColor(operation.category).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getCategoryColor(operation.category).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(operation.category),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(operation.category),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operation.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCategoryName(operation.category),
                      style: TextStyle(
                        fontSize: 14,
                        color: _getCategoryColor(operation.category),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            operation.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataFlowVisualization(AtomOperation operation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.swap_horiz, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                '数据流向',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDataBox(
                  label: '输入',
                  type: operation.input,
                  icon: Icons.input,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_forward, color: Colors.blue, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDataBox(
                  label: '输出',
                  type: operation.output,
                  icon: Icons.output,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataBox({
    required String label,
    required String type,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            type,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessSteps(AtomOperation operation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.list_alt, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                '处理步骤',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...operation.steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == operation.steps.length - 1;

            return _buildStepItem(
              stepNumber: index + 1,
              stepText: step,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String stepText,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Text(
              stepText,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(AtomOperationCategory category) {
    switch (category) {
      case AtomOperationCategory.time:
        return const Color(0xFF10B981);
      case AtomOperationCategory.logic:
        return const Color(0xFF3B82F6);
      case AtomOperationCategory.format:
        return const Color(0xFF8B5CF6);
      case AtomOperationCategory.number:
        return const Color(0xFFF59E0B);
      case AtomOperationCategory.output:
        return const Color(0xFFF97316);
    }
  }

  IconData _getCategoryIcon(AtomOperationCategory category) {
    switch (category) {
      case AtomOperationCategory.time:
        return Icons.access_time;
      case AtomOperationCategory.logic:
        return Icons.calculate;
      case AtomOperationCategory.format:
        return Icons.format_list_numbered;
      case AtomOperationCategory.number:
        return Icons.calculate;
      case AtomOperationCategory.output:
        return Icons.output;
    }
  }

  String _getCategoryName(AtomOperationCategory category) {
    switch (category) {
      case AtomOperationCategory.time:
        return '时间处理';
      case AtomOperationCategory.logic:
        return '逻辑操作';
      case AtomOperationCategory.format:
        return '数据格式';
      case AtomOperationCategory.number:
        return '数值计算';
      case AtomOperationCategory.output:
        return '输出操作';
    }
  }
}
