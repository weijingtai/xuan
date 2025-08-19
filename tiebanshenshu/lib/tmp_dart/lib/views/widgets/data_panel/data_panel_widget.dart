import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/data_panel_viewmodel.dart';
import '../../../models/page_view_state.dart';
import 'detail_view.dart';
import 'visualization_view.dart';
import '../common/resizable_panel.dart';

class DataPanelWidget extends StatefulWidget {
  const DataPanelWidget({super.key});

  @override
  State<DataPanelWidget> createState() => _DataPanelWidgetState();
}

class _DataPanelWidgetState extends State<DataPanelWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      context.read<DataPanelViewModel>().setSelectedTab(_tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataPanelViewModel>(
      builder: (context, viewModel, child) {
        return ResizablePanel(
          height: viewModel.panelHeight,
          isAutoHeight: viewModel.isAutoHeight,
          onHeightChanged: viewModel.setPanelHeight,
          onAutoHeightToggled: viewModel.toggleAutoHeight,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [DetailView(), VisualizationView()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF3B82F6),
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: const Color(0xFF3B82F6),
        indicatorWeight: 2,
        tabs: const [
          Tab(icon: Icon(Icons.info_outline), text: '详细信息'),
          Tab(icon: Icon(Icons.visibility), text: '可视化'),
        ],
      ),
    );
  }
}
