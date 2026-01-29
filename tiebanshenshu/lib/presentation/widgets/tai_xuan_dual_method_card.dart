import 'package:flutter/material.dart';
import '../viewmodels/tai_xuan_four_zhu_view_model.dart';
import 'loading_widget.dart';
import 'error_widget.dart';
import 'empty_state_widget.dart';
import 'tai_xuan_method_section.dart';

/// 太玄四柱双纳甲方案展示卡片
///
/// 同时展示年干阴阳纳甲和传统内外卦纳甲两种方案的计算结果
class TaiXuanDualMethodCard extends StatefulWidget {
  /// ViewModel实例
  final TaiXuanFourZhuViewModel viewModel;

  /// 是否默认展开
  final bool initiallyExpanded;

  /// 卡片边距
  final EdgeInsets? margin;

  const TaiXuanDualMethodCard({
    super.key,
    required this.viewModel,
    this.initiallyExpanded = false,
    this.margin,
  });

  @override
  State<TaiXuanDualMethodCard> createState() => _TaiXuanDualMethodCardState();
}

class _TaiXuanDualMethodCardState extends State<TaiXuanDualMethodCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ??
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2.0,
        child: Column(
          children: [
            _buildHeader(),
            if (_isExpanded) _buildContent(),
          ],
        ),
      ),
    );
  }

  /// 构建卡片头部
  Widget _buildHeader() {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // 展开/收起图标
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8.0),

                // 标题和状态
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '太玄四柱（双纳甲方案）',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (widget.viewModel.hasSelection) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          '八字: ${widget.viewModel.eightCharsDisplayText}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                      if (widget.viewModel.hasAnyResult) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          _buildSummaryText(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.blue[700],
                              ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 状态指示器
                _buildStateIndicator(),

                const SizedBox(width: 8.0),

                // 刷新按钮
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: widget.viewModel.hasSelection
                      ? () => widget.viewModel.refresh()
                      : null,
                  tooltip: '刷新',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建摘要文本
  String _buildSummaryText() {
    final List<String> parts = [];

    if (widget.viewModel.hasYearGanYinYangResult) {
      parts.add('年干阴阳: ${widget.viewModel.yearGanYinYangTiaoWenCount}条');
    }

    if (widget.viewModel.hasInnerOuterGuaResult) {
      parts.add('内外卦: ${widget.viewModel.innerOuterGuaTiaoWenCount}条');
    }

    if (parts.isEmpty) {
      return '暂无结果';
    }

    return parts.join(' • ');
  }

  /// 构建状态指示器
  Widget _buildStateIndicator() {
    if (widget.viewModel.isLoading) {
      return const SizedBox(
        width: 16.0,
        height: 16.0,
        child: CircularProgressIndicator(strokeWidth: 2.0),
      );
    }

    if (widget.viewModel.hasError) {
      return Icon(
        Icons.error_outline,
        color: Colors.red[700],
        size: 20.0,
      );
    }

    if (widget.viewModel.hasAnyResult) {
      return Icon(
        Icons.check_circle_outline,
        color: Colors.green[700],
        size: 20.0,
      );
    }

    return const SizedBox.shrink();
  }

  /// 构建卡片内容
  Widget _buildContent() {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return _buildStateContent();
      },
    );
  }

  /// 根据状态构建内容
  Widget _buildStateContent() {
    // 初始状态
    if (widget.viewModel.isInitial) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: SimpleEmptyWidget(
          message: '选择八字后点击刷新开始计算',
          icon: Icons.play_arrow,
        ),
      );
    }

    // 加载状态
    if (widget.viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: LargeLoadingWidget(message: '正在计算双纳甲方案...'),
      );
    }

    // 错误状态
    if (widget.viewModel.hasError) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomErrorWidget(
          message: widget.viewModel.errorMessage ?? '计算失败',
          onRetry: widget.viewModel.refresh,
        ),
      );
    }

    // 成功状态 - 显示双方案结果
    if (widget.viewModel.hasAnyResult) {
      return Column(
        children: [
          // 方案选择器
          _buildMethodSelector(),

          const Divider(height: 1.0),

          // 年干阴阳纳甲方案
          if (widget.viewModel.showYearGanYinYang &&
              widget.viewModel.hasYearGanYinYangResult)
            TaiXuanMethodSection(
              methodName: '年干阴阳纳甲',
              uiModel: widget.viewModel.yearGanYinYangUIModel!,
              color: Colors.blue,
            ),

          // 传统内外卦纳甲方案
          if (widget.viewModel.showInnerOuterGua &&
              widget.viewModel.hasInnerOuterGuaResult)
            TaiXuanMethodSection(
              methodName: '传统内外卦纳甲',
              uiModel: widget.viewModel.innerOuterGuaUIModel!,
              color: Colors.green,
            ),

          // 如果没有选中任何方案
          if (!widget.viewModel.showYearGanYinYang &&
              !widget.viewModel.showInnerOuterGua)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SimpleEmptyWidget(
                message: '请至少选择一种纳甲方案',
                icon: Icons.visibility_off,
              ),
            ),
        ],
      );
    }

    // 默认空状态
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: SimpleEmptyWidget(
        message: '暂无计算结果',
        icon: Icons.info_outline,
      ),
    );
  }

  /// 构建方案选择器
  Widget _buildMethodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '显示方案',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('年干阴阳纳甲'),
                  subtitle: widget.viewModel.hasYearGanYinYangResult
                      ? Text(
                          '${widget.viewModel.yearGanYinYangTiaoWenCount}条',
                          style: const TextStyle(fontSize: 12.0),
                        )
                      : null,
                  value: widget.viewModel.showYearGanYinYang,
                  onChanged: widget.viewModel.hasYearGanYinYangResult
                      ? (value) => widget.viewModel.toggleYearGanYinYang(value!)
                      : null,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('传统内外卦纳甲'),
                  subtitle: widget.viewModel.hasInnerOuterGuaResult
                      ? Text(
                          '${widget.viewModel.innerOuterGuaTiaoWenCount}条',
                          style: const TextStyle(fontSize: 12.0),
                        )
                      : null,
                  value: widget.viewModel.showInnerOuterGua,
                  onChanged: widget.viewModel.hasInnerOuterGuaResult
                      ? (value) => widget.viewModel.toggleInnerOuterGua(value!)
                      : null,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
