import 'package:flutter/material.dart';

class ZoomControls extends StatelessWidget {
  final double zoomLevel;
  final double minZoom;
  final double maxZoom;
  final double zoomStep;
  final ValueChanged<double> onZoomChanged;
  final VoidCallback? onResetZoom;

  const ZoomControls({
    super.key,
    required this.zoomLevel,
    required this.onZoomChanged,
    this.minZoom = 0.25,
    this.maxZoom = 3.0,
    this.zoomStep = 0.25,
    this.onResetZoom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildZoomButton(
            icon: Icons.add,
            tooltip: '放大',
            onPressed: _canZoomIn() ? _zoomIn : null,
          ),
          _buildDivider(),
          _buildZoomDisplay(),
          _buildDivider(),
          _buildZoomButton(
            icon: Icons.remove,
            tooltip: '缩小',
            onPressed: _canZoomOut() ? _zoomOut : null,
          ),
          if (onResetZoom != null) ...[
            _buildDivider(),
            _buildZoomButton(
              icon: Icons.center_focus_strong,
              tooltip: '重置缩放',
              onPressed: onResetZoom,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null
                ? Colors.grey.shade700
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildZoomDisplay() {
    return Container(
      width: 40,
      height: 32,
      alignment: Alignment.center,
      child: Text(
        '${(zoomLevel * 100).round()}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey.shade300,
    );
  }

  bool _canZoomIn() {
    return zoomLevel < maxZoom;
  }

  bool _canZoomOut() {
    return zoomLevel > minZoom;
  }

  void _zoomIn() {
    final newZoom = (zoomLevel + zoomStep).clamp(minZoom, maxZoom);
    onZoomChanged(newZoom);
  }

  void _zoomOut() {
    final newZoom = (zoomLevel - zoomStep).clamp(minZoom, maxZoom);
    onZoomChanged(newZoom);
  }
}

class ZoomControlsHorizontal extends StatelessWidget {
  final double zoomLevel;
  final double minZoom;
  final double maxZoom;
  final double zoomStep;
  final ValueChanged<double> onZoomChanged;
  final VoidCallback? onResetZoom;

  const ZoomControlsHorizontal({
    super.key,
    required this.zoomLevel,
    required this.onZoomChanged,
    this.minZoom = 0.25,
    this.maxZoom = 3.0,
    this.zoomStep = 0.25,
    this.onResetZoom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildZoomButton(
            icon: Icons.remove,
            tooltip: '缩小',
            onPressed: _canZoomOut() ? _zoomOut : null,
          ),
          const SizedBox(width: 8),
          _buildZoomSlider(),
          const SizedBox(width: 8),
          _buildZoomButton(
            icon: Icons.add,
            tooltip: '放大',
            onPressed: _canZoomIn() ? _zoomIn : null,
          ),
          if (onResetZoom != null) ...[
            const SizedBox(width: 8),
            _buildZoomButton(
              icon: Icons.center_focus_strong,
              tooltip: '重置缩放',
              onPressed: onResetZoom,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          child: Icon(
            icon,
            size: 18,
            color: onPressed != null
                ? Colors.grey.shade700
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildZoomSlider() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          child: Slider(
            value: zoomLevel,
            min: minZoom,
            max: maxZoom,
            divisions: ((maxZoom - minZoom) / zoomStep).round(),
            onChanged: onZoomChanged,
            activeColor: const Color(0xFF3B82F6),
            inactiveColor: Colors.grey.shade300,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${(zoomLevel * 100).round()}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  bool _canZoomIn() {
    return zoomLevel < maxZoom;
  }

  bool _canZoomOut() {
    return zoomLevel > minZoom;
  }

  void _zoomIn() {
    final newZoom = (zoomLevel + zoomStep).clamp(minZoom, maxZoom);
    onZoomChanged(newZoom);
  }

  void _zoomOut() {
    final newZoom = (zoomLevel - zoomStep).clamp(minZoom, maxZoom);
    onZoomChanged(newZoom);
  }
}
