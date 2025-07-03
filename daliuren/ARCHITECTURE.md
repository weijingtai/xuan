# 大六壬 (DaLiuRen) 子项目架构文档

## 1. 架构概述 (Architecture Overview)

本 `daliuren` 子项目采用的是一种受 **Clean Architecture** 启发的 **MVVM (Model-View-ViewModel) + Repository + Use Cases** 架构模式。目标是实现关注点分离、提高代码的可测试性、可维护性和可扩展性。

**核心分层理念:**

*   **表现层 (Presentation Layer):** 用户界面 (Flutter Widgets) 和 ViewModel。负责展示数据和处理用户输入。
*   **领域层 (Domain Layer):** 包含核心业务逻辑、领域实体、用例 (Use Cases) 和仓库接口 (Repository Interfaces)。此层不依赖于任何外部层。
*   **数据层 (Data Layer):** 负责数据的获取和存储。包含仓库实现 (Repository Implementations)、数据源 (DataSources - 本地和远程) 以及数据传输对象 (DTOs)。
*   **核心/通用层 (Core/Common):** 包含整个应用可能用到的基础工具类、常量、自定义错误/异常等。

**层级依赖关系:**

```
+---------------------+     +---------------------+     +---------------------+
| Presentation Layer  | --> |    Domain Layer     | --> |     Data Layer      |
| (View, ViewModel)   |     | (Entities, UseCases,|     | (Repositories Impl, |
|                     |     |  Repo Interfaces,   |     |  DataSources, DTOs)|
|                     |     |  Domain Services)   |     |                     |
+---------------------+     +---------------------+     +---------------------+
          ^                                                       |
          |                                                       |
          +-------------------依赖注入 (GetIt)--------------------+
```

*   箭头表示依赖方向。表现层依赖领域层，领域层依赖数据层（通过接口）。
*   依赖注入 (`get_it`) 用于解耦各层之间的具体实现。

## 2. 各层职责 (Layer Responsibilities)

### 2.1. 表现层 (Presentation Layer) - `lib/presentation/`

*   **View (Widgets) - `lib/presentation/pages/` 和 `lib/presentation/widgets/`:**
    *   负责渲染UI，展示从 ViewModel 获取的数据。
    *   将用户交互事件传递给 ViewModel 进行处理。
    *   不包含任何业务逻辑。
*   **ViewModel - `lib/presentation/viewmodels/`:**
    *   充当 View 和领域层之间的桥梁。
    *   持有并管理UI状态 (`MyHomePageState`)。
    *   调用 UseCases 执行业务操作。
    *   将领域层返回的数据转换为UI可以直接使用的格式。
    *   使用 `ChangeNotifier` (配合 `provider` 包) 通知 View 更新。

### 2.2. 领域层 (Domain Layer) - `lib/domain/`

*   **Entities - `lib/domain/entities/`:**
    *   核心业务对象，代表应用的关键概念 (如 `LiuRenPan`, `YuDingEntry`)。
    *   不包含任何与特定框架或数据源相关的代码。
*   **Use Cases (Interactors) - `lib/domain/usecases/`:**
    *   封装单一的业务操作或用户场景 (如 `CalculateLiuRenPanUseCase`, `InitializeDatabaseUseCase`)。
    *   协调对 Repository 接口的调用。
    *   通常是无状态的。
*   **Repository Interfaces - `lib/domain/repositories/`:**
    *   定义数据操作的抽象契约 (如 `LiuRenRepository`)。
    *   领域层依赖这些接口，而不是具体的实现，实现依赖倒置原则。
*   **Domain Services - `lib/domain/services/`:**
    *   封装复杂的、可复用的领域逻辑，这些逻辑可能不适合放在单个 UseCase 或 Entity 中 (如 `LiuRenCalculationService` 用于核心排盘算法)。

### 2.3. 数据层 (Data Layer) - `lib/data/`

*   **Repository Implementations - `lib/data/repositories/`:**
    *   `LiuRenRepository` 接口的具体实现 (`LiuRenRepositoryImpl`)。
    *   负责协调来自一个或多个数据源的数据。
    *   进行数据模型转换 (DTOs/DBOs 到 Domain Entities)。
*   **DataSources - `lib/data/datasources/`:**
    *   **Local (`local/`)**:
        *   `AppDatabase` (`drift_database.dart`): Drift 数据库定义，包含表结构和 TypeConverter。
        *   `LiuRenDao` (`dao/liuren_dao.dart`): Data Access Object，提供对 Drift 数据库表的 CRUD 操作。
        *   `LiuRenLocalDataSource`: 本地数据源接口及其实现，使用 `LiuRenDao` 与数据库交互。
    *   **Remote (`remote/`)**: 远程数据源的占位符，未来可用于与网络 API 交互。
