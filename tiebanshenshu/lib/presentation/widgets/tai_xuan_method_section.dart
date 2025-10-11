import 'package:flutter/material.dart';
import '../models/ui_tiao_wen_list_result_model.dart';
import 'calculation_summary.dart';
import 'tiao_wen_item.dart';
import 'tiao_wen_list_view.dart';

/// 太玄单个纳甲方案展示区域
///
/// 展示一种纳甲方案的完整计算结果，包括摘要和条文列表
class TaiXuanMethodSection extends StatefulWidget {
  /// 方案名称
  final String methodName;

  /// UI模型
  final UITiaoWenListResultModel uiModel;

  /// 主题颜色
  final Color color;

  const TaiXuanMethodSection({
    super.key,
    required this.methodName,
    required this.uiModel,
    required this.color,
  });

  @override
  State<TaiXuanMethodSection> createState() => _TaiXuanMethodSectionState();
}

class _TaiXuanMethodSectionState extends State<TaiXuanMethodSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: widget.color, width: 4.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 方案标题和展开控制
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.color,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      widget.methodName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.color,
                          ),
                    ),
                  ),
                  // 条文数量标签
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      '${widget.uiModel.tiaoWenCount}条',
                      style: TextStyle(
                        color: widget.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 展开内容
          if (_isExpanded) ...[
            const Divider(height: 1.0),

            // 计算摘要
            CalculationSummary(result: widget.uiModel),

            // 条文列表
            TiaoWenListView(
              tiaoWenList: widget.uiModel.tiaoWenEntities
                  .map(
                    (e) => TiaoWenItem(
                      number: e.id,
                      content: e.content1 ?? '',
                      ageInfo: _formatAgeInfo(e),
                      category: e.setName?.name ?? '',
                    ),
                  )
                  .toList(),
              result: null,
            ),
          ],
        ],
      ),
    );
  }

  /// 格式化年龄信息
  String _formatAgeInfo(entity) {
    String ageInfo = '';
    if (entity.ageSet1 != null && entity.ageSet1.isNotEmpty) {
      ageInfo = entity.ageSet1.join(', ');
      if (entity.ageSet2 != null && entity.ageSet2.isNotEmpty) {
        ageInfo += ' / ${entity.ageSet2.join(', ')}';
      }
    }
    return ageInfo.isNotEmpty ? ageInfo : '无年龄信息';
  }
}
