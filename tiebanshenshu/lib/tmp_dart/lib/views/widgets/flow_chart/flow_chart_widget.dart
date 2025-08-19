import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/atom_operation.dart';
import '../../../viewmodels/algorithm_editor_viewmodel.dart';
import '../common/colors.dart';
import '../common/zoom_controls.dart';
import 'connectioin_painter.dart';
import 'flow_node_widget.dart';

class FlowChartWidget extends StatelessWidget {
  const FlowChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlgorithmEditorViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          decoration: const BoxDecoration(color: AppColors.background),
          child: Column(
            children: [
              // 工具栏
              _buildToolbar(context, viewModel),

              // 流程图画布
              Expanded(child: _buildCanvas(context, viewModel)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    AlgorithmEditorViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            '算法流程图',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),

          // 缩放控件

          // ZoomControls(
          //   zoomLevel: viewModel.zoomLevel,
          //   onZoomIn: viewModel.zoomIn,
          //   onZoomOut: viewModel.zoomOut,
          //   onReset: viewModel.resetZoom,
          //   onZoomChanged: (double value) {},
          // ),
          const SizedBox(width: 12),

          // 自动布局按钮
          IconButton(
            onPressed: () {
              // TODO: 实现自动布局
            },
            icon: const Icon(Icons.auto_awesome),
            tooltip: '自动布局',
          ),

          // 全屏按钮
          IconButton(
            onPressed: () {
              // TODO: 实现全屏功能
            },
            icon: const Icon(Icons.fullscreen),
            tooltip: '全屏',
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(
    BuildContext context,
    AlgorithmEditorViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DragTarget<AtomOperation>(
          onAccept: (operation) {
            // 计算放置位置
            final position = Offset(
              100.0 + (viewModel.nodes.length * 150.0),
              100.0,
            );
            viewModel.addNode(operation, position);
          },
          builder: (context, candidateData, rejectedData) {
            return Transform.scale(
              scale: viewModel.zoomLevel,
              child: Stack(
                children: [
                  // 背景
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: candidateData.isNotEmpty
                        ? AppColors.primary.withOpacity(0.05)
                        : Colors.white,
                  ),

                  // 连接线
                  if (viewModel.connections.isNotEmpty)
                    CustomPaint(
                      painter: ConnectionPainter(
                        connections: viewModel.connections,
                        nodes: viewModel.nodes,
                      ),
                      size: Size.infinite,
                    ),

                  // 节点
                  ...viewModel.nodes.map(
                    (node) => Positioned(
                      left: node.position.dx,
                      top: node.position.dy,
                      child: FlowNodeWidget(
                        node: node,
                        onPositionChanged: (newPosition) {
                          viewModel.updateNodePosition(node.id, newPosition);
                        },
                        onDelete: () {
                          viewModel.removeNode(node.id);
                        },
                      ),
                    ),
                  ),

                  // 空状态提示
                  if (viewModel.nodes.isEmpty)
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_tree_outlined,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '拖拽原子操作到此处开始构建流程',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
