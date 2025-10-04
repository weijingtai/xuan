# Common Module - Product Requirements Document (PRD)

## 1. 项目概述 / Project Overview

### 1.1 模块简介
Common 模块是铁板神数应用的核心共享模块，提供了数据库管理、数据模型、UI 组件、工具类和业务逻辑的基础设施。该模块采用 Flutter/Dart 技术栈，遵循 Clean Architecture 架构模式。

### 1.2 技术栈
- **框架**: Flutter 3.24.0+
- **语言**: Dart 3.5.0+
- **数据库**: Drift (SQLite ORM)
- **状态管理**: Provider/ChangeNotifier
- **日志**: Logger
- **国际化**: Intl
- **其他**: Tuple, Collection 工具类

## 2. 目标与愿景 / Goals & Objectives

### 2.1 主要目标
1. **模块化设计**: 提供高度可复用的共享组件和服务
2. **数据一致性**: 确保应用数据的完整性和一致性
3. **性能优化**: 提供高效的数据访问和 UI 渲染
4. **可维护性**: 建立清晰的代码结构和文档

### 2.2 SMART 目标
- **具体 (Specific)**: 构建完整的共享模块基础设施
- **可衡量 (Measurable)**: 代码覆盖率 >80%，API 响应时间 <100ms
- **可实现 (Achievable)**: 基于现有 Flutter 生态系统
- **相关性 (Relevant)**: 支持铁板神数核心业务功能
- **时限性 (Time-bound)**: 持续迭代优化

## 3. 目标用户 / Target Audience

### 3.1 主要用户
- **应用开发者**: 使用 common 模块构建铁板神数功能
- **系统架构师**: 设计和维护整体应用架构
- **测试工程师**: 验证模块功能和性能

### 3.2 用户画像
- 具备 Flutter/Dart 开发经验
- 熟悉移动应用开发最佳实践
- 理解 Clean Architecture 设计原则

## 4. 用户故事 / User Stories

### 4.1 开发者用户故事
```
作为一个应用开发者
我希望能够轻松访问共享的数据模型和服务
以便快速构建新功能而不重复造轮子
```

### 4.2 架构师用户故事
```
作为一个系统架构师
我希望有一个清晰的模块边界和接口定义
以便维护系统的整体一致性和可扩展性
```

### 4.3 用户用户故事
```
作为一个最终用户
我希望应用响应迅速且数据准确
以便获得良好的使用体验
```

## 5. 功能需求 / Functional Requirements

### 5.1 数据库管理 (Database Management)
- **FR-DB-001**: 提供统一的数据库连接和配置管理
- **FR-DB-002**: 支持数据库迁移和版本控制
- **FR-DB-003**: 实现数据表的 CRUD 操作
- **FR-DB-004**: 提供事务管理和数据一致性保证

#### 核心表结构
1. **占卜类型表** (divination_types)
2. **面板表** (panels) 
3. **技能类别表** (skill_classes)
4. **占卜历史记录表** (divination_history_records)
5. **面板技能映射表** (panel_skill_class_mappers)

### 5.2 数据模型 (Data Models)
- **FR-DM-001**: 定义标准化的数据传输对象 (DTO)
- **FR-DM-002**: 提供数据验证和序列化功能
- **FR-DM-003**: 支持复杂数据类型的映射和转换

#### 核心数据模型
1. **基础占卜信息** (BasicDivinationInfo)
2. **位置数据模型** (SpLocationDatamodel)
3. **时区数据模型** (SpTimezoneDatamodel)
4. **四柱八字** (FourZhuEightChar)
5. **世界信息** (WorldInfo)

### 5.3 UI 组件 (UI Components)
- **FR-UI-001**: 提供可复用的 UI 组件库
- **FR-UI-002**: 支持主题和样式定制
- **FR-UI-003**: 实现响应式设计和适配

#### 核心 UI 组件
1. **占卜卡片组件** (DivinationCardWidget)
2. **时间选择组件** (DivinationDatetimeSelectionCard)
3. **城市选择器** (CityPickerBottomSheet)
4. **查询时间输入卡** (QueryTimeInputCard)
5. **八字选择卡** (EightCharsSelectionCard)

### 5.4 工具类和辅助功能 (Utilities)
- **FR-UT-001**: 提供日期时间处理工具
- **FR-UT-002**: 实现集合操作辅助函数
- **FR-UT-003**: 提供日志记录和调试工具
- **FR-UT-004**: 支持数据格式转换和验证

### 5.5 业务逻辑层 (Business Logic)
- **FR-BL-001**: 实现占卜相关的核心算法
- **FR-BL-002**: 提供数据访问对象 (DAO) 层
- **FR-BL-003**: 支持业务规则验证和处理

## 6. 非功能需求 / Non-Functional Requirements

### 6.1 性能要求 (Performance)
- **NFR-P-001**: 数据库查询响应时间 < 100ms
- **NFR-P-002**: UI 组件渲染时间 < 16ms (60fps)
- **NFR-P-003**: 内存使用优化，避免内存泄漏
- **NFR-P-004**: 支持大数据集的分页和懒加载

