import 'package:flutter/material.dart';
import '../../../models/atom_operation.dart';
import '../../../models/flow_node.dart';
import '../common/colors.dart';

class FlowNodeWidget extends StatelessWidget {
  final FlowNode node;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Function(Offset)? onPositionChanged;

  const FlowNodeWidget({
    Key? key,
    required this.node,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
    this.onPositionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: GestureDetector(
        onTap: onTap,
        onPanUpdate: (details) {
          onPositionChanged?.call(node.position + details.delta);
        },
        child: Container(
          width: 224,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      node.operation.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(node.operation.category),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (onDelete != null) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                node.operation.description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '输入: ${node.operation.input}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '输出: ${node.operation.output}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(AtomOperationCategory category) {
    switch (category) {
      case AtomOperationCategory.time:
        return AppColors.time;
      case AtomOperationCategory.logic:
        return AppColors.logic;
      case AtomOperationCategory.format:
        return AppColors.format;
      case AtomOperationCategory.number:
        return AppColors.number;
      case AtomOperationCategory.output:
        return AppColors.output;
    }
  }
}
