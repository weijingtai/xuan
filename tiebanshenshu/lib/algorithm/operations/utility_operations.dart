import 'package:tiebanshenshu/algorithm/models/atomic_operation.dart';
import 'package:tiebanshenshu/algorithm/models/execution_context.dart';

/// A utility operation to split a list into two parts at a given index.
class SplitListAtom extends AtomicOperation {
  SplitListAtom()
      : super(
          id: 'split_list',
          name: '拆分列表',
          category: '辅助工具',
          description: '将一个列表在指定索引处拆分为两个列表。',
          version: 'v0.1',
        );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
        'list': ParameterDefinition(
          name: 'list',
          type: ParameterType.array,
          required: true,
          description: '需要被拆分的列表',
        ),
        'index': ParameterDefinition(
          name: 'index',
          type: ParameterType.intNum,
          required: true,
          description: '拆分的索引位置（该索引及之后的元素为第二部分）',
        ),
      };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
        'part1': ParameterDefinition(
          name: 'part1',
          type: ParameterType.array,
          required: true,
          description: '列表的第一部分',
        ),
        'part2': ParameterDefinition(
          name: 'part2',
          type: ParameterType.array,
          required: true,
          description: '列表的第二部分',
        ),
      };

  @override
  Map<String, ParameterDefinition> get configParameters => {};

  @override
  Future<Map<String, dynamic>> execute(
    ExecutionContext context,
    Map<String, dynamic> inputs,
    Map<String, dynamic> config,
  ) async {
    final list = inputs['list'] as List? ?? [];
    final index = inputs['index'] as int? ?? 0;

    if (index < 0 || index > list.length) {
      throw ArgumentError('Split index is out of bounds for the given list.');
    }

    final part1 = list.sublist(0, index);
    final part2 = list.sublist(index);

    return {
      'part1': part1,
      'part2': part2,
    };
  }
}

class FormatStringAtom extends AtomicOperation {
  FormatStringAtom()
      : super(
          id: 'format_string',
          name: '格式化字符串',
          category: '辅助工具',
          description: '使用变量映射来格式化一个模板字符串。',
          version: 'v0.1',
        );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
        'template': ParameterDefinition(
          name: 'template',
          type: ParameterType.str,
          required: true,
          description: '模板字符串，使用 {{variable_name}} 作为占位符。',
        ),
        'variables': ParameterDefinition(
          name: 'variables',
          type: ParameterType.dict,
          required: true,
          description: '用于替换占位符的键值对。',
        ),
      };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
        'result': ParameterDefinition(
          name: 'result',
          type: ParameterType.str,
          required: true,
          description: '格式化后的字符串。',
        ),
      };

  @override
  Map<String, ParameterDefinition> get configParameters => {};

  @override
  Future<Map<String, dynamic>> execute(
    ExecutionContext context,
    Map<String, dynamic> inputs,
    Map<String, dynamic> config,
  ) async {
    String template = inputs['template'] as String? ?? '';
    final variables = inputs['variables'] as Map<String, dynamic>? ?? {};

    variables.forEach((key, value) {
      template = template.replaceAll('{{$key}}', value.toString());
    });

    return {
      'result': template,
    };
  }
}


/// Wrapper class for utility operations.
class UtilityOperations {
  static List<AtomicOperation> getOperations() {
    return [
      SplitListAtom(),
      FormatStringAtom(),
    ];
  }
}
