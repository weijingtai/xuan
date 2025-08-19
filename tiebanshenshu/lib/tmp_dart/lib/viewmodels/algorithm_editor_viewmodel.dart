import 'package:flutter/material.dart';
import '../models/atom_operation.dart';
import '../models/flow_node.dart';
import '../models/page_view_state.dart';

class AlgorithmEditorViewModel extends ChangeNotifier {
  // 状态变量
  bool _isSidebarOpen = false;
  bool _isSaved = true;
  double _zoomLevel = 1.0;
  double _dataPanelHeight = 400.0;
  int _activeTabIndex = 0;

  // 流程图相关
  final List<FlowNode> _nodes = [];
  final List<NodeConnection> _connections = [];
  int _nodeCounter = 1;

  // 页面视图相关
  PageViewState _pageViewState = const PageViewState();
  final PageController _pageController = PageController();

  // Getters
  bool get isSidebarOpen => _isSidebarOpen;
  bool get isSaved => _isSaved;
  double get zoomLevel => _zoomLevel;
  double get dataPanelHeight => _dataPanelHeight;
  int get activeTabIndex => _activeTabIndex;
  List<FlowNode> get nodes => List.unmodifiable(_nodes);
  List<NodeConnection> get connections => List.unmodifiable(_connections);
  PageViewState get pageViewState => _pageViewState;
  PageController get pageController => _pageController;

  // 侧边栏控制
  void toggleSidebar() {
    _isSidebarOpen = !_isSidebarOpen;
    notifyListeners();
  }

  void closeSidebar() {
    if (_isSidebarOpen) {
      _isSidebarOpen = false;
      notifyListeners();
    }
  }

  // 缩放控制
  void zoomIn() {
    if (_zoomLevel < 2.0) {
      _zoomLevel += 0.1;
      notifyListeners();
    }
  }

  void zoomOut() {
    if (_zoomLevel > 0.5) {
      _zoomLevel -= 0.1;
      notifyListeners();
    }
  }

  void resetZoom() {
    _zoomLevel = 1.0;
    notifyListeners();
  }

  // 数据面板高度调整
  void updateDataPanelHeight(double height) {
    _dataPanelHeight = height.clamp(250.0, 600.0);
    notifyListeners();
  }

  // Tab切换
  void switchTab(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  // 节点管理
  void addNode(AtomOperation operation, Offset position) {
    final nodeId = 'node-${_nodeCounter++}';
    final newNode = FlowNode(
      id: nodeId,
      operation: operation,
      position: position,
      isHighlighted: true,
    );

    _nodes.add(newNode);
    _updateConnections();
    _updatePageView();
    _setSaved(false);

    // 3秒后移除高亮
    Future.delayed(const Duration(seconds: 3), () {
      _removeHighlight(nodeId);
    });

    notifyListeners();
  }

  void removeNode(String nodeId) {
    _nodes.removeWhere((node) => node.id == nodeId);
    _connections.removeWhere(
      (conn) => conn.fromNodeId == nodeId || conn.toNodeId == nodeId,
    );
    _updatePageView();
    _setSaved(false);
    notifyListeners();
  }

  void updateNodePosition(String nodeId, Offset newPosition) {
    final index = _nodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      _nodes[index] = _nodes[index].copyWith(position: newPosition);
      _setSaved(false);
      notifyListeners();
    }
  }

  void _removeHighlight(String nodeId) {
    final index = _nodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      _nodes[index] = _nodes[index].copyWith(isHighlighted: false);
      notifyListeners();
    }
  }

  // 连接线更新
  void _updateConnections() {
    _connections.clear();

    // 按节点ID排序
    final sortedNodes = List<FlowNode>.from(_nodes)
      ..sort((a, b) => a.id.compareTo(b.id));

    // 创建连接
    for (int i = 0; i < sortedNodes.length - 1; i++) {
      _connections.add(
        NodeConnection(
          fromNodeId: sortedNodes[i].id,
          toNodeId: sortedNodes[i + 1].id,
          isActive: i == 0,
        ),
      );
    }
  }

  // 页面视图更新
  void _updatePageView() {
    if (_nodes.isEmpty) {
      _pageViewState = const PageViewState();
    } else {
      _pageViewState = PageViewState(
        currentPage: _nodes.length - 1,
        totalPages: _nodes.length,
        isEmpty: false,
      );

      // 跳转到最新页面
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _pageViewState.currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  // 页面导航
  void goToPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < _pageViewState.totalPages) {
      _pageViewState = _pageViewState.copyWith(currentPage: pageIndex);
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  void nextPage() {
    if (_pageViewState.currentPage < _pageViewState.totalPages - 1) {
      goToPage(_pageViewState.currentPage + 1);
    }
  }

  void previousPage() {
    if (_pageViewState.currentPage > 0) {
      goToPage(_pageViewState.currentPage - 1);
    }
  }

  // 保存状态管理
  void _setSaved(bool saved) {
    _isSaved = saved;
    notifyListeners();
  }

  void saveProject() {
    // 模拟保存操作
    Future.delayed(const Duration(milliseconds: 500), () {
      _setSaved(true);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
