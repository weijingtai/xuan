# HuangJiV2SessionService 设计文档

## 1. 概述

`HuangJiV2SessionService` 是一个专门为皇极取数法 V2 架构设计的会话服务，实现了 `InteractiveSessionService` 接口，负责管理皇极取数法的交互式计算会话。

## 2. 设计目标

- 集成 `InteractiveSessionService` 接口，提供标准化的会话管理
- 支持皇极取数法 V2 架构的特有功能
- 桥接现有的 `HuangJiV2Session` 和标准的 `InteractiveSession`
- 提供完整的会话生命周期管理

## 3. 核心架构

### 3.1 类结构

```dart
class HuangJiV2SessionService implements InteractiveSessionService {
  // 内存会话存储
  final Map<String, InteractiveSession> _sessions = {};
  final Map<String, HuangJiV2Session> _huangJiSessions = {};
  
  // 依赖服务
  final HuangJiFormulaManager _formulaManager;
  
  // 配置
  final int _sessionExpirationHours;
}
```

### 3.2 数据转换层

#### 3.2.1 HuangJiV2Session → InteractiveSession
- 会话基本信息映射
- 步骤状态转换
- 候选项数据转换

#### 3.2.2 InteractiveSession → HuangJiV2Session  
- 反向数据同步
- 状态一致性维护

## 4. 接口实现

### 4.1 会话管理接口

#### createSession
```dart
Future<InteractiveSession> createSession({
  required String strategyName,
  Map<String, dynamic>? sessionConfig,
})
```

**实现逻辑：**
1. 验证策略名称（必须是 "huang_ji_v2"）
2. 创建 `HuangJiV2Session` 实例
3. 转换为 `InteractiveSession`
4. 存储双重会话数据

#### getSession / saveSession / deleteSession
标准的 CRUD 操作，维护双重存储结构。

### 4.2 步骤管理接口

#### addStepToSession
```dart
Future<InteractiveSession> addStepToSession(
  String sessionId,
  InteractiveSessionStep step,
)
```

**实现逻辑：**
1. 获取对应的 `HuangJiV2Session`
2. 转换步骤数据到 V2 格式
3. 更新 V2 会话
4. 同步到 `InteractiveSession`

#### updateSessionStep
类似的双向同步逻辑。

## 5. 数据映射规范

### 5.1 会话状态映射

| HuangJiV2SessionStatus | InteractiveSessionStatus |
|------------------------|--------------------------|
| notStarted             | notStarted               |
| inProgress             | inProgress               |
| waitingForSelection    | waitingForSelection      |
| completed              | completed                |
| cancelled              | cancelled                |
| error                  | error                    |

### 5.2 步骤类型映射

| HuangJiStepType           | InteractiveSessionStep.stepName |
|---------------------------|----------------------------------|
| initializeFourZhu         | "initialize_four_zhu"            |
| calculateYuanHuiYunShi    | "calculate_yuan_hui_yun_shi"     |
| calculateInitialNumber    | "calculate_initial_number"       |
| calculateSecondaryNumber  | "calculate_secondary_number"     |
| selectBaseNumber          | "select_base_number"             |
| calculateFinalNumbers     | "calculate_final_numbers"        |
| getTiaoWenContent         | "get_tiao_wen_content"           |
| userSelection             | "user_selection"                 |
| completed                 | "completed"                      |

### 5.3 候选项数据映射

```dart
// SelectionCandidate → TiaoWenCandidate
TiaoWenCandidate _convertToTiaoWenCandidate(SelectionCandidate candidate) {
  return TiaoWenCandidate(
    id: candidate.id,
    name: candidate.name,
    description: candidate.description,
    value: candidate.selectableBaseNumber.value,
    source: candidate.numberSource?.toString() ?? 'unknown',
    metadata: candidate.metadata ?? {},
  );
}
```

## 6. 错误处理

### 6.1 异常类型
- `SessionNotFoundException`: 会话不存在
- `SessionStateException`: 会话状态异常
- `InvalidStrategyException`: 不支持的策略类型
- `DataSyncException`: 数据同步失败

### 6.2 错误恢复
- 自动重试机制
- 数据一致性检查
- 降级处理策略

## 7. 性能考虑

### 7.1 内存管理
- 定期清理过期会话
- 懒加载大型数据结构
- 缓存常用计算结果

### 7.2 并发处理
- 会话级别的锁机制
- 异步操作优化
- 批量操作支持

## 8. 测试策略

### 8.1 单元测试
- 接口方法覆盖率 100%
- 数据转换正确性验证
- 错误场景处理测试

### 8.2 集成测试
- 与现有系统的兼容性
- 端到端会话流程测试
- 性能基准测试

## 9. 扩展性设计

### 9.1 插件化架构
- 支持自定义步骤处理器
- 可配置的数据转换器
- 扩展的验证规则

### 9.2 配置化管理
- 外部配置文件支持
- 运行时配置更新
- 环境特定配置

## 10. 部署和维护

### 10.1 监控指标
- 会话创建/完成率
- 平均会话持续时间
- 错误率统计

### 10.2 日志记录
- 结构化日志格式
- 关键操作审计
- 性能指标记录