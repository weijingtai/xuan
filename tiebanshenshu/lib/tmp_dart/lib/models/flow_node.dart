import 'package:flutter/material.dart';
import 'atom_operation.dart';

import 'package:flutter/material.dart';
import 'atom_operation.dart';

class FlowNode {
  final String id;
  final AtomOperation operation;
  final Offset position;
  final bool isActive;
  final bool isHighlighted;
  final List<String> connections;

  const FlowNode({
    required this.id,
    required this.operation,
    required this.position,
    this.isActive = false,
    this.isHighlighted = false,
    this.connections = const [],
  });

  FlowNode copyWith({
    String? id,
    AtomOperation? operation,
    Offset? position,
    bool? isActive,
    bool? isHighlighted,
    List<String>? connections,
  }) {
    return FlowNode(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      position: position ?? this.position,
      isActive: isActive ?? this.isActive,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      connections: connections ?? this.connections,
    );
  }
}

class NodeConnection {
  final String fromNodeId;
  final String toNodeId;
  final bool isActive;

  const NodeConnection({
    required this.fromNodeId,
    required this.toNodeId,
    this.isActive = false,
  });

  NodeConnection copyWith({
    String? fromNodeId,
    String? toNodeId,
    bool? isActive,
  }) {
    return NodeConnection(
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      isActive: isActive ?? this.isActive,
    );
  }
}
