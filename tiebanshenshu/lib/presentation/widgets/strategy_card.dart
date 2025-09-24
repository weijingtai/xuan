import 'package:flutter/material.dart';
import '../viewmodels/base_tiao_wen_list_view_model.dart';
import '../models/ui_tiao_wen_list_result_model.dart';
import '../../domain/models/tiao_wen_list_state.dart';
import '../../repository/datamodels/tiao_wen_datamodel.dart';
import 'calculation_summary.dart';
import 'loading_widget.dart';
import 'error_widget.dart';
import 'empty_state_widget.dart';
import 'strategy_header.dart';
import 'tiao_wen_item.dart';
import 'tiao_wen_list_view.dart';

/// Strategy展示卡片组件
///
/// 展示单个Strategy的计算结果，支持展开/收起功能
class StrategyCard extends StatefulWidget {
  /// Strategy标题
  final String title;

  /// ViewModel实例
  final BaseTiaoWenListViewModel viewModel;

  /// 是否默认展开
  final bool initiallyExpanded;

  /// 卡片边距
  final EdgeInsets? margin;

  const StrategyCard({
    super.key,
    required this.title,
    required this.viewModel,
    this.initiallyExpanded = false,
    this.margin,
  });

  @override
  State<StrategyCard> createState() => _StrategyCardState();
}

class _StrategyCardState extends State<StrategyCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          widget.margin ??
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2.0,
        child: Column(
          children: [_buildHeader(), if (_isExpanded) _buildContent()],
        ),
      ),
    );
  }

  /// 构建卡片头部
  Widget _buildHeader() {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return StrategyHeader(
          title: widget.title,
          state: widget.viewModel.state,
          isExpanded: _isExpanded,
          onToggle: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          onRefresh: widget.viewModel.refresh,
          summary: widget.viewModel.hasResult ? _buildSummaryText() : null,
        );
      },
    );
  }

  /// 构建摘要文本
  String _buildSummaryText() {
    final result = widget.viewModel.result;
    if (result == null) return '';

    return '${result.tiaoWenCount}条 • ${result.calculationMethod}';
  }

  /// 构建卡片内容
  Widget _buildContent() {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return _buildStateContent();
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 1024,
          width: 512,
          child: _buildStateContent(),
        );
      },
    );
  }

  /// 格式化年龄信息
  String _formatAgeInfo(TiaoWenDataModel entity) {
    String ageInfo = '';
    if (entity.ageSet1 != null && entity.ageSet1!.isNotEmpty) {
      ageInfo = entity.ageSet1!.join(', ');
      if (entity.ageSet2 != null && entity.ageSet2!.isNotEmpty) {
        ageInfo += ' / ${entity.ageSet2!.join(', ')}';
      }
    }
    return ageInfo.isNotEmpty ? ageInfo : '无年龄信息';
  }

  /// 根据状态构建内容
  Widget _buildStateContent() {
    switch (widget.viewModel.state) {
      case TiaoWenListState.initial:
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: SimpleEmptyWidget(message: '点击刷新开始计算', icon: Icons.play_arrow),
        );

      case TiaoWenListState.loading:
        return const Padding(
          padding: EdgeInsets.all(32.0),
          child: LargeLoadingWidget(message: '计算中...'),
        );

      case TiaoWenListState.success:
        final result = widget.viewModel.result;
        if (result == null || result.tiaoWenCount == 0) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: EmptyStateWidget.noTiaoWen(),
          );
        }
        return Column(
          children: [
            CalculationSummary(result: result),
            TiaoWenListView(
              tiaoWenList: result.tiaoWenEntities
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
        );

      case TiaoWenListState.error:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomErrorWidget(
            message: '计算失败',
            onRetry: widget.viewModel.refresh,
          ),
        );
    }
  }
}
