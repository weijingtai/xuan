/// 候选项选择组件
///
/// 显示候选项列表并处理用户选择
library;

import 'package:flutter/material.dart';

import '../../domain/models/tiao_wen_candidate.dart';

/// 候选项选择组件
class CandidateSelectionWidget extends StatefulWidget {
  /// 候选项列表
  final List<TiaoWenCandidate> candidates;

  /// 候选项选择回调
  final Function(TiaoWenCandidate) onCandidateSelected;

  /// 是否正在加载
  final bool isLoading;

  const CandidateSelectionWidget({
    super.key,
    required this.candidates,
    required this.onCandidateSelected,
    this.isLoading = false,
  });

  @override
  State<CandidateSelectionWidget> createState() =>
      _CandidateSelectionWidgetState();
}

class _CandidateSelectionWidgetState extends State<CandidateSelectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _selectedCandidateId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(CandidateSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.candidates != widget.candidates) {
      _selectedCandidateId = null;
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.candidates.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildCandidateList(),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64.0,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16.0),
          Text(
            '暂无可选项',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            '请等待系统加载选项',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建候选项列表
  Widget _buildCandidateList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: widget.candidates.asMap().entries.map((entry) {
          final index = entry.key;
          final candidate = entry.value;
          return _buildCandidateItem(candidate, index);
        }).toList(),
      ),
    );
  }

  /// 构建候选项
  Widget _buildCandidateItem(TiaoWenCandidate candidate, int index) {
    final theme = Theme.of(context);
    final isSelected = _selectedCandidateId == candidate.id;
    final isEnabled = candidate.isEnabled && !widget.isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        elevation: isSelected ? 4.0 : 1.0,
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surface,
        child: InkWell(
          onTap: isEnabled ? () => _selectCandidate(candidate) : null,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // 候选项图标
                _buildCandidateIcon(theme, candidate, isSelected, isEnabled),

                const SizedBox(width: 16.0),

                // 候选项内容
                Expanded(
                  child: _buildCandidateContent(
                    theme,
                    candidate,
                    isSelected,
                    isEnabled,
                  ),
                ),

                // 选择指示器
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 24.0,
                  )
                else if (!isEnabled)
                  Icon(
                    Icons.block,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                    size: 24.0,
                  )
                else
                  Icon(
                    Icons.radio_button_unchecked,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 24.0,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建候选项图标
  Widget _buildCandidateIcon(
    ThemeData theme,
    TiaoWenCandidate candidate,
    bool isSelected,
    bool isEnabled,
  ) {
    IconData icon;
    Color iconColor;

    switch (candidate.type) {
      case TiaoWenCandidateType.fourZhu:
        icon = Icons.calendar_view_day;
        break;
      case TiaoWenCandidateType.calculationMethod:
        icon = Icons.calculate;
        break;
      case TiaoWenCandidateType.guaMapping:
        icon = Icons.map;
        break;
      case TiaoWenCandidateType.confirmation:
        icon = Icons.check_circle_outline;
        break;
      case TiaoWenCandidateType.custom:
        icon = Icons.settings;
        break;
      case TiaoWenCandidateType.baseNumber:
        icon = Icons.format_list_numbered;
        break;
      case TiaoWenCandidateType.gua:
        icon = Icons.auto_awesome;
        break;
      case TiaoWenCandidateType.ganzhi:
        icon = Icons.auto_awesome;
        break;
    }

    if (!isEnabled) {
      iconColor = theme.colorScheme.onSurface.withOpacity(0.3);
    } else if (isSelected) {
      iconColor = theme.colorScheme.primary;
    } else {
      iconColor = theme.colorScheme.onSurface.withOpacity(0.7);
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(icon, color: iconColor, size: 24.0),
    );
  }

  /// 构建候选项内容
  Widget _buildCandidateContent(
    ThemeData theme,
    TiaoWenCandidate candidate,
    bool isSelected,
    bool isEnabled,
  ) {
    Color textColor;
    if (!isEnabled) {
      textColor = theme.colorScheme.onSurface.withOpacity(0.3);
    } else if (isSelected) {
      textColor = theme.colorScheme.onPrimaryContainer;
    } else {
      textColor = theme.colorScheme.onSurface;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 显示名称
        Text(
          candidate.displayName,
          style: theme.textTheme.titleMedium?.copyWith(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),

        // 描述
        if (candidate.description.isNotEmpty) ...[
          const SizedBox(height: 4.0),
          Text(
            candidate.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],

        // 候选项类型标签
        const SizedBox(height: 8.0),
        _buildTypeChip(theme, candidate, isSelected, isEnabled),
      ],
    );
  }

  /// 构建类型标签
  Widget _buildTypeChip(
    ThemeData theme,
    TiaoWenCandidate candidate,
    bool isSelected,
    bool isEnabled,
  ) {
    String typeText = _getCandidateTypeText(candidate.type);

    Color chipColor;
    Color chipTextColor;

    if (!isEnabled) {
      chipColor = theme.colorScheme.onSurface.withOpacity(0.1);
      chipTextColor = theme.colorScheme.onSurface.withOpacity(0.3);
    } else if (isSelected) {
      chipColor = theme.colorScheme.primary.withOpacity(0.2);
      chipTextColor = theme.colorScheme.primary;
    } else {
      chipColor = theme.colorScheme.surfaceVariant;
      chipTextColor = theme.colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        typeText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: chipTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 获取候选项类型文本
  String _getCandidateTypeText(TiaoWenCandidateType type) {
    switch (type) {
      case TiaoWenCandidateType.fourZhu:
        return '四柱';
      case TiaoWenCandidateType.calculationMethod:
        return '计算方法';
      case TiaoWenCandidateType.guaMapping:
        return '卦象映射';
      case TiaoWenCandidateType.confirmation:
        return '确认';
      case TiaoWenCandidateType.custom:
        return '自定义';
      case TiaoWenCandidateType.baseNumber:
        return "基础数";
      case TiaoWenCandidateType.gua:
        return "卦";
      case TiaoWenCandidateType.ganzhi:
        return "干支";
    }
  }

  /// 选择候选项
  void _selectCandidate(TiaoWenCandidate candidate) {
    if (widget.isLoading) return;

    setState(() {
      _selectedCandidateId = candidate.id;
    });

    // 延迟一点时间显示选择效果，然后调用回调
    Future.delayed(const Duration(milliseconds: 200), () {
      widget.onCandidateSelected(candidate);
    });
  }
}
