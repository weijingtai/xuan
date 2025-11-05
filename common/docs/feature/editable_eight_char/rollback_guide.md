# PillarDecoration 重构回滚指南

> EditableFourZhuCard 数据驱动装饰系统 - 完整回滚方案

## 📋 目录

- [回滚策略总览](#回滚策略总览)
- [Git 提交策略（重要）](#git-提交策略重要)
- [分阶段回滚方案](#分阶段回滚方案)
  - [阶段 1 回滚](#阶段-1-回滚)
  - [阶段 2 回滚](#阶段-2-回滚)
  - [阶段 3 回滚](#阶段-3-回滚)
  - [阶段 4 回滚](#阶段-4-回滚)
  - [阶段 5 回滚](#阶段-5-回滚)
  - [阶段 6 回滚](#阶段-6-回滚)
- [Git 分支管理策略](#git-分支管理策略)
- [数据备份建议](#数据备份建议)
- [常见问题快速修复](#常见问题快速修复)
- [完全回滚的终极方案](#完全回滚的终极方案)

---

## 回滚策略总览

### 核心原则

本次重构采用**新建文件策略**，所有数据模型和 Widget 组件都创建为新文件，最大限度减少对现有代码的修改，确保可安全回滚。

### 回滚难度分级

| 阶段 | 主要操作 | 回滚难度 | 回滚方式 |
|------|----------|----------|----------|
| 阶段 1 | 创建数据模型文件 | ⭐ 极低 | 直接删除新文件 |
| 阶段 2 | 创建 Widget 组件文件 | ⭐ 极低 | 直接删除新文件 |
| 阶段 3 | 修改 impl 文件 | ⭐⭐ 低 | Git revert 或分支切换 |
| 阶段 4 | 修改拖拽反馈 | ⭐⭐ 低 | Git revert 或分支切换 |
| 阶段 5 | 修改幽灵元素 | ⭐⭐ 低 | Git revert 或分支切换 |
| 阶段 6 | 清理优化 | ⭐ 极低 | Git revert 或分支切换 |

### 新建文件清单

```
lib/widgets/editable_fourzhu_card/
├── models/
│   └── decoration/
│       ├── cell_decoration.dart             ✨ 新建
│       ├── pillar_decoration.dart           ✨ 新建
│       └── decoration_defaults.dart         ✨ 新建
├── widgets/
│   ├── cell_widget.dart                     ✨ 新建
│   ├── pillar_widget.dart                   ✨ 新建
│   ├── ghost_pillar_widget.dart             ✨ 新建
│   ├── dragging_feedback_widget.dart        ✨ 新建
│   ├── column_grip_widget.dart              ✨ 新建
│   ├── row_grip_widget.dart                 ✨ 新建
│   └── widgets.dart                         ✨ 新建（导出文件）
└── editable_fourzhu_card_impl.dart          ⚠️ 修改（唯一需要回滚的现有文件）
```

### 修改文件清单

```
⚠️ 需要回滚的文件：

1. lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart
   - 修改时间：阶段 3-6
   - 修改内容：添加 _pillarDecorations、修改计算方法、修改渲染逻辑

2. lib/widgets/editable_fourzhu_card/models/drag_payloads.dart
   - 修改时间：阶段 1
   - 修改内容：PillarPayload 添加 decoration 字段
```

---

## Git 提交策略（重要）

> **核心理念：** 精细提交 + 清晰消息 = 快速回滚

### 提交频率原则

#### ✅ 推荐：每个小任务完成后立即提交

```bash
# 完成任务 1.1 后
git add lib/widgets/editable_fourzhu_card/models/decoration/
git commit -m "feat(stage-1): 创建 decoration 目录结构

- 创建 lib/widgets/editable_fourzhu_card/models/decoration/ 目录

阶段: 1 (数据模型创建)
任务: 1.1
耗时: 5分钟"

# 完成任务 1.2 后
git add lib/widgets/editable_fourzhu_card/models/decoration/decoration_defaults.dart
git commit -m "feat(stage-1): 创建 DecorationDefaults 常量类

- 定义 ganZhiCellHeight, otherCellHeight, dividerCellHeight 等常量
- 定义默认 padding, margin, border 等样式常量

阶段: 1 (数据模型创建)
任务: 1.2
耗时: 15分钟"
```

**优点：**
- ✅ 粒度细，回滚精确（只回滚出错的任务）
- ✅ 进度清晰，易于追踪
- ✅ 出错时损失最小（只损失当前任务的工作量）

#### ❌ 不推荐：整个阶段完成后才提交

```bash
# 阶段 1 的 8 个任务全部完成后才提交
git commit -m "feat: 完成阶段 1"  # ❌ 粒度太粗
```

**缺点：**
- ❌ 粒度粗，回滚会丢失整个阶段的工作
- ❌ 难以定位具体哪个任务出错
- ❌ 出错时损失大（损失整个阶段 2-3 小时）

---

### 提交消息格式

#### 标准格式（推荐）

```
<type>(stage-<N>): <简短描述>

<详细描述>
- 修改点 1
- 修改点 2
- ...

阶段: <N> (<阶段名称>)
任务: <任务编号>
耗时: <实际耗时>
```

#### Type 类型

| Type | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(stage-1): 创建 CellDecoration 类` |
| `refactor` | 重构代码 | `refactor(stage-3): 简化 _colWidthAtIndex() 方法` |
| `fix` | 修复 bug | `fix(stage-3): 修复抓手对齐偏移问题` |
| `test` | 添加测试 | `test(stage-6): 添加 PillarDecoration 单元测试` |
| `docs` | 文档更新 | `docs: 更新 README` |
| `chore` | 杂项 | `chore(stage-6): 删除调试日志` |

#### 完整示例

```bash
# 示例 1: 创建新文件
git commit -m "feat(stage-1): 创建 CellDecoration 基础类

- 添加 rowType, padding, border, backgroundColor, height, isHeaderRow 字段
- 实现 effectiveHeight 计算属性（支持 height 覆盖、isHeaderRow 特殊处理、rowType 推断）
- 实现 getSize(width) 方法（含 padding + border）
- 添加 copyWith() 方法

阶段: 1 (数据模型创建)
任务: 1.3
文件: lib/widgets/editable_fourzhu_card/models/decoration/cell_decoration.dart
耗时: 30分钟"

# 示例 2: 修改现有文件
git commit -m "refactor(stage-3): 简化 _colWidthAtIndex() 方法

修改前: 40+ 行复杂逻辑
修改后: 3 行数据驱动

- 使用 payload.decoration?.size.width 替代复杂计算
- 保留兜底逻辑（无 decoration 时）

阶段: 3 (渲染层局部替换)
任务: 3.7
文件: lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart
行数: Line 1234-1267
耗时: 20分钟"

# 示例 3: 修复错误
git commit -m "fix(stage-3): 修复抓手对齐偏移问题

问题: 抓手未居中到柱的内容区
原因: 未抵消 margin 的影响
修复: 添加 horizontalPadding = decoration.margin.horizontal / 2

阶段: 3 (渲染层局部替换)
任务: 3.10
文件: lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart
行数: Line 764-776
耗时: 15分钟（包含调试）"
```

---

### 快速回滚策略

#### 策略 1: 精确回滚单个任务（推荐）

```bash
# 查看最近的提交
git log --oneline -10

# 输出示例:
# a1b2c3d (HEAD) refactor(stage-3): 替换 topGripRow 的柱抓手渲染
# e4f5g6h refactor(stage-3): 重构 _columnBoundaryMidX() 使用 contentCenter
# i7j8k9l refactor(stage-3): 简化 _totalColsWidth() 方法
# m0n1o2p refactor(stage-3): 简化 _colWidthAtIndex() 方法
# q3r4s5t feat(stage-3): 在 rowListNotifier 监听器中更新 decorations

# 发现任务 3.10（a1b2c3d）有问题，需要回滚
git revert a1b2c3d

# 或者回滚最近 2 个提交
git revert HEAD~1..HEAD
```

**优点：**
- ✅ 只回滚出错的任务，保留其他任务的成果
- ✅ 保留 Git 历史，可追溯
- ✅ 安全，不影响其他提交

#### 策略 2: 回滚到某个检查点

```bash
# 查看提交历史
git log --oneline --grep="阶段: 3"

# 输出示例:
# a1b2c3d refactor(stage-3): 替换 topGripRow 的柱抓手渲染
# e4f5g6h refactor(stage-3): 重构 _columnBoundaryMidX()
# ...
# q3r4s5t feat(stage-3): 创建 Git 分支  ← 阶段 3 的第一个提交

# 回滚到阶段 3 开始前
git reset --hard q3r4s5t~1  # ⚠️ 危险：会丢失所有阶段 3 的工作

# 更安全的方式：创建新分支从检查点重新开始
git checkout -b refactor/common/card-stage-3-retry q3r4s5t~1
```

#### 策略 3: 使用交互式 rebase 编辑历史

```bash
# 交互式编辑最近 5 个提交
git rebase -i HEAD~5

# 在编辑器中，可以：
# - pick: 保留提交
# - drop: 删除提交
# - edit: 编辑提交
# - squash: 合并到前一个提交

# 示例：删除任务 3.10 的提交
# pick e4f5g6h refactor(stage-3): 重构 _columnBoundaryMidX()
# drop a1b2c3d refactor(stage-3): 替换 topGripRow 的柱抓手渲染  ← 删除这个
# pick ...
```

**⚠️ 注意：** 仅在未推送到远程时使用 rebase，否则会导致历史冲突。

---

### 快速定位问题提交

#### 方法 1: 按阶段过滤

```bash
# 查看阶段 3 的所有提交
git log --oneline --grep="阶段: 3"

# 查看阶段 3 的详细提交
git log --grep="阶段: 3" --no-merges
```

#### 方法 2: 按任务编号过滤

```bash
# 查看任务 3.10 的提交
git log --oneline --grep="任务: 3.10"

# 查看任务 3.10 的详细变更
git log --grep="任务: 3.10" -p
```

#### 方法 3: 按文件过滤

```bash
# 查看 editable_fourzhu_card_impl.dart 的提交历史
git log --oneline -- lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart

# 查看特定行的修改历史
git log -L 764,776:lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart
```

#### 方法 4: 使用 git bisect 二分查找

```bash
# 已知阶段 3 开始前是好的，现在是坏的
git bisect start
git bisect bad HEAD  # 当前版本有问题
git bisect good q3r4s5t  # 阶段 3 开始前没问题

# Git 会自动二分查找，每次检出中间的提交
# 运行测试，标记好/坏
flutter test
git bisect bad  # 或 git bisect good

# 重复直到找到第一个坏提交
git bisect reset  # 结束二分查找
```

---

### 提交前检查清单

每次提交前，确保：

- [ ] ✅ 代码编译通过：`flutter analyze`
- [ ] ✅ 相关测试通过：`flutter test`（如果有测试）
- [ ] ✅ 提交消息清晰，包含阶段、任务、耗时
- [ ] ✅ 只提交相关文件，不提交无关变更
- [ ] ✅ 检查 git diff，确认变更符合预期

```bash
# 检查清单脚本
#!/bin/bash
echo "🔍 提交前检查..."

echo "1️⃣ 运行 flutter analyze..."
flutter analyze || { echo "❌ Analyze 失败"; exit 1; }

echo "2️⃣ 检查 git diff..."
git diff --cached

echo "3️⃣ 确认提交文件列表..."
git status

echo "✅ 检查通过，可以提交！"
```

---

### 推送策略

#### 策略 1: 每个任务完成后推送（推荐）

```bash
# 完成任务 1.3 后
git add lib/widgets/editable_fourzhu_card/models/decoration/cell_decoration.dart
git commit -m "feat(stage-1): 创建 CellDecoration 基础类 ..."
git push origin refactor/common/card-stage-1

# 优点: 云端备份，防止本地丢失
# 缺点: 推送频繁
```

#### 策略 2: 每个阶段完成后推送

```bash
# 阶段 1 的所有任务完成后
git push origin refactor/common/card-stage-1

# 优点: 推送次数少
# 缺点: 本地丢失风险高
```

#### ⚠️ 重要：推送前确认分支名

```bash
# 确认当前分支
git branch --show-current

# 应输出: refactor/common/card-stage-1
# 不应输出: master 或 main（避免推送到主分支）

# 推送
git push origin $(git branch --show-current)
```

---

### 提交模板（可选）

创建 `.gitmessage` 模板文件：

```bash
# 创建模板文件
cat > ~/.gitmessage << 'EOF'
<type>(stage-<N>): <简短描述>

<详细描述>
-
-

阶段: <N> (<阶段名称>)
任务: <任务编号>
文件:
耗时: <实际耗时>
EOF

# 配置 Git 使用模板
git config --global commit.template ~/.gitmessage
```

使用模板提交：

```bash
git commit  # 会打开编辑器，自动填充模板
```

---

### 实战示例：快速修复错误重构

#### 场景：任务 3.10 导致抓手对齐错误

```bash
# 1. 发现问题
flutter run
# 观察到抓手对齐有问题

# 2. 定位问题提交
git log --oneline --grep="任务: 3.10"
# 输出: a1b2c3d refactor(stage-3): 替换 topGripRow 的柱抓手渲染

# 3. 查看变更
git show a1b2c3d

# 4. 确认是这个提交的问题，回滚
git revert a1b2c3d

# 5. 修复问题
# 编辑 editable_fourzhu_card_impl.dart
# 修复抓手对齐逻辑

# 6. 重新提交
git add lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart
git commit -m "fix(stage-3): 修复抓手对齐偏移问题

问题: 抓手未居中到柱的内容区
原因: 未抵消 margin 的影响
修复: 添加 horizontalPadding = decoration.margin.horizontal / 2

阶段: 3 (渲染层局部替换)
任务: 3.10 (重做)
文件: lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart
耗时: 15分钟（包含调试和修复）"

# 7. 测试验证
flutter run
# 确认抓手对齐正确

# 8. 推送
git push origin refactor/common/card-stage-3
```

**总耗时：** 约 20 分钟（定位 5 分钟 + 修复 15 分钟）

**如果没有精细提交：** 需要回滚整个阶段 3，损失 3-4 小时的工作量。

---

### 提交策略总结

| 策略 | 提交频率 | 粒度 | 回滚精度 | 推荐度 |
|------|----------|------|----------|--------|
| **每任务提交** | 高（49次） | 极细 | 精确到任务 | ⭐⭐⭐⭐⭐ |
| 每阶段提交 | 中（6次） | 粗 | 精确到阶段 | ⭐⭐⭐ |
| 最终一次提交 | 低（1次） | 极粗 | 只能全部回滚 | ⭐ |

**建议：** 使用**每任务提交**策略，虽然提交次数多，但回滚精确，修复错误成本低。

---

## 分阶段回滚方案

### 阶段 1 回滚

**阶段 1 完成内容：** 创建数据模型（CellDecoration、PillarDecoration、DecorationDefaults）

#### 回滚步骤

**方式 1：直接删除文件（推荐）**

```bash
# 删除整个 decoration 目录
rm -rf lib/widgets/editable_fourzhu_card/models/decoration/

# 或逐个删除
rm lib/widgets/editable_fourzhu_card/models/decoration/cell_decoration.dart
rm lib/widgets/editable_fourzhu_card/models/decoration/pillar_decoration.dart
rm lib/widgets/editable_fourzhu_card/models/decoration/decoration_defaults.dart
rmdir lib/widgets/editable_fourzhu_card/models/decoration
```

**方式 2：Git 回滚**

```bash
# 如果已提交，使用 git revert
git log --oneline  # 查找阶段 1 的 commit hash
git revert <commit-hash>

# 或直接重置到阶段 1 之前
git reset --hard HEAD~1  # ⚠️ 谨慎使用，会丢失未提交的更改
```

**方式 3：恢复 drag_payloads.dart**

```bash
# 如果修改了 drag_payloads.dart，需要回滚
git checkout HEAD -- lib/widgets/editable_fourzhu_card/models/drag_payloads.dart
```

#### 验证回滚成功

```bash
# 检查文件是否已删除
ls lib/widgets/editable_fourzhu_card/models/decoration/
# 预期输出：ls: cannot access ...: No such file or directory

# 运行应用
flutter run
# 预期：应用正常运行（因为这些文件未被引用）
```

---

### 阶段 2 回滚

**阶段 2 完成内容：** 创建 Widget 组件（CellWidget、PillarWidget、GhostPillarWidget 等）

#### 回滚步骤

**方式 1：直接删除文件（推荐）**

```bash
# 删除整个 widgets 目录
rm -rf lib/widgets/editable_fourzhu_card/widgets/

# 或逐个删除
rm lib/widgets/editable_fourzhu_card/widgets/cell_widget.dart
rm lib/widgets/editable_fourzhu_card/widgets/pillar_widget.dart
rm lib/widgets/editable_fourzhu_card/widgets/ghost_pillar_widget.dart
rm lib/widgets/editable_fourzhu_card/widgets/dragging_feedback_widget.dart
rm lib/widgets/editable_fourzhu_card/widgets/column_grip_widget.dart
rm lib/widgets/editable_fourzhu_card/widgets/row_grip_widget.dart
rm lib/widgets/editable_fourzhu_card/widgets/widgets.dart
rmdir lib/widgets/editable_fourzhu_card/widgets
```

**方式 2：Git 回滚**

```bash
# 如果已提交，查找阶段 2 的 commit
git log --oneline | grep "阶段 2\|Widget 组件"
git revert <commit-hash>
```

#### 验证回滚成功

```bash
# 检查文件是否已删除
ls lib/widgets/editable_fourzhu_card/widgets/
# 预期输出：ls: cannot access ...: No such file or directory

# 运行应用
flutter run
# 预期：应用正常运行
```

---

### 阶段 3 回滚

**阶段 3 完成内容：** 修改 `editable_fourzhu_card_impl.dart`，添加 `_pillarDecorations`、简化计算方法、替换渲染逻辑

⚠️ **重要：** 这是第一个修改现有文件的阶段，回滚需谨慎。

#### 回滚步骤

**方式 1：Git 分支切换（推荐）**

```bash
# 假设当前在 refactor/common/card-stage-3 分支
git status  # 检查是否有未提交的更改

# 切换回主分支
git checkout refactor/common/card  # 或 master

# 删除阶段 3 分支（可选）
git branch -D refactor/common/card-stage-3
```

**方式 2：Git revert**

```bash
# 查找阶段 3 的所有 commits
git log --oneline | grep "阶段 3\|Stage 3"

# 逐个 revert（从最新到最旧）
git revert <commit-hash-1>
git revert <commit-hash-2>
# ...
```

**方式 3：Git reset（危险）**

```bash
# ⚠️ 仅在没有推送到远程时使用
git log --oneline  # 查找阶段 3 之前的 commit
git reset --hard <commit-hash-before-stage-3>
```

**方式 4：手动恢复文件**

```bash
# 恢复 impl 文件到阶段 3 之前的版本
git checkout <commit-hash-before-stage-3> -- lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart
```

#### 需要恢复的代码片段

如果手动回滚，需要删除以下内容：

```dart
// 删除新增字段
final Map<int, PillarDecoration> _pillarDecorations = {};  // ❌ 删除

// 删除新增方法
void _initializePillarDecorations() { ... }  // ❌ 删除
PillarDecoration _createPillarDecoration(int pillarIndex) { ... }  // ❌ 删除

// 恢复旧的计算方法
double _colWidthAtIndex(int i, List<Tuple2<String, JiaZi>> pillars) {
  // 恢复原来的 40+ 行逻辑
}
```

#### 验证回滚成功

```bash
# 检查 impl 文件是否恢复
git diff lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart
# 预期输出：无差异

# 运行应用
flutter run
# 预期：应用正常运行，抓手对齐可能有问题（回到重构前状态）
```

---

### 阶段 4 回滚

**阶段 4 完成内容：** 使用 `DraggingFeedbackWidget` 替换拖拽反馈视图

#### 回滚步骤

**方式 1：Git 分支切换（推荐）**

```bash
# 切换回阶段 3 分支
git checkout refactor/common/card-stage-3

# 或切换回主分支
git checkout refactor/common/card
```

**方式 2：Git revert**

```bash
# 查找阶段 4 的 commits
git log --oneline | grep "阶段 4\|拖拽反馈"
git revert <commit-hash>
```

**方式 3：手动恢复拖拽反馈代码**

在 `editable_fourzhu_card_impl.dart` 中：

```dart
// 删除新方法
Widget _buildColumnDraggingFeedback(int pillarIndex) { ... }  // ❌ 删除
Widget _buildRowDraggingFeedback(int rowIndex) { ... }  // ❌ 删除

// 恢复 Draggable 的 feedback 参数
Draggable<Object>(
  feedback: Material(  // ✅ 恢复原来的手动构建反馈
    elevation: 4,
    child: Container(...),
  ),
  ...
)
```

#### 验证回滚成功

```bash
# 运行应用，测试拖拽
flutter run

# 拖拽列/行，检查反馈视图
# 预期：反馈视图恢复到阶段 4 之前的样式
```

---

### 阶段 5 回滚

**阶段 5 完成内容：** 使用 `GhostPillarWidget` 统一幽灵行/列的渲染

#### 回滚步骤

**方式 1：Git 分支切换（推荐）**

```bash
# 切换回阶段 4 分支
git checkout refactor/common/card-stage-4
```

**方式 2：Git revert**

```bash
# 查找阶段 5 的 commits
git log --oneline | grep "阶段 5\|幽灵元素"
git revert <commit-hash>
```

**方式 3：手动恢复幽灵元素代码**

在 `editable_fourzhu_card_impl.dart` 中：

```dart
// 删除新方法
double _getGhostColumnWidth() { ... }  // ❌ 删除
double _getGhostRowHeight(int rowIndex) { ... }  // ❌ 删除
PillarDecoration? _externalPillarDecoration;  // ❌ 删除字段

// 恢复幽灵列渲染
if (showGhost) {
  SizedBox(  // ✅ 恢复原来的手动构建
    width: _externalColHoverWidth ?? pillarWidth,
    height: dragHandleRowHeight,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        border: Border.all(...),
      ),
    ),
  )
}
```

#### 验证回滚成功

```bash
# 运行应用，测试拖拽插入
flutter run

# 拖拽外部柱/行到卡片，检查幽灵元素
# 预期：幽灵元素恢复到阶段 5 之前的样式
```

---

### 阶段 6 回滚

**阶段 6 完成内容：** 删除临时代码、移除调试日志、添加单元测试

#### 回滚步骤

**方式 1：Git revert（简单，推荐）**

```bash
# 查找阶段 6 的 commits
git log --oneline | grep "阶段 6\|清理\|优化"
git revert <commit-hash>
```

**方式 2：手动恢复**

```dart
// 恢复临时装饰代码（如果删除了）
Container(
  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  padding: EdgeInsets.symmetric(vertical: 6),
  decoration: BoxDecoration(
    color: Colors.red.withAlpha(10),
    border: Border.all(color: Colors.green, width: 2),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [...],
  ),
  width: colW,
  child: columnContent,
)

// 恢复调试日志（如果需要）
print('🔍 [幽灵行-gripColumn] ...');
```

**方式 3：删除测试文件**

```bash
# 删除新增的测试文件
rm test/widgets/editable_fourzhu_card/pillar_decoration_test.dart
rm test/widgets/editable_fourzhu_card/pillar_widget_test.dart
```

#### 验证回滚成功

```bash
# 运行应用
flutter run

# 检查是否有调试日志输出
# 检查是否有临时装饰效果
```

---

## Git 分支管理策略

### 分支命名规范

```
refactor/common/card              主分支（重构基线）
  ├── refactor/common/card-stage-1   阶段 1 分支
  ├── refactor/common/card-stage-2   阶段 2 分支
  ├── refactor/common/card-stage-3   阶段 3 分支
  ├── refactor/common/card-stage-4   阶段 4 分支
  ├── refactor/common/card-stage-5   阶段 5 分支
  └── refactor/common/card-stage-6   阶段 6 分支
```

### 分支创建时机

```bash
# 开始阶段 1 之前
git checkout -b refactor/common/card-stage-1

# 完成阶段 1 后，合并到主分支
git checkout refactor/common/card
git merge refactor/common/card-stage-1

# 开始阶段 2 之前
git checkout -b refactor/common/card-stage-2

# 重复以上流程...
```

### 合并策略

#### 策略 1：每阶段合并（推荐）

```bash
# 阶段 1 完成并验证通过后
git checkout refactor/common/card
git merge refactor/common/card-stage-1
git push origin refactor/common/card

# 优点：每阶段都有检查点，回滚成本低
# 缺点：commit 历史略复杂
```

#### 策略 2：最终一次性合并

```bash
# 所有阶段完成并验证通过后
git checkout refactor/common/card
git merge refactor/common/card-stage-6
git push origin refactor/common/card

# 优点：commit 历史简洁
# 缺点：回滚只能回到重构之前
```

### 分支保护策略

```bash
# 保留所有阶段分支，直到重构完全稳定
# 不要删除分支：
# git branch -D refactor/common/card-stage-X  # ❌ 不要执行

# 至少保留 2 周，确保没有问题后再删除
```

---

## 数据备份建议

### 备份时机

#### 重构前完整备份

```bash
# 创建备份分支
git checkout -b backup/before-pillar-decoration-refactor
git push origin backup/before-pillar-decoration-refactor

# 备份文件
cp -r lib/widgets/editable_fourzhu_card ~/backup/editable_fourzhu_card-$(date +%Y%m%d)
```

#### 每阶段开始前备份

```bash
# 阶段 3 开始前（第一个修改现有文件的阶段）
git stash  # 暂存当前更改
cp lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart \
   ~/backup/editable_fourzhu_card_impl-before-stage-3.dart
```

### 备份内容

```
推荐备份：

1. 整个 editable_fourzhu_card 目录
2. editable_fourzhu_card_impl.dart（重点）
3. drag_payloads.dart
4. Git 分支快照

不需要备份：

1. 生成的 .g.dart 文件（可重新生成）
2. build/ 目录
```

---

## 常见问题快速修复

### 问题 1：抓手对齐错误

**症状：** 拖拽抓手不在柱的中心

**快速修复：**

```dart
// 检查 topGripRow 的 ColumnGripWidget
return ColumnGripWidget(
  width: decoration?.size.width ?? pillarWidth,
  horizontalPadding: decoration != null
    ? decoration.margin.horizontal / 2  // ✅ 确保这行存在
    : 0,
  child: Draggable(...),
);
```

**如果无法修复，回滚到阶段 3 之前：**

```bash
git checkout refactor/common/card-stage-2
```

---

### 问题 2：Overflow 警告

**症状：** 控制台出现 "RenderFlex overflowed" 警告

**快速修复：**

```dart
// 检查 dataGrid 的柱渲染
child: Container(
  margin: decoration.margin,  // ✅ 外层 margin
  child: Container(
    padding: decoration.padding,  // ✅ 中层 padding
    decoration: decoration.toBoxDecoration(),
    child: SizedBox(
      width: decoration.basePillarWidth,  // ✅ 精确的内容宽度
      child: columnContent,
    ),
  ),
)
```

**如果无法修复，临时禁用装饰：**

```dart
// 在 _initializePillarDecorations() 中
return;  // 临时禁用装饰，恢复到原来的渲染方式
```

---

### 问题 3：幽灵行高度不一致

**症状：** 拖拽行到 insertIndex=0 时，幽灵行高度跳变

**快速修复：**

```dart
// 检查 _getGhostRowHeight() 方法
double _getGhostRowHeight(int rowIndex) {
  // 优先使用 _rowHeightOverrides
  if (_rowHeightOverrides.containsKey(rowIndex)) {
    return _rowHeightOverrides[rowIndex]!;  // ✅ 确保这行存在
  }

  // 否则根据 rowType 推断
  final row = widget.rowListNotifier.value[rowIndex];
  return _getDefaultRowHeight(row.rowType);
}
```

**如果无法修复，回滚到阶段 5 之前：**

```bash
git checkout refactor/common/card-stage-4
```

---

### 问题 4：拖拽反馈尺寸不匹配

**症状：** 拖拽时反馈视图的尺寸与原柱不一致

**快速修复：**

```dart
// 检查 _buildColumnDraggingFeedback() 方法
Widget _buildColumnDraggingFeedback(int pillarIndex) {
  final decoration = _pillarDecorations[pillarIndex];
  if (decoration == null) {
    return _buildDefaultColumnFeedback(pillarIndex);  // ✅ 兜底逻辑
  }

  return DraggingFeedbackWidget(
    decoration: decoration,  // ✅ 使用相同的 decoration
    children: _buildCellChildren(pillarIndex),
    opacity: 0.7,
  );
}
```

**如果无法修复，回滚到阶段 4 之前：**

```bash
git checkout refactor/common/card-stage-3
```

---

### 问题 5：缓存未失效

**症状：** 调整行高度后，柱的高度未立即更新

**快速修复：**

```dart
// 检查 _updateRowHeightOverride() 或类似方法
void _updateRowHeightOverride(int rowIndex, double height) {
  _rowHeightOverrides[rowIndex] = height;

  // 失效所有柱的缓存
  for (final decoration in _pillarDecorations.values) {
    decoration.invalidateCache();  // ✅ 确保这行存在
  }

  setState(() {});
}
```

---

## 完全回滚的终极方案

### 场景：所有阶段都失败，需要完全回滚

#### 方案 1：切换到备份分支

```bash
# 切换到重构前的备份分支
git checkout backup/before-pillar-decoration-refactor

# 创建新分支继续工作
git checkout -b refactor/common/card-retry
```

#### 方案 2：硬重置到重构前

```bash
# ⚠️ 危险操作：会丢失所有重构工作
git log --oneline | grep "重构前\|before refactor"
git reset --hard <commit-hash-before-refactor>

# 强制推送到远程（如果已推送）
git push --force origin refactor/common/card
```

#### 方案 3：删除所有新文件 + 恢复现有文件

```bash
# 删除所有新建的文件
rm -rf lib/widgets/editable_fourzhu_card/models/decoration/
rm -rf lib/widgets/editable_fourzhu_card/widgets/

# 恢复修改过的文件
git checkout HEAD -- lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart
git checkout HEAD -- lib/widgets/editable_fourzhu_card/models/drag_payloads.dart

# 验证恢复成功
flutter run
```

### 验证完全回滚成功

```bash
# 检查文件树
tree lib/widgets/editable_fourzhu_card/
# 预期输出：没有 decoration/ 和 widgets/ 目录

# 检查 Git 差异
git diff
# 预期输出：无差异

# 运行应用
flutter run
# 预期：应用正常运行，回到重构前状态

# 运行测试
flutter test
# 预期：所有测试通过
```

---

## 回滚检查清单

### 阶段 1-2 回滚检查清单

- [ ] 删除 `lib/widgets/editable_fourzhu_card/models/decoration/` 目录
- [ ] 删除 `lib/widgets/editable_fourzhu_card/widgets/` 目录
- [ ] 恢复 `drag_payloads.dart`（如果修改了）
- [ ] 运行 `flutter run`，确认应用正常
- [ ] 运行 `flutter analyze`，确认无错误

### 阶段 3-6 回滚检查清单

- [ ] 切换到回滚目标分支（或执行 git revert）
- [ ] 检查 `editable_fourzhu_card_impl.dart` 是否恢复
- [ ] 删除 `_pillarDecorations` 字段（如果存在）
- [ ] 恢复 `_colWidthAtIndex()` 原逻辑
- [ ] 恢复 `_columnBoundaryMidX()` 原逻辑
- [ ] 恢复拖拽反馈渲染（如果修改了）
- [ ] 恢复幽灵元素渲染（如果修改了）
- [ ] 删除调试日志（如果添加了）
- [ ] 运行 `flutter run`，测试所有功能
- [ ] 运行 `flutter test`，确认测试通过

### 完全回滚检查清单

- [ ] 切换到 `backup/before-pillar-decoration-refactor` 分支
- [ ] 或执行 `git reset --hard <commit-hash>`
- [ ] 删除所有新建文件
- [ ] 恢复所有修改过的文件
- [ ] 运行 `flutter clean && flutter pub get`
- [ ] 运行 `flutter run`，确认应用正常
- [ ] 运行 `flutter test`，确认所有测试通过
- [ ] 运行 `flutter analyze`，确认无警告

---

## 总结

本回滚指南提供了完整的回滚方案，涵盖：

1. **分阶段回滚** - 每个阶段都有详细的回滚步骤
2. **Git 分支管理** - 清晰的分支策略和合并流程
3. **数据备份建议** - 重构前和关键阶段的备份方案
4. **快速修复指南** - 常见问题的快速修复方法
5. **完全回滚方案** - 终极回滚的三种方式

**核心原则：** 新建文件策略确保回滚成本极低，大部分阶段只需删除文件即可回滚。

**建议：** 在每个阶段完成后充分测试，确认无问题后再进入下一阶段，降低回滚概率。

---

**祝重构顺利！** 🚀