*   **Data Models (DTOs) - `lib/data/models/`:**
    *   数据传输对象，直接映射外部数据源的结构 (如 JSON 文件内容，Drift 表结构)。
    *   通常包含 `fromJson`/`toJson` 方法，使用 `json_serializable` 生成。

### 2.4. 核心/通用层 (Core/Common) - `lib/core/`

*   **`lib/core/errors/failures.dart`**: 定义通用的 `Failure` 类及其子类，用于错误处理。
*   **`lib/core/usecase/usecase.dart`**: 定义基础的 `UseCase` 接口。
*   **`lib/core/enums/`**, **`lib/core/constants/`**, **`lib/core/utils/`**: 存放通用枚举、常量和工具函数。
*   项目还依赖外部的 `common` 包，其中也包含了一些共享的枚举和 Widgets。

## 3. 数据流示例 (Data Flow Example: 按时间排盘)

1.  **View (`MyHomePage`):** 用户选择日期时间，点击“依时间排盘”按钮。
2.  **View:** 调用 `ViewModel.getPanByTime(selectedDateTime)`。
3.  **ViewModel (`MyHomePageViewModel`):**
    *   更新UI状态为加载中 (`state.copyWith(isLoadingPan: true)`).
    *   创建 `PanInput.byTime(dateTime: selectedDateTime)` 对象。
    *   调用 `CalculateLiuRenPanUseCase.call(panInput)`。
4.  **UseCase (`CalculateLiuRenPanUseCase`):**
    *   调用 `LiuRenRepository.getLiuRenPan(panInput)`。
5.  **Repository (`LiuRenRepositoryImpl`):**
    *   判断 `panInput.inputType`。
    *   对于 `TIME_INPUT`:
        *   **(TODO: 此处调用 `LiuRenCalculationService` 执行核心排盘算法)**。
        *   该服务会计算四柱、月将、贵人、天地盘、四课、三传、课体等。
        *   服务返回 `LiuRenPan` 领域实体。
    *   (如果输入是 `GANZHI_INPUT` 且匹配预设盘):
        *   调用 `LiuRenLocalDataSource.getPresetPan(...)`。
        *   将返回的 `PresetPanEntryDb` (DBO) 映射为 `LiuRenPan` 领域实体。
6.  **DataSource (`LiuRenLocalDataSourceImpl` - 仅在预设盘或获取基础数据时):**
    *   调用 `LiuRenDao` 的查询方法 (如 `findPresetPan`, `findJuMapping`)。
7.  **DAO (`LiuRenDao`):**
    *   执行 Drift 查询，从 SQLite 数据库获取数据。
8.  **数据返回:** 数据沿调用链返回：DAO -> DataSource -> Repository -> UseCase -> ViewModel。
9.  **ViewModel:**
    *   接收到 `Either<Failure, LiuRenPan>`。
    *   若成功 (Right - `LiuRenPan`):
        *   更新状态: `state.copyWith(isLoadingPan: false, liuRenPan: pan)`。
        *   根据 `pan` 的信息 (日干支、干上神) 调用 `_fetchYuDingEntry`。
            *   `_fetchYuDingEntry` 内部调用 `GetYuDingEntryUseCase`。
            *   `GetYuDingEntryUseCase` -> `LiuRenRepository.getYuDingEntry` -> `DataSource` -> `DAO`。
            *   获取到 `YuDingEntry` 后更新 ViewModel 状态。
    *   若失败 (Left - `Failure`):
        *   更新状态: `state.copyWith(isLoadingPan: false, error: failure)`。
10. **View:** 响应 ViewModel 状态变化，更新UI以显示排盘结果、课义或错误信息。

## 4. 核心组件说明 (Key Component Descriptions)

*   **`MyHomePageViewModel`:** 管理 `MyHomePage` 的UI状态，处理用户交互，通过调用UseCases执行业务逻辑，并为View准备展示数据。
*   **`LiuRenRepository` (及 `LiuRenRepositoryImpl`):** 数据访问的抽象层和实现。负责从本地数据源获取六壬相关数据（如预设盘、课体释义、局数映射），并进行 DTO/DBO 到领域实体的转换。未来也可能集成远程数据源。
*   **`LiuRenLocalDataSource` (及 `LiuRenLocalDataSourceImpl`):** 封装了对本地 Drift 数据库的所有直接操作，通过 `LiuRenDao` 实现。
*   **`AppDatabase` (Drift):** 定义了应用的 SQLite 数据库结构，包括表 (`JuMappings`, `YuDingEntries`, `PresetPans`, `DbInitializationFlags`) 和用于存储复杂对象的 TypeConverter。
*   **`LiuRenCalculationService`:** (当前为占位符) 计划用于封装核心的、复杂的六壬排盘算法，实现业务逻辑与数据访问的进一步分离。
*   **UseCases:**
    *   `InitializeDatabaseUseCase`: 负责从JSON资产文件加载初始数据并存入数据库。
    *   `CalculateLiuRenPanUseCase`: 负责根据输入参数（时间或干支）获取或计算完整的六壬盘。
    *   `GetYuDingEntryUseCase`: 负责获取《御定大六壬》的特定课体释义。

