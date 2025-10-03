# 奇门遁甲双架构实现说明

## 概述

本项目现已支持两种架构实现,两者功能相同但设计理念不同,便于学习和对比不同的架构模式。

## 架构对比

### 1. 传统架构 (路由: `/qimendunjia`)

**文件位置:**
- ViewModel: `lib/pages/shi_jia_qi_men_view_model.dart`
- View: `lib/pages/scalable_shi_jia_qi_men_view_page.dart`
- 路由配置: `lib/navigator.dart`

**特点:**
- ✓ 简单直接的状态管理
- ✓ ViewModel 直接处理业务逻辑
- ✓ 适合快速开发和原型验证
- ✓ 代码结构扁平,易于理解

**架构层级:**
```
View (UI)
  ↓
ViewModel (状态 + 业务逻辑)
  ↓
Utils/Models (工具类和数据模型)
```

### 2. MVVM + UseCase 架构 (路由: `/qimendunjia/mvvm`)

**文件位置:**
- **Domain层** (`lib/domain/`):
  - Entities: `lib/domain/entities/` - 业务实体
  - Repository接口: `lib/domain/repositories/` - 数据操作契约
  - UseCases: `lib/domain/usecases/` - 业务用例逻辑
    - `calculate_ju_usecase.dart` - 计算局数用例
    - `arrange_pan_usecase.dart` - 排盘用例
    - `select_gong_usecase.dart` - 选择宫位用例

- **Data层** (`lib/data/`):
  - DataSources: `lib/data/datasources/` - 数据源(JSON/计算器)
  - Repository实现: `lib/data/repositories/` - 仓储接口实现

- **Presentation层** (`lib/presentation/`):
  - ViewModel: `lib/presentation/viewmodels/qimen_viewmodel.dart`
  - View: `lib/presentation/pages/qimen_mvvm_page.dart`

- **依赖注入** (`lib/di/`):
  - ServiceLocator: `lib/di/service_locator.dart` - 管理所有依赖

**特点:**
- ✓ Clean Architecture 分层架构
- ✓ Domain层独立,不依赖外层
- ✓ UseCase 封装单一业务场景
- ✓ Repository 模式分离数据层
- ✓ 易于测试和维护
- ✓ 适合大型项目和团队协作

**架构层级:**
```
View (UI)
  ↓
ViewModel (状态管理)
  ↓
UseCase (业务用例)
  ↓
Repository接口 (Domain层)
  ↑
Repository实现 (Data层)
  ↓
DataSource (数据源)
```

## 使用方式

### 启动应用

运行 `flutter run` 后,首页会显示架构选择页面:

1. **传统架构版本** - 点击进入旧版实现
2. **MVVM+UseCase版本** - 点击进入新版实现

### 切换架构

在任何页面都可以通过返回按钮回到首页重新选择架构。

## 代码对比示例

### 传统架构 - 创建排盘

```dart
// ShiJiaQiMenViewModel
void createShiJiaQiMen(PlateType plateType, DateTime dateTime,
                       ShiJiaJu shiJiaJu, PanSettings settings) {
  // 直接在 ViewModel 中处理所有业务逻辑
  final calculator = QiMenJuCalculator(dateTime, shiJiaJu);
  final pan = calculator.calculate();
  _shiJiaQiMen = pan;
  notifyListeners();
}
```

### MVVM+UseCase架构 - 创建排盘

```dart
// QiMenViewModel
Future<void> calculateAndArrangePan({
  required DateTime dateTime,
  required ArrangeType arrangeType,
  required PlateType plateType,
}) async {
  // 1. 通过UseCase计算局数
  final ju = await _calculateJuUseCase.execute(
    CalculateJuParams(dateTime: dateTime, arrangeType: arrangeType),
  );

  // 2. 通过UseCase排盘
  final pan = await _arrangePanUseCase.execute(
    ArrangePanParams(ju: ju, plateType: plateType, settings: _panSettings),
  );

  _currentPan = pan;
  notifyListeners();
}

// CalculateJuUseCase (独立的业务用例)
class CalculateJuUseCase extends UseCase<ShiJiaJu, CalculateJuParams> {
  final QiMenCalculatorRepository _repository;

  Future<ShiJiaJu> execute(CalculateJuParams params) async {
    return await _repository.calculateJu(
      dateTime: params.dateTime,
      arrangeType: params.arrangeType,
    );
  }
}
```

