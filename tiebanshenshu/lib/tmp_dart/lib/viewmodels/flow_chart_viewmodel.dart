import 'package:flutter/material.dart';
import '../models/flow_node.dart';
import '../models/atom_operation.dart';

class FlowChartViewModel extends ChangeNotifier {
  List<FlowNode> _nodes = [];
  double _zoomLevel = 1.0;
  bool _isConnecting = false;
  FlowNode? _selectedNode;

  List<FlowNode> get nodes => _nodes;
  double get zoomLevel => _zoomLevel;
  bool get isConnecting => _isConnecting;
  FlowNode? get selectedNode => _selectedNode;

  void addNode(AtomOperation operation, Offset position) {
    final node = FlowNode(
      id: 'node_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      position: position,
    );
    _nodes.add(node);
    notifyListeners();
  }

  void removeNode(String nodeId) {
    _nodes.removeWhere((node) => node.id == nodeId);
    notifyListeners();
  }

  void updateNodePosition(String nodeId, Offset newPosition) {
    final nodeIndex = _nodes.indexWhere((node) => node.id == nodeId);
    if (nodeIndex != -1) {
      _nodes[nodeIndex] = _nodes[nodeIndex].copyWith(position: newPosition);
      notifyListeners();
    }
  }

  void setZoomLevel(double zoom) {
    _zoomLevel = zoom.clamp(0.5, 2.0);
    notifyListeners();
  }

  void zoomIn() {
    setZoomLevel(_zoomLevel + 0.1);
  }

  void zoomOut() {
    setZoomLevel(_zoomLevel - 0.1);
  }

  void selectNode(FlowNode? node) {
    _selectedNode = node;
    notifyListeners();
  }

  void startConnecting() {
    _isConnecting = true;
    notifyListeners();
  }

  void stopConnecting() {
    _isConnecting = false;
    notifyListeners();
  }

  void connectNodes(String fromNodeId, String toNodeId) {
    final fromNodeIndex = _nodes.indexWhere((node) => node.id == fromNodeId);
    final toNodeIndex = _nodes.indexWhere((node) => node.id == toNodeId);

    if (fromNodeIndex != -1 && toNodeIndex != -1) {
      final fromNode = _nodes[fromNodeIndex];
      final updatedConnections = List<String>.from(fromNode.connections)
        ..add(toNodeId);
      _nodes[fromNodeIndex] = fromNode.copyWith(
        connections: updatedConnections,
      );
      notifyListeners();
    }
  }

  void clearAll() {
    _nodes.clear();
    _selectedNode = null;
    _isConnecting = false;
    notifyListeners();
  }
}