### 6.2 可用性要求 (Usability)
- **NFR-U-001**: 提供清晰的 API 文档和使用示例
- **NFR-U-002**: 错误信息友好且具有指导性
- **NFR-U-003**: 支持多语言国际化
- **NFR-U-004**: 遵循 Material Design 设计规范

### 6.3 可维护性要求 (Maintainability)
- **NFR-M-001**: 代码覆盖率 > 80%
- **NFR-M-002**: 遵循 Dart 代码规范和最佳实践
- **NFR-M-003**: 模块间低耦合，高内聚
- **NFR-M-004**: 提供完整的单元测试和集成测试

### 6.4 安全性要求 (Security)
- **NFR-S-001**: 敏感数据加密存储
- **NFR-S-002**: 输入数据验证和清理
- **NFR-S-003**: 防止 SQL 注入攻击
- **NFR-S-004**: 用户数据隐私保护

### 6.5 兼容性要求 (Compatibility)
- **NFR-C-001**: 支持 iOS 12+ 和 Android API 21+
- **NFR-C-002**: 兼容不同屏幕尺寸和分辨率
- **NFR-C-003**: 支持 Web 平台部署
- **NFR-C-004**: 向后兼容性保证

## 7. 架构设计 / Architecture Design

### 7.1 整体架构
```
┌─────────────────────────────────────────┐
│              Presentation Layer          │
│  ┌─────────────┐  ┌─────────────────────┐│
│  │   Widgets   │  │    ViewModels       ││
│  └─────────────┘  └─────────────────────┘│
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│              Business Layer              │
│  ┌─────────────┐  ┌─────────────────────┐│
│  │  Use Cases  │  │     Services        ││
│  └─────────────┘  └─────────────────────┘│
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│               Data Layer                 │
│  ┌─────────────┐  ┌─────────────────────┐│
│  │    DAOs     │  │    Data Models      ││
│  └─────────────┘  └─────────────────────┘│
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│            Infrastructure Layer          │
│  ┌─────────────┐  ┌─────────────────────┐│
│  │  Database   │  │      Utils          ││
│  └─────────────┘  └─────────────────────┘│
└─────────────────────────────────────────┘
```

### 7.2 核心组件
1. **AppDatabase**: 数据库连接和配置管理
2. **DAOs**: 数据访问对象，封装数据库操作
3. **DataModels**: 数据传输对象和实体模型
4. **Widgets**: 可复用的 UI 组件
5. **ViewModels**: 业务逻辑和状态管理
6. **Utils**: 工具类和辅助函数

### 7.3 数据流
```
User Input → Widget → ViewModel → UseCase → DAO → Database
                ↓         ↓         ↓       ↓        ↓
User Interface ← Widget ← ViewModel ← Data ← DAO ← Database
```

## 8. API 接口文档 / API Documentation

### 8.1 数据库 API

#### AppDatabase
```dart
class AppDatabase extends _$AppDatabase {
  // 数据库连接管理
  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase._();
  
  // 核心方法
  Future<void> initialize();
  Future<void> close();
  Future<void> migrate(int from, int to);
}
```

#### 核心 DAO 接口
```dart
// 占卜类型 DAO
abstract class DivinationTypesDao {
  Future<List<DivinationType>> getAllDivinationTypes();
  Future<DivinationType?> getDivinationTypeById(int id);
  Future<int> insertDivinationType(DivinationTypesCompanion companion);
  Future<bool> updateDivinationType(DivinationType type);
  Future<bool> softDeleteDivinationType(int id);
}

// 面板 DAO
abstract class PanelsDao {
  Future<List<Panel>> getAllPanels();
  Future<Panel?> getPanelById(int id);
  Future<List<Panel>> getPanelsByType(int typeId);
  Future<int> insertPanel(PanelsCompanion companion);
  Future<bool> updatePanel(Panel panel);
  Future<bool> softDeletePanel(int id);
}
```

### 8.2 UI 组件 API

#### 核心 Widget 接口
```dart
// 占卜卡片组件
class DivinationCardWidget extends StatelessWidget {
  const DivinationCardWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });
  
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
}

// 时间选择组件
class DivinationDatetimeSelectionCard extends StatefulWidget {
  const DivinationDatetimeSelectionCard({
    Key? key,
    required this.onDateTimeChanged,
    this.initialDateTime,
  });
  
  final Function(DateTime) onDateTimeChanged;
  final DateTime? initialDateTime;
}
```

### 8.3 工具类 API

#### 日期时间工具
```dart
class SolarLunarDatetimeHelper {
  // 公历转农历
  static LunarDate solarToLunar(DateTime solar);
  
  // 农历转公历
  static DateTime lunarToSolar(LunarDate lunar);
  
  // 获取节气信息
  static SolarTerm getSolarTerm(DateTime date);
}

// 儒略日转换器
class JulianDayConverter {
  static double dateTimeToJulianDay(DateTime dateTime);
  static DateTime julianDayToDateTime(double julianDay);
}
```

