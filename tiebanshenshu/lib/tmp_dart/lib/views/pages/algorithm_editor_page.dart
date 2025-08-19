import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/algorithm_editor_viewmodel.dart';
import '../widgets/common/colors.dart';
import '../widgets/sidebar/atom_operations_sidebar.dart';
import '../widgets/flow_chart/flow_chart_widget.dart';
import '../widgets/data_panel/data_panel_widget.dart';
import '../widgets/common/custom_toast.dart';

class AlgorithmEditorPage extends StatelessWidget {
  const AlgorithmEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlgorithmEditorViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _buildHeader(context, viewModel),
              Expanded(
                child: Row(
                  children: [
                    // 侧边栏
                    if (MediaQuery.of(context).size.width >= 768)
                      const SizedBox(
                        width: 320,
                        child: AtomOperationsSidebar(),
                      ),

                    // 主内容区
                    Expanded(
                      child: Column(
                        children: [
                          // 流程图区域
                          Expanded(flex: 3, child: const FlowChartWidget()),

                          // 分隔线
                          _buildResizer(context, viewModel),

                          // 数据面板
                          SizedBox(
                            height: viewModel.dataPanelHeight,
                            child: const DataPanelWidget(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 移动端侧边栏
          drawer: MediaQuery.of(context).size.width < 768
              ? const Drawer(child: AtomOperationsSidebar())
              : null,

          // Toast提示
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AlgorithmEditorViewModel viewModel,
  ) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // 移动端菜单按钮
            if (MediaQuery.of(context).size.width < 768)
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),

            // 标题
            const Text(
              '原子算法编辑器',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 16),

            // 保存状态
            if (MediaQuery.of(context).size.width >= 768)
              Row(
                children: [
                  Icon(
                    viewModel.isSaved ? Icons.check_circle : Icons.access_time,
                    size: 16,
                    color: viewModel.isSaved
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    viewModel.isSaved ? '已保存' : '未保存',
                    style: TextStyle(
                      fontSize: 14,
                      color: viewModel.isSaved
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ],
              ),

            const Spacer(),

            // 操作按钮
            Row(
              children: [
                // 撤销/重做
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: null, // TODO: 实现撤销功能
                  tooltip: '撤销',
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: null, // TODO: 实现重做功能
                  tooltip: '重做',
                ),

                const SizedBox(width: 8),

                // 保存按钮
                ElevatedButton.icon(
                  onPressed: viewModel.saveProject,
                  icon: const Icon(Icons.save, size: 16),
                  label: MediaQuery.of(context).size.width >= 640
                      ? const Text('保存')
                      : const SizedBox.shrink(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),

                const SizedBox(width: 8),

                // 更多操作
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    // TODO: 实现导入导出功能
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text('导出JSON'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'import',
                      child: Row(
                        children: [
                          Icon(Icons.upload),
                          SizedBox(width: 8),
                          Text('导入JSON'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResizer(
    BuildContext context,
    AlgorithmEditorViewModel viewModel,
  ) {
    return GestureDetector(
      onPanUpdate: (details) {
        final newHeight = viewModel.dataPanelHeight - details.delta.dy;
        viewModel.updateDataPanelHeight(newHeight);
      },
      child: Container(
        height: 20,
        color: AppColors.background,
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
