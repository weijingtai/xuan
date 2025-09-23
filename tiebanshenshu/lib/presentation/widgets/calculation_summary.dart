import 'package:flutter/material.dart';
import '../models/ui_tiao_wen_list_result_model.dart';

/// 计算结果摘要组件
/// 
/// 显示计算方法、条文数量等摘要信息
class CalculationSummary extends StatelessWidget {
  /// UI结果模型
  final UITiaoWenListResultModel result;

  const CalculationSummary({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 计算方法
          Row(
            children: [
              Icon(
                Icons.calculate,
                size: 16.0,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8.0),
              Text(
                '计算方法',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                result.calculationMethod,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8.0),
          
          // 条文统计
          Row(
            children: [
              Icon(
                Icons.article,
                size: 16.0,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8.0),
              Text(
                '条文数量',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                '${result.tiaoWenCount}条',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          
          // 源数据信息
          if (result.sourceData.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(
                  Icons.data_object,
                  size: 16.0,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8.0),
                Text(
                  '数据源',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    _formatTiaoWenSummary(result),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 格式化条文摘要信息
  String _formatTiaoWenSummary(UITiaoWenListResultModel result) {
    // 优先显示条文entities的摘要信息
    if (result.hasTiaoWenData) {
      final entities = result.tiaoWenEntities;
      final firstEntity = entities.first;
      final setNames = entities.map((e) => e.setName?.name ?? '未知').toSet();
      
      return '条文数量: ${entities.length} | 地支: ${setNames.join(', ')} | 首条: ${firstEntity.content1 ?? '无内容'}';
    }
    
    // 如果没有条文数据，回退到源数据显示
    return _formatSourceData(result.sourceData);
  }

  /// 格式化源数据为显示字符串
  String _formatSourceData(Map<String, dynamic> sourceData) {
    if (sourceData.isEmpty) {
      return '无数据';
    }
    
    // 提取关键信息进行显示
    final List<String> keyInfo = [];
    
    // 添加一些常见的关键字段
    if (sourceData.containsKey('calculationMethod')) {
      keyInfo.add('方法: ${sourceData['calculationMethod']}');
    }
    if (sourceData.containsKey('timestamp')) {
      keyInfo.add('时间: ${sourceData['timestamp']}');
    }
    if (sourceData.containsKey('inputData')) {
      keyInfo.add('输入数据');
    }
    
    // 如果没有找到关键信息，显示字段数量
    if (keyInfo.isEmpty) {
      keyInfo.add('${sourceData.length} 个数据字段');
    }
    
    return keyInfo.join(', ');
  }
}