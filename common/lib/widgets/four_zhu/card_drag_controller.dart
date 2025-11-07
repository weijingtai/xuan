import 'dart:ui';

import 'package:flutter/foundation.dart';

/// CardDragController
/// 负责拖拽过程中的节流、状态通知与生命周期管理（开始/移动/放置/取消）。
///
/// 功能描述：
/// - 在 `onMove` 中对频繁事件进行时间窗口节流（默认 12ms），仅在跨单元或阈值变化时触发外部回调。
/// - 维护内部计数器用于调试或性能统计（可选）。
/// - 提供 ValueListenable 通知，便于外部视图按需刷新。
///
/// 参数说明：
/// - `moveThrottle`：移动事件节流窗口，默认 12ms。
///
/// 返回值说明：
/// - 生命周期方法均返回 `void`；统计与通知通过监听获取。
class CardDragController {
  /// 创建拖拽控制器。
  CardDragController({Duration moveThrottle = const Duration(milliseconds: 12)})
      : _moveThrottle = moveThrottle;

  final Duration _moveThrottle;
  DateTime? _lastMoveAt;
  final ValueNotifier<int> _events = ValueNotifier<int>(0);

  /// 对外暴露移动/事件计数，可用于日志或性能观测。
  ValueListenable<int> get events => _events;

  /// 拖拽开始时调用，重置内部状态并增加事件计数。
  /// 参数：无。
  /// 返回：`void`
  void onDragStart() {
    _lastMoveAt = null;
    _events.value = _events.value + 1;
  }

  /// 拖拽移动事件，执行节流并在通过窗口时调用外部回调。
  /// 参数：
  /// - `localPosition`：当前局部坐标。
  /// - `onThrottled`：通过节流窗口时触发的回调，参数为坐标。
  /// 返回：`void`
  void onMove(Offset localPosition,
      {required ValueChanged<Offset> onThrottled}) {
    final now = DateTime.now();
    if (_lastMoveAt == null || now.difference(_lastMoveAt!) >= _moveThrottle) {
      _lastMoveAt = now;
      _events.value = _events.value + 1;
      onThrottled(localPosition);
    }
  }

  /// 拖拽释放（放置）事件，重置状态并增加事件计数。
  /// 参数：无。
  /// 返回：`void`
  void onDrop() {
    _lastMoveAt = null;
    _events.value = _events.value + 1;
  }

  /// 取消拖拽（如中断或失败），重置状态并增加事件计数。
  /// 参数：无。
  /// 返回：`void`
  void cancel() {
    _lastMoveAt = null;
    _events.value = _events.value + 1;
  }
}
