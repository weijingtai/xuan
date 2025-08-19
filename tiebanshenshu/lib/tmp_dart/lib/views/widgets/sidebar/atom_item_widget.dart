import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/atom_operation.dart';
import '../../../viewmodels/algorithm_editor_viewmodel.dart';
import '../common/colors.dart';

class AtomItemWidget extends StatelessWidget {
  final AtomOperation operation;
  final Color color;

  const AtomItemWidget({
    super.key,
    required this.operation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<AtomOperation>(
      data: operation,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: _buildContent(),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: _buildItem()),
      child: _buildItem(),
    );
  }

  Widget _buildItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          // 可以添加点击事件，比如显示详细信息
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          operation.name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          operation.description,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
