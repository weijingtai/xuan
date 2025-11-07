import 'package:common/widgets/four_zhu/card_drag_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// CardDragController 单元测试
///
/// 覆盖事件计数与节流窗口的基本行为。
void main() {
  test('生命周期事件计数与 onMove 节流', () async {
    final controller =
        CardDragController(moveThrottle: const Duration(milliseconds: 12));
    final int c0 = controller.events.value;
    controller.onDragStart();
    expect(controller.events.value, c0 + 1);

    // 第一次移动：通过节流窗口
    int throttled = 0;
    controller.onMove(const Offset(1, 1), onThrottled: (_) => throttled++);
    expect(throttled, 1);

    // 紧接着第二次移动：应被节流忽略
    controller.onMove(const Offset(2, 2), onThrottled: (_) => throttled++);
    expect(throttled, 1);

    // 等待超过阈值，再次移动：应触发
    await Future.delayed(const Duration(milliseconds: 13));
    controller.onMove(const Offset(3, 3), onThrottled: (_) => throttled++);
    expect(throttled, 2);

    // 释放与取消进一步增加事件计数
    final beforeDrop = controller.events.value;
    controller.onDrop();
    expect(controller.events.value, beforeDrop + 1);

    final beforeCancel = controller.events.value;
    controller.cancel();
    expect(controller.events.value, beforeCancel + 1);
  });
}
