import 'package:flutter/material.dart';
import '../../../models/atom_operation.dart';
import '../common/colors.dart';
import '../common/constants.dart';
import 'category_section.dart';

class AtomOperationsSidebar extends StatefulWidget {
  const AtomOperationsSidebar({super.key});

  @override
  State<AtomOperationsSidebar> createState() => _AtomOperationsSidebarState();
}

class _AtomOperationsSidebarState extends State<AtomOperationsSidebar> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // 搜索框
          _buildSearchBox(),

          // 分类列表
          Expanded(
            child: ListView(
              children: [
                CategorySection(
                  title: '时间处理',
                  icon: Icons.access_time,
                  color: AppColors.time,
                  operations: _filterOperations(AppConstants.timeOperations),
                ),
                CategorySection(
                  title: '数值计算',
                  icon: Icons.calculate,
                  color: AppColors.number,
                  operations: _filterOperations(AppConstants.numberOperations),
                ),
                CategorySection(
                  title: '逻辑判断',
                  icon: Icons.account_tree,
                  color: AppColors.logic,
                  operations: _filterOperations(AppConstants.logicOperations),
                ),
                CategorySection(
                  title: '输出格式化',
                  icon: Icons.text_format,
                  color: AppColors.format,
                  operations: _filterOperations(AppConstants.formatOperations),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索原子操作...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  List<AtomOperation> _filterOperations(List<AtomOperation> operations) {
    if (_searchQuery.isEmpty) return operations;

    return operations.where((op) {
      return op.name.toLowerCase().contains(_searchQuery) ||
          op.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
