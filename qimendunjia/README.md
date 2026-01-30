# 奇门遁甲 - 快速启动指南

## 项目说明

本项目实现了两套完整的架构:

1. **传统架构** - ViewModel + UI 直接通信
2. **MVVM+UseCase架构** - Clean Architecture 分层设计

## 快速启动

### 1. 安装依赖

```bash
cd qimendunjia
flutter pub get
```

### 2. 运行应用

```bash
flutter run
```

### 3. 选择架构

启动后会看到架构选择页面,可以选择:
- **传统架构版本** (蓝色卡片)
- **MVVM+UseCase版本** (绿色卡片)

## 路由配置

应用支持以下路由:

- `/` - 架构选择首页
- `/qimendunjia` - 传统架构实现
- `/qimendunjia/mvvm` - MVVM+UseCase 架构实现

## 功能特性

### 传统架构版本
- ✓ 完整的奇门遁甲排盘功能
- ✓ 支持转盘/飞盘
- ✓ 支持拆补/置润/茅山/阴盘等算法
- ✓ 九宫克应格局显示
- ✓ 动画效果

### MVVM+UseCase版本
- ✓ 所有传统版本功能
- ✓ Clean Architecture 设计
- ✓ UseCase 业务封装
- ✓ Repository 数据分离
- ✓ 依赖注入管理
- ✓ 状态可视化展示

## 更多信息

详细架构说明请查看: [ARCHITECTURE.md](./ARCHITECTURE.md)
