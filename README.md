# Xuan (玄学)

中国传统术数研究与实践平台，基于 Flutter 构建，涵盖奇门遁甲、七政四余、太乙神数、大六壬、铁版神数等多个术数系统。

## 项目架构

本项目采用 **Git Submodules** 架构，每个术数模块为独立仓库，支持独立开发与集成测试。

```
xuan/                              # 主项目（集成层）
├── lib/                           # 主应用代码、路由、Demo 首页
├── assets/                        # 静态资源（星历、地理、图标等）
│
├── common/          (submodule)   # 共享模块：数据库、枚举、组件、工具
├── storage/         (submodule)   # 持久化层（core / drift / firebase）
├── account/         (submodule)   # 账户与认证模块
│
├── qimendunjia/     (submodule)   # 奇门遁甲
├── qizhengsiyu/     (submodule)   # 七政四余
├── taiyishenshu/    (submodule)   # 太乙神数
├── daliuren/        (submodule)   # 大六壬
└── tiebanshenshu/   (submodule)   # 铁版神数
```

### 依赖层级

```
Layer 0  xuan-storage          持久化抽象与实现
             ↑
Layer 1  xuan-common           共享枚举、模型、数据库、UI 组件
             ↑
Layer 2  xuan-account          账户模块
         xuan-qimendunjia      奇门遁甲
         xuan-qizhengsiyu      七政四余
         xuan-taiyishenshu     太乙神数
         xuan-daliuren         大六壬
         xuan-tiebanshenshu    铁版神数
             ↑
Layer 3  xuan                  主项目（路由集成、Provider 初始化）
```

## 子模块仓库

