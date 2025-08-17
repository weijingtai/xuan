/// 算法编译器 - 组合与建构原子操作
///
/// 版本: v0.1
/// 作者: Algorithm Compiler Team
/// 创建时间: 2024
///
/// 功能说明:
/// - 提供数据组合和结构构建操作
/// - 支持复杂数据结构的创建
/// - 实现数据聚合和合并逻辑

import '../models/atomic_operation.dart';
import '../models/execution_context.dart';

/// 对象构建操作
class ObjectConstructionOperation extends AtomicOperation {
  ObjectConstructionOperation()
    : super(
        id: 'object_construction',
        name: '对象构建',
        category: '组合与建构',
        description: '根据字段规则构建对象',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'fields': ParameterDefinition(
      name: 'fields',
      type: ParameterType.dict,
      required: true,
      description: '对象字段',
    ),
    'template': ParameterDefinition(
      name: 'template',
      type: ParameterType.dict,
      required: false,
      description: '对象模板',
      defaultValue: {},
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'constructed_object': ParameterDefinition(
      name: 'constructed_object',
      type: ParameterType.dict,
      required: true,
      description: '构建的对象',
    ),
    'field_count': ParameterDefinition(
      name: 'field_count',
      type: ParameterType.intNum,
      required: true,
      description: '字段数量',
    ),
    'template_used': ParameterDefinition(
      name: 'template_used',
      type: ParameterType.boolean,
      required: true,
      description: '是否使用了模板',
    ),
  };

  @override
  Map<String, ParameterDefinition> get configParameters => {};

  @override
  Future<Map<String, dynamic>> execute(
    ExecutionContext context,
    Map<String, dynamic> input,
    Map<String, dynamic> config,
  ) async {
    final fields = input['fields'] as Map<String, dynamic>? ?? {};
    final template = input['template'] as Map<String, dynamic>? ?? {};

    final constructed = Map<String, dynamic>.from(template);

    // 添加字段
    for (final entry in fields.entries) {
      constructed[entry.key] = entry.value;
    }

    return {
      'constructed_object': constructed,
      'field_count': constructed.length,
      'template_used': template.isNotEmpty,
    };
  }
}

/// 数组组合操作
class ArrayCompositionOperation extends AtomicOperation {
  ArrayCompositionOperation()
    : super(
        id: 'array_composition',
        name: '数组组合',
        category: '组合与建构',
        description: '将多个元素组合成数组',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'elements': ParameterDefinition(
      name: 'elements',
      type: ParameterType.array,
      required: true,
      description: '待组合的元素列表',
    ),
    'mode': ParameterDefinition(
      name: 'mode',
      type: ParameterType.str,
      required: false,
      description: '组合模式：append, flatten, unique, sort',
      defaultValue: 'append',
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'composed_array': ParameterDefinition(
      name: 'composed_array',
      type: ParameterType.array,
      required: true,
      description: '组合后的数组',
    ),
    'element_count': ParameterDefinition(
      name: 'element_count',
      type: ParameterType.intNum,
      required: true,
      description: '元素数量',
    ),
  };

  @override
  Map<String, ParameterDefinition> get configParameters => {};

  @override
  Future<Map<String, dynamic>> execute(
    ExecutionContext context,
    Map<String, dynamic> input,
    Map<String, dynamic> config,
  ) async {
    final elements = input['elements'] as List? ?? [];
    final mode = input['mode'] as String? ?? 'append';

    List<dynamic> result;

    switch (mode) {
      case 'flatten':
        result = _flattenElements(elements);
        break;
      case 'unique':
        result = _uniqueElements(elements);
        break;
      case 'sort':
        result = _sortElements(elements);
        break;
      default:
        result = List.from(elements);
    }

    return {
      'composed_array': result,
      'element_count': result.length,
      'composition_mode': mode,
    };
  }

  List<dynamic> _flattenElements(List elements) {
    final flattened = <dynamic>[];

    for (final element in elements) {
      if (element is List) {
        flattened.addAll(_flattenElements(element));
      } else {
        flattened.add(element);
      }
    }

    return flattened;
  }

  List<dynamic> _uniqueElements(List elements) {
    final seen = <dynamic>{};
    final unique = <dynamic>[];

    for (final element in elements) {
      if (!seen.contains(element)) {
        seen.add(element);
        unique.add(element);
      }
    }

    return unique;
  }

  List<dynamic> _sortElements(List elements) {
    final sorted = List.from(elements);

    try {
      sorted.sort((a, b) {
        if (a is Comparable && b is Comparable) {
          return a.compareTo(b);
        }
        return a.toString().compareTo(b.toString());
      });
    } catch (e) {
      // 如果排序失败，返回原始顺序
    }

    return sorted;
  }
}

/// 数据合并操作
class DataMergeOperation extends AtomicOperation {
  DataMergeOperation()
    : super(
        id: 'data_merge',
        name: '数据合并',
        category: '组合与建构',
        description: '合并多个数据源',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'sources': ParameterDefinition(
      name: 'sources',
      type: ParameterType.array,
      required: true,
      description: '待合并的数据源列表',
    ),
    'strategy': ParameterDefinition(
      name: 'strategy',
      type: ParameterType.str,
      required: false,
      description: '合并策略：deep, shallow',
      defaultValue: 'deep',
    ),
    'conflict_resolution': ParameterDefinition(
      name: 'conflict_resolution',
      type: ParameterType.str,
      required: false,
      description: '冲突解决策略：first_wins, last_wins, combine',
      defaultValue: 'last_wins',
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'merged_data': ParameterDefinition(
      name: 'merged_data',
      type: ParameterType.dict,
      required: true,
      description: '合并后的数据',
    ),
    'source_count': ParameterDefinition(
      name: 'source_count',
      type: ParameterType.intNum,
      required: true,
      description: '数据源数量',
    ),
  };

  @override
  Map<String, ParameterDefinition> get configParameters => {};

  @override
  Future<Map<String, dynamic>> execute(
    ExecutionContext context,
    Map<String, dynamic> input,
    Map<String, dynamic> config,
  ) async {
    final sources = input['sources'] as List? ?? [];
    final strategy = input['strategy'] as String? ?? 'deep';
    final conflictResolution =
        input['conflict_resolution'] as String? ?? 'last_wins';

    final merged = _mergeSources(sources, strategy, conflictResolution);

    return {
      'merged_data': merged,
      'source_count': sources.length,
      'merge_strategy': strategy,
      'conflict_resolution': conflictResolution,
    };
  }

  Map<String, dynamic> _mergeSources(
    List sources,
    String strategy,
    String conflictResolution,
  ) {
    final result = <String, dynamic>{};

    for (final source in sources) {
      if (source is Map<String, dynamic>) {
        if (strategy == 'deep') {
          _deepMerge(result, source, conflictResolution);
        } else {
          _shallowMerge(result, source, conflictResolution);
        }
      }
    }

    return result;
  }

  void _shallowMerge(
    Map<String, dynamic> target,
    Map<String, dynamic> source,
    String conflictResolution,
  ) {
    for (final entry in source.entries) {
      if (!target.containsKey(entry.key) || conflictResolution == 'last_wins') {
        target[entry.key] = entry.value;
      } else if (conflictResolution == 'first_wins') {
        // 保持现有值
      } else if (conflictResolution == 'combine') {
        final existing = target[entry.key];
        if (existing is List && entry.value is List) {
          target[entry.key] = [...existing, ...entry.value];
        } else if (existing is String && entry.value is String) {
          target[entry.key] = '$existing ${entry.value}';
        } else {
          target[entry.key] = entry.value;
        }
      }
    }
  }

  void _deepMerge(
    Map<String, dynamic> target,
    Map<String, dynamic> source,
    String conflictResolution,
  ) {
    for (final entry in source.entries) {
      if (!target.containsKey(entry.key)) {
        target[entry.key] = entry.value;
      } else {
        final existing = target[entry.key];
        final incoming = entry.value;

        if (existing is Map<String, dynamic> &&
            incoming is Map<String, dynamic>) {
          _deepMerge(existing, incoming, conflictResolution);
        } else {
          _handleConflict(
            target,
            entry.key,
            existing,
            incoming,
            conflictResolution,
          );
        }
      }
    }
  }

  void _handleConflict(
    Map<String, dynamic> target,
    String key,
    dynamic existing,
    dynamic incoming,
    String resolution,
  ) {
    switch (resolution) {
      case 'first_wins':
        // 保持现有值
        break;
      case 'last_wins':
        target[key] = incoming;
        break;
      case 'combine':
        if (existing is List && incoming is List) {
          target[key] = [...existing, ...incoming];
        } else if (existing is String && incoming is String) {
          target[key] = '$existing $incoming';
        } else {
          target[key] = incoming;
        }
        break;
      default:
        target[key] = incoming;
    }
  }
}

/// 组合与建构操作包装类
class CompositionConstruction {
  static List<AtomicOperation> getOperations() {
    return [
      ObjectConstructionOperation(),
      ArrayCompositionOperation(),
      DataMergeOperation(),
    ];
  }
}