## 依赖注入配置

MVVM+UseCase 架构使用 ServiceLocator 管理依赖:

```dart
void main() {
  // 初始化依赖注入
  serviceLocator.init();
  runApp(const QiMenDunJiaApp());
}
```

ServiceLocator 自动注册:
- DataSources (数据源)
- Repositories (仓储)
- UseCases (用例)
- ViewModels (视图模型工厂)

## 架构选择建议

### 选择传统架构,如果:
- 项目规模较小
- 团队成员较少
- 需要快速迭代
- 业务逻辑相对简单

### 选择MVVM+UseCase架构,如果:
- 项目规模较大
- 团队成员较多
- 需要高度可测试性
- 业务逻辑复杂
- 需要多端复用业务逻辑
- 追求高度解耦和可维护性

## 技术栈

### 共同使用
- Flutter 3.x
- Provider (状态管理)
- Dart 3.x

### MVVM+UseCase额外使用
- Clean Architecture 原则
- Repository 模式
- UseCase 模式
- 依赖注入 (ServiceLocator)

## 目录结构

```
lib/
├── main.dart                    # 应用入口 + 架构选择页面
├── navigator.dart               # 路由配置(支持两种架构)
├── di/                          # 依赖注入
│   └── service_locator.dart
├── domain/                      # Domain层(MVVM+UseCase)
│   ├── entities/               # 业务实体
│   ├── repositories/           # 仓储接口
│   └── usecases/               # 业务用例
├── data/                        # Data层(MVVM+UseCase)
│   ├── datasources/            # 数据源
│   ├── models/                 # 数据模型
│   └── repositories/           # 仓储实现
├── presentation/                # Presentation层(MVVM+UseCase)
│   ├── viewmodels/             # ViewModel
│   └── pages/                  # UI页面
└── pages/                       # 传统架构页面
    ├── shi_jia_qi_men_view_model.dart
    └── scalable_shi_jia_qi_men_view_page.dart
```

## 开发指南

### 添加新功能 - 传统架构
1. 在 ViewModel 中添加业务方法
2. 在 View 中调用 ViewModel 方法
3. 使用 notifyListeners() 通知UI更新

### 添加新功能 - MVVM+UseCase架构
1. 在 Domain层定义 Entity
2. 在 Domain层定义 Repository接口
3. 创建 UseCase 封装业务逻辑
4. 在 Data层实现 Repository
5. 在 ViewModel 中调用 UseCase
6. 在 View 中使用 ViewModel

## 测试

### 传统架构测试
- 测试 ViewModel 业务逻辑
- Widget 测试

### MVVM+UseCase架构测试
- **Unit测试**: 独立测试每个 UseCase
- **Repository测试**: Mock DataSource 测试 Repository
- **ViewModel测试**: Mock UseCase 测试 ViewModel
- **Widget测试**: UI组件测试

## 注意事项

1. **状态同步**: 两种架构完全独立,不共享状态
2. **数据持久化**: 如需要数据持久化,需在两个架构中分别实现
3. **性能**: MVVM+UseCase 有轻微性能开销,但可忽略不计
4. **学习曲线**: MVVM+UseCase 需要理解更多概念

## 总结

- **传统架构**: 简单、直接、快速,适合小型项目
- **MVVM+UseCase**: 规范、解耦、可测试,适合大型项目

两种架构各有优劣,根据项目实际情况选择合适的架构。