## 5. 数据库 (Database - Drift)

*   **技术选型:** 使用 [Drift](https://drift.simonbinder.eu/) (原 Moor) 作为本地响应式持久化库。
*   **主要数据表:**
    *   `JuMappings`: 存储日干支、时地支、阴阳遁到局数的映射关系 (源自 `ju_mapper.json`)。
    *   `YuDingEntries`: 存储《御定大六壬》的课体释义 (源自 `御定大六壬.json`)。
    *   `PresetPans`: 存储预设的六壬盘数据 (源自 `甲午庚牛羊_阳.json` 和 `甲午庚牛羊_阴.json`)。
    *   `DbInitializationFlags`: 用于标记数据库是否已使用资产数据进行初始化。
*   **TypeConverters:** 用于将复杂的 Dart 对象 (如 `Map<String, DaLiuRenGongDataModel>`) 序列化为 JSON 字符串存入数据库，并在读取时反序列化回来。
*   **数据初始化:** `InitializeDatabaseUseCase` 在应用首次启动（或数据库未初始化时）从 `assets/da_liu_ren/` 目录下的 JSON 文件读取数据，通过 Repository 和 DataSource 存入 Drift 数据库。

## 6. 依赖注入 (Dependency Injection)

*   **技术选型:** 使用 [get_it](https://pub.dev/packages/get_it) 包作为服务定位器 (Service Locator) 实现依赖注入。
*   **设置:**
    *   `lib/di/service_locator.dart`: 定义 `setupServiceLocator()` 函数，在此函数中注册所有依赖项 (单例、工厂等)，包括数据库、DAO、数据源、仓库、用例、服务和视图模型。
    *   `lib/main.dart`: 在 `main()` 函数中调用 `await setupServiceLocator()` 进行初始化。ViewModel 通过 `ChangeNotifierProvider(create: (_) => sl<MyHomePageViewModel>())` 从 `get_it` (别名 `sl`) 获取并提供给 Widget 树。

## 7. 代码生成 (Code Generation)

项目大量使用代码生成来减少样板代码并确保类型安全：

*   **Drift (`drift_dev`):**
    *   根据 `lib/data/datasources/local/drift_database.dart` 中的表定义和 DAO 注解，生成 `.g.dart` 文件，包含数据库伴侣类 (Companions)、数据类 (DBOs)、以及 DAO 的实现。
*   **JSON Serialization (`json_serializable`):**
    *   用于 `lib/data/models/` 目录下的 DTOs，根据 `@JsonSerializable()` 注解和字段定义，生成 `fromJson` 和 `toJson` 方法到对应的 `.g.dart` 文件中。
*   **Mockito (`mockito`):**
    *   用于单元测试中生成 Mock 对象。在测试文件中使用 `@GenerateMocks([...])` 注解，生成 `.mocks.dart` 文件。
*   **构建命令:**
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
    此命令用于运行所有代码生成器。

## 8. TODOs / 后续工作 (Future Work)

*   **核心算法实现:** 在 `LiuRenCalculationService` 中完整实现六壬排盘的核心算法逻辑 (当前为占位符)。
*   **UI 完善:**
    *   详细实现 `PanDisplayWidget` 及其子组件，以美观、准确地展示六壬盘的各个部分 (天地盘、四课、三传、神将等)。
    *   完善 `YuDingDisplayWidget` 的展示。
    *   优化整体 UI/UX。
*   **测试覆盖:**
    *   编写更全面的单元测试，覆盖 ViewModels, UseCases, Repositories, Services (尤其是排盘算法)。
    *   编写针对 Drift DAO 和数据库交互的集成测试。
    *   考虑 Widget 测试。
*   **错误处理:** 进一步细化和完善错误处理机制，为用户提供更友好的错误提示。
*   **状态管理:** 当前 `MyHomePageViewModel` 使用 `ChangeNotifier`。对于更复杂的页面或全局状态，可以评估是否需要引入如 Riverpod 等更高级的状态管理方案。
*   **特性扩展:**
    *   历史排盘记录的保存与查看。
    *   用户自定义设置 (如贵人起法选择等)。
    *   详细的课体分析和解释。
    *   (如果适用) 集成远程 API 以获取更新的数据或释义。
*   **代码清理:** 移除 `lib/model/` 目录下剩余未迁移的文件 (如 `da_liu_ren_ke_pan.dart`, `da_liu_ren_panel.dart` 等)，将其逻辑重构并整合到新的架构中。

```
