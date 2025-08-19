import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/data_panel_viewmodel.dart';
import '../../../models/atom_operation.dart';

class DetailView extends StatelessWidget {
  const DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataPanelViewModel>(
      builder: (context, viewModel, child) {
        final pageViewState = viewModel.pageViewState;

        if (pageViewState.operations.isEmpty) {
          return _buildEmptyState();
        }

        final currentOperation =
            pageViewState.operations[pageViewState.currentPage];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOperationHeader(currentOperation),
              const SizedBox(height: 16),
              _buildOperationDetails(currentOperation),
              const SizedBox(height: 16),
              _buildInputOutputInfo(currentOperation),
              const SizedBox(height: 16),
              _buildStepsInfo(currentOperation),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('暂无数据处理步骤', style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 8),
          Text(
            '从左侧拖拽原子操作到流程图中开始构建',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationHeader(AtomOperation operation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCategoryColor(operation.category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getCategoryColor(operation.category).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getCategoryColor(operation.category),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(operation.category),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  operation.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCategoryName(operation.category),
                  style: TextStyle(
                    fontSize: 14,
                    color: _getCategoryColor(operation.category),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationDetails(AtomOperation operation) {
    return _buildInfoCard(
      title: '操作描述',
      icon: Icons.description,
      child: Text(
        operation.description,
        style: const TextStyle(fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _buildInputOutputInfo(AtomOperation operation) {
    return _buildInfoCard(
      title: '输入输出信息',
      icon: Icons.swap_horiz,
      child: Column(
        children: [
          _buildIORow('输入类型', operation.input, Icons.input),
          const SizedBox(height: 8),
          _buildIORow('输出类型', operation.output, Icons.output),
        ],
      ),
    );
  }

  Widget _buildStepsInfo(AtomOperation operation) {
    return _buildInfoCard(
      title: '处理步骤',
      icon: Icons.list_alt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: operation.steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    step,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildIORow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
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
        return Icons.transform;
      case AtomOperationCategory.number:
        return Icons.analytics;
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
