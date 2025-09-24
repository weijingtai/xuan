import 'package:flutter/foundation.dart';
import 'package:common/models/eight_chars.dart';
import 'lib/domain/models/huang_ji_interactive_step.dart';
import 'lib/domain/models/interactive_session.dart';

void main() {
  // 模拟会话数据
  final sessionConfig = {
    'initialNumber': 9216,
    'secondaryNumber': 10151,
    'currentStep': HuangJiInteractiveStep.userSelection.id,
  };

  final session = InteractiveSession.create(
    sessionId: 'test_session',
    strategyName: 'huang_ji_interactive',
    sessionConfig: sessionConfig,
  );

  print('🧪 测试会话数据:');
  print('📊 sessionConfig: ${session.sessionConfig}');
  print('📊 currentStep from config: ${session.sessionConfig?['currentStep']}');
  
  // 模拟_updateSessionData逻辑
  final configData = session.sessionConfig ?? {};
  final currentStepId = configData['currentStep'] as String?;
  final currentStep = currentStepId != null 
      ? HuangJiInteractiveStep.fromString(currentStepId) ?? HuangJiInteractiveStep.initialization
      : HuangJiInteractiveStep.initialization;
  
  print('📊 解析后的currentStep: $currentStep');
  print('📊 needsUserSelection: ${currentStep == HuangJiInteractiveStep.userSelection}');
  
  if (currentStep == HuangJiInteractiveStep.userSelection) {
    print('✅ 修复成功！应该调用loadCandidates()');
  } else {
    print('❌ 修复失败！currentStep不正确');
  }
}