import 'package:flutter/material.dart';

class ResizablePanel extends StatefulWidget {
  final Widget child;
  final double height;
  final double minHeight;
  final double maxHeight;
  final bool isAutoHeight;
  final ValueChanged<double>? onHeightChanged;
  final VoidCallback? onAutoHeightToggled;
  final bool showResizeHandle;
  final bool showAutoHeightToggle;

  const ResizablePanel({
    super.key,
    required this.child,
    this.height = 300,
    this.minHeight = 200,
    this.maxHeight = 600,
    this.isAutoHeight = false,
    this.onHeightChanged,
    this.onAutoHeightToggled,
    this.showResizeHandle = true,
    this.showAutoHeightToggle = true,
  });

  @override
  State<ResizablePanel> createState() => _ResizablePanelState();
}

class _ResizablePanelState extends State<ResizablePanel> {
  late double _currentHeight;
  bool _isResizing = false;
  double _startY = 0;
  double _startHeight = 0;

  @override
  void initState() {
    super.initState();
    _currentHeight = widget.height;
  }

  @override
  void didUpdateWidget(ResizablePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.height != oldWidget.height) {
      _currentHeight = widget.height;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showResizeHandle) _buildResizeHandle(),
        SizedBox(
          height: widget.isAutoHeight ? null : _currentHeight,
          child: widget.child,
        ),
      ],
    );
  }

  Widget _buildResizeHandle() {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeUpDown,
        child: Container(
          height: 8,
          width: double.infinity,
          color: Colors.transparent,
          child: Center(
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: _isResizing
                    ? const Color(0xFF3B82F6)
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.isAutoHeight) return;

    setState(() {
      _isResizing = true;
      _startY = details.globalPosition.dy;
      _startHeight = _currentHeight;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.isAutoHeight || !_isResizing) return;

    final deltaY = details.globalPosition.dy - _startY;
    final newHeight = (_startHeight - deltaY).clamp(
      widget.minHeight,
      widget.maxHeight,
    );

    setState(() {
      _currentHeight = newHeight;
    });

    widget.onHeightChanged?.call(newHeight);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isResizing = false;
    });
  }
}

class ResizablePanelWithControls extends StatelessWidget {
  final Widget child;
  final double height;
  final double minHeight;
  final double maxHeight;
  final bool isAutoHeight;
  final ValueChanged<double>? onHeightChanged;
  final VoidCallback? onAutoHeightToggled;
  final String? title;

  const ResizablePanelWithControls({
    super.key,
    required this.child,
    this.height = 300,
    this.minHeight = 200,
    this.maxHeight = 600,
    this.isAutoHeight = false,
    this.onHeightChanged,
    this.onAutoHeightToggled,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ResizablePanel(
            height: height,
            minHeight: minHeight,
            maxHeight: maxHeight,
            isAutoHeight: isAutoHeight,
            onHeightChanged: onHeightChanged,
            onAutoHeightToggled: onAutoHeightToggled,
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
          ],
          if (onAutoHeightToggled != null)
            Tooltip(
              message: isAutoHeight ? '固定高度' : '自动高度',
              child: InkWell(
                onTap: onAutoHeightToggled,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    isAutoHeight ? Icons.height : Icons.unfold_more,
                    size: 18,
                    color: isAutoHeight
                        ? const Color(0xFF3B82F6)
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HorizontalResizablePanel extends StatefulWidget {
  final Widget child;
  final double width;
  final double minWidth;
  final double maxWidth;
  final ValueChanged<double>? onWidthChanged;
  final bool showResizeHandle;

  const HorizontalResizablePanel({
    super.key,
    required this.child,
    this.width = 300,
    this.minWidth = 200,
    this.maxWidth = 600,
    this.onWidthChanged,
    this.showResizeHandle = true,
  });

  @override
  State<HorizontalResizablePanel> createState() =>
      _HorizontalResizablePanelState();
}

class _HorizontalResizablePanelState extends State<HorizontalResizablePanel> {
  late double _currentWidth;
  bool _isResizing = false;
  double _startX = 0;
  double _startWidth = 0;

  @override
  void initState() {
    super.initState();
    _currentWidth = widget.width;
  }

  @override
  void didUpdateWidget(HorizontalResizablePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.width != oldWidget.width) {
      _currentWidth = widget.width;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: _currentWidth, child: widget.child),
        if (widget.showResizeHandle) _buildResizeHandle(),
      ],
    );
  }

  Widget _buildResizeHandle() {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        child: Container(
          width: 8,
          height: double.infinity,
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _isResizing
                    ? const Color(0xFF3B82F6)
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isResizing = true;
      _startX = details.globalPosition.dx;
      _startWidth = _currentWidth;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isResizing) return;

    final deltaX = details.globalPosition.dx - _startX;
    final newWidth = (_startWidth + deltaX).clamp(
      widget.minWidth,
      widget.maxWidth,
    );

    setState(() {
      _currentWidth = newWidth;
    });

    widget.onWidthChanged?.call(newWidth);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isResizing = false;
    });
  }
}