| 模块 | 仓库 | 说明 |
|------|------|------|
| common | [xuan-common](https://github.com/weijingtai/xuan-common) | 共享数据库（Drift）、枚举（天干地支五行等）、UI 组件、天文计算工具 |
| storage | [xuan-storage](https://github.com/weijingtai/xuan-storage) | 持久化抽象层（core）、Drift 实现、Firebase 实现 |
| account | [xuan-account](https://github.com/weijingtai/xuan-account) | Firebase Auth 登录、用户资料管理 |
| qimendunjia | [xuan-qimendunjia](https://github.com/weijingtai/xuan-qimendunjia) | 奇门遁甲排盘与推演 |
| qizhengsiyu | [xuan-qizhengsiyu](https://github.com/weijingtai/xuan-qizhengsiyu) | 七政四余星盘，基于 Swiss Ephemeris 天文计算 |
| taiyishenshu | [xuan-taiyishenshu](https://github.com/weijingtai/xuan-taiyishenshu) | 太乙神数排盘 |
| daliuren | [xuan-daliuren](https://github.com/weijingtai/xuan-daliuren) | 大六壬四课三传推演 |
| tiebanshenshu | [xuan-tiebanshenshu](https://github.com/weijingtai/xuan-tiebanshenshu) | 铁版神数考刻与条文推算 |

## 快速开始

### 环境要求

- Flutter SDK >= 3.0.2
- Dart SDK >= 3.0.2

### 克隆与运行（完整项目）

```bash
# 克隆主项目（含所有子模块）
git clone --recursive https://github.com/weijingtai/xuan.git
cd xuan

# 安装依赖
flutter pub get

# 运行
flutter run
```

### 独立开发子模块

子模块可脱离主项目独立开发，通过 git 依赖引用 common：

```bash
# 以奇门遁甲为例
git clone https://github.com/weijingtai/xuan-qimendunjia.git
cd xuan-qimendunjia
flutter pub get
```

### 更新子模块

```bash
# 更新所有子模块到最新
git submodule update --remote

# 更新单个子模块
git submodule update --remote qimendunjia
```

## 功能导航

应用启动后进入 Demo 首页（路由 `/demo`），按模块分类展示所有功能入口：

### 三式术数

| 功能 | 路由 |
|------|------|
| 奇门遁甲 | `/qimendunjia` |
| 奇门遁甲 MVVM | `/qimendunjia/mvvm` |
| 七政四余 | `/qizhengsiyu/panel` |
| 太乙神数 | `/taiyishenshu` |
| 大六壬 | `/daliuren` |
| 大六壬 (旧版) | `/daliuren/old` |
| 大六壬 (开发) | `/daliuren/dev` |

### 铁版神数

| 功能 | 路由 |
|------|------|
| 皇极 V2 演示 | `/tiebanshenshu/huang_ji_v2_demo` |
| 策略演示 | `/tiebanshenshu/strategy_demo` |
| 四门 gun 法 | `/tiebanshenshu/four_doors_and_gun_fa` |
| 六亲考刻选择 | `/tiebanshenshu/liuqinkaoke/selection` |
| 考刻交互 | `/tiebanshenshu/kaoke` |
| 考订六亲 | `/tiebanshenshu/kao_ding_liu_qin` |

### 通用工具

| 功能 | 路由 |
|------|------|
| 开发入口 | `/common/dev` |
| 农历信息卡 | `/common/dev/lunar_info_card` |
| 占测历史 | `/common/history` |
| 四柱编辑 | `/common/four_zhu_edit` |
| 可编辑卡片演示 | `/common/editable_card_demo` |
| 命运日历 | `/common/fate_calender` |

### 开发测试

| 功能 | 路由 |
|------|------|
| 一年时间轮 | `/one_year` |
| 小部件开发 | `/widget_dev` |

## 技术栈

### 核心框架

| 技术 | 用途 |
|------|------|
| Flutter | 跨平台 UI（iOS / Android / Web） |
| Provider | 状态管理 |
| Drift | 本地数据库 ORM（SQLite） |
| Firebase | 云端认证、Firestore 数据同步 |

### 术数计算

| 依赖 | 用途 |
|------|------|
| tyme | 中国农历、干支、节气计算 |
| sweph | Swiss Ephemeris 天文星历计算（七政四余核心） |

### 数据与序列化

| 依赖 | 用途 |
|------|------|
| json_serializable | JSON 模型代码生成 |
| protobuf | Protocol Buffer 二进制数据（地理、颜色） |
| build_runner | 代码生成驱动 |

### UI 组件

| 依赖 | 用途 |
|------|------|
| responsive_framework | 响应式布局适配 |
| google_fonts | 字体管理 |
| lottie / dotlottie_loader | Lottie 动画 |
| flutter_map | 地图展示与地理定位 |
| board_datetime_picker | 日期时间选择 |

## 代码生成

修改带有 `@JsonSerializable()` 注解的模型类或 Drift 表定义后，需重新生成代码：

```bash
# 在对应模块目录下执行
flutter packages pub run build_runner build --delete-conflicting-outputs
```

涉及代码生成的文件类型：
- `@JsonSerializable()` 注解类 → 生成 `.g.dart`
- Drift 表定义和 DAO → 生成 `.g.dart`

## 数据资源

```
assets/
├── ephe/                 # Swiss Ephemeris 天文星历数据
├── da_liu_ren/           # 大六壬：御定大六壬、甲午庚牛羊阴阳数据（~6.7MB）
├── qi_men_dun_jia/       # 奇门遁甲排盘数据
├── qizhengsiyu/          # 七政四余：恒星、黄道、赤道数据（17 个 JSON）
├── shen_sha/             # 神煞规则数据（23+ 个文件）
├── dataset/              # 地理数据
│   ├── geo/              # GeoJSON 地区边界（2,888 个文件）
│   └── world.sqlite3     # 世界地理 SQLite 数据库（~20MB）
├── icons/                # 图标资源
├── planets/              # 行星图标
├── lotties/              # Lottie 动画
└── backgrounds/          # 背景图
```

## 多平台支持

| 平台 | 数据库 | 状态 |
|------|--------|------|
| Android | Drift + SQLite (native) | 支持 |
| iOS | Drift + SQLite (native) | 支持 |
| Web | Drift + SQLite (WASM) | 支持 |

数据库连接在 `common/lib/database/connection.dart` 中根据平台自动选择实现。

## 构建

```bash
flutter build apk          # Android
flutter build ios           # iOS
flutter build web           # Web
```

## 项目结构（主项目 lib/）

```
lib/
├── main.dart                      # 应用入口：Firebase 初始化、Provider 注册、数据库初始化
├── NavigatorGenerator.dart        # 路由生成器：聚合所有子模块路由
├── firebase_options.dart          # Firebase 配置
├── app_colors.dart                # 天干地支配色
├── routes.dart                    # 路由定义
├── ephe_io_helper.dart            # 天文数据加载（native）
├── ephe_web_helper.dart           # 天文数据加载（web）
├── pages/
│   ├── demo_home_page.dart        # Demo 导航首页
│   ├── root_page.dart             # 根页面
│   ├── one_year_circle.dart       # 一年时间轮
│   └── cross_platform_main_page.dart
├── fate/                          # 飞仙算法
├── models/                        # 主项目模型
├── utils/                         # 工具函数
└── widgets/                       # 主项目组件
```

## Storage 模块结构

`xuan-storage` 采用依赖倒置设计，支持灵活切换存储后端：

```
xuan-storage/
├── core/       # persistence_core：抽象接口（Repository、SyncCoordinator）
├── drift/      # persistence_drift：Drift/SQLite 本地存储实现
└── firebase/   # persistence_firebase：Firestore 云端存储实现
```

扩展新的存储后端（如 AWS）只需在 `xuan-storage` 中添加新目录实现 core 接口。

## Common 模块概览

`xuan-common` 是所有术数模块的共享基础，包含：

- **database/** — Drift ORM 数据库（AppDatabase + WorldInfoDatabase）、DAO、类型转换器
- **enums/** — 32 个枚举文件：天干、地支、五行、十神、甲子、二十四节气、星体等
- **datamodel/** — 30+ 数据模型（占测记录、求测人、时间模型等）
- **features/** — 四柱、大运、流年、胎元等计算功能
- **widgets/** — 可复用 UI 组件（八字卡片、日期选择、城市选择等）
- **painter/** — 自定义 Canvas 绘制器（圆环、分割圆等）
- **datasource/** — 地理数据、模板数据、Protocol Buffer 数据源
- **viewmodels/** — 视图模型（时区定位、开发入口等）

## 许可证

本项目仅供学习研究使用。