## 9. 数据模型规范 / Data Model Specifications

### 9.1 核心实体模型

#### 基础占卜信息
```dart
class BasicDivinationInfo {
  final int? id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  
  // 构造函数、序列化方法等
}
```

#### 四柱八字
```dart
class FourZhuEightChar {
  final String yearZhu;    // 年柱
  final String monthZhu;   // 月柱
  final String dayZhu;     // 日柱
  final String hourZhu;    // 时柱
  
  // 天干地支相关方法
  String get yearTianGan;
  String get yearDiZhi;
  // ... 其他属性和方法
}
```

### 9.2 枚举定义

#### 核心枚举类型
```dart
// 日期时间类型
enum DatetimeType {
  solar,    // 公历
  lunar,    // 农历
  julian,   // 儒略日
}

// 地支枚举
enum DiZhi {
  zi, chou, yin, mao, chen, si,
  wu, wei, shen, you, xu, hai
}

// 二十八星宿
enum TwentyEightConstellations {
  jiao, kang, di, fang, xin, wei, ji,
  // ... 其他星宿
}
```

## 10. 成功指标 / Success Metrics

### 10.1 技术指标
- **代码质量**: 代码覆盖率 > 80%，静态分析评分 > 90
- **性能指标**: API 响应时间 < 100ms，UI 渲染 60fps
- **稳定性**: 崩溃率 < 0.1%，内存泄漏为 0
- **可维护性**: 圈复杂度 < 10，代码重复率 < 5%

### 10.2 业务指标
- **开发效率**: 新功能开发时间减少 30%
- **代码复用**: 共享组件使用率 > 70%
- **缺陷率**: 生产环境缺陷 < 1 个/千行代码
- **文档完整性**: API 文档覆盖率 100%

### 10.3 用户体验指标
- **响应速度**: 页面加载时间 < 2s
- **易用性**: 开发者满意度 > 4.5/5
- **稳定性**: 应用无响应率 < 0.5%

## 11. 风险评估 / Risk Assessment

### 11.1 技术风险
| 风险项 | 概率 | 影响 | 缓解策略 |
|--------|------|------|----------|
| 数据库迁移失败 | 中 | 高 | 完善的备份和回滚机制 |
| 性能瓶颈 | 中 | 中 | 性能监控和优化 |
| 第三方依赖更新 | 高 | 低 | 版本锁定和兼容性测试 |

### 11.2 业务风险
| 风险项 | 概率 | 影响 | 缓解策略 |
|--------|------|------|----------|
| 需求变更频繁 | 高 | 中 | 敏捷开发和模块化设计 |
| 团队人员变动 | 中 | 中 | 完善文档和知识传承 |
| 时间压力 | 中 | 高 | 合理的项目规划和优先级 |

## 12. 开发计划 / Development Plan

### 12.1 里程碑
- **Phase 1**: 核心数据库和模型完成 (已完成)
- **Phase 2**: UI 组件库建设 (进行中)
- **Phase 3**: 工具类和辅助功能 (计划中)
- **Phase 4**: 性能优化和测试 (计划中)

### 12.2 优先级
1. **高优先级**: 数据库稳定性、核心 API
2. **中优先级**: UI 组件完善、性能优化
3. **低优先级**: 文档完善、工具类扩展

## 13. 未来规划 / Future Considerations

### 13.1 技术演进
- **微服务架构**: 考虑拆分为更细粒度的服务
- **云原生**: 支持容器化部署和云服务集成
- **AI 集成**: 集成机器学习算法优化占卜准确性

### 13.2 功能扩展
- **实时同步**: 支持多设备数据同步
- **离线支持**: 增强离线功能和数据缓存
- **插件系统**: 支持第三方插件和扩展

### 13.3 生态建设
- **开发者工具**: 提供调试和开发辅助工具
- **社区支持**: 建立开发者社区和文档站点
- **标准化**: 制定行业标准和最佳实践

## 14. 附录 / Appendix

### 14.1 术语表
- **DAO**: Data Access Object，数据访问对象
- **DTO**: Data Transfer Object，数据传输对象
- **ORM**: Object-Relational Mapping，对象关系映射
- **Clean Architecture**: 清洁架构，一种软件架构模式

### 14.2 参考资料
- Flutter 官方文档: https://flutter.dev/docs
- Drift 数据库文档: https://drift.simonbinder.eu/
- Clean Architecture 原则: https://blog.cleancoder.com/

### 14.3 版本历史
- **v1.0.0**: 初始版本，基础功能完成
- **v1.1.0**: UI 组件库扩展
- **v1.2.0**: 性能优化和错误修复

---

**文档版本**: 1.0.0  
**创建日期**: 2025-09-20  
**最后更新**: 2025-09-20  
**维护者**: Trae AI Assistant  
**审核状态**: ✅通过