import 'package:flutter/material.dart';
import '../../../models/atom_operation.dart';
import '../common/colors.dart';
import 'atom_item_widget.dart';

class CategorySection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<AtomOperation> operations;

  const CategorySection({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.operations,
  });

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 分类标题
        InkWell(
          onTap: _toggleExpanded,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 操作列表
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: widget.color, width: 2)),
            ),
            child: Column(
              children: widget.operations
                  .map(
                    (operation) => AtomItemWidget(
                      operation: operation,
                      color: widget.color,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
