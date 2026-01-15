我先快速扫描现有测试结构与工具链，再按 M9 顺序给出可执行的测试开发计划。
        
            
toolName: search_codebase
            
status: success
          
query: Find existing test infrastructure: flutter test usage, integration_test folder, firebase emulator usage, mock patterns, CI scripts for lint/typecheck. Need to align M9 test plan to existing conventions.
          

        
            
toolName: todo_write
            
status: failed
          
Todos updated: 0 items
          

        
            
toolName: todo_write
            
status: success
          
Todos updated: 2 items
          

        
            
toolName: todo_write
            
status: success
          
Todos updated: 2 items
          
按 M9 列表顺序，我建议把测试开发拆成 **单元/组件测试（先）→ 数据合并集成测试（再）→ 端到端验证（最后）**。默认以 `flutter test` 为主（你仓库已有惯例），Firebase 相关尽量用 fake/mock；需要验证规则/真实权限时再引入 emulator。

**假设**
- 主要自动化入口：`flutter test`
- 认证/映射可用 fake（你已有 `_FakeAuthAdapter/_FakeIdentityResolver` 风格）
- Drift 本地库可用临时目录/内存库做集成验证（不依赖真设备）

## 0) 基线与约束（先做一次）
- 命令基线：`flutter test`、`flutter analyze`
- 统一测试数据：所有用到 SharedPreferences 的测试都先 `SharedPreferences.setMockInitialValues({})`
- 对外部依赖（FirebaseAuth/Firestore/网络）一律用 fake/mock，避免不稳定

## 1) 顺序 1：首次启动生成 guest（单元测试）
目标：验证“游客底座”稳定，不被后续登录流程破坏。

- 新增/完善用例（建议都放在 `account/test/account_test.dart` 同类文件）
  - GuestIdentityStore：首次生成、二次读取一致、clear 后重新生成（你已有覆盖）
  - ActiveAccountStore：无 active account → 进入 guest、`isGuest=true`、`activeAppUserId` 非空（你已有覆盖）
  - ActiveAccountStore：已有账号记录且被 setActive → 启动落到 account（补一个用例）

## 2) 顺序 2：匿名绑定成功/失败降级（单元 + 少量组件测试）
目标：匿名绑定不影响“可用性”，失败不阻断；成功时确保 `ensureIdentityMapping(session, guestAppUserId)` 被调用。

- 单元测试（AuthCoordinator 维度）
  - `signInAnonymously()`：guest 模式下调用 `ensureIdentityMapping`（你已有覆盖）
  - `signInAnonymously()`：`ensureIdentityMapping` 抛错时的行为（期望：不改变 activeAppUserId、不把用户踢出 guest；错误可上抛给上层做“静默失败”策略）
- 组件/装配层行为（建议用一个轻量 widget test 或者直接对启动组件做可测封装）
  - E3：App 冷启动只尝试一次匿名绑定；遇到配置型错误码（如 admin-restricted-operation）后停止自动重试（这里更偏装配层逻辑验证）

## 3) 顺序 3：匿名→注册新账号保留 appUserId（单元测试）
目标：游客注册后 **仍使用同一个 appUserId_guest**，游客期数据自然保留。

- AuthCoordinator 用例
  - guest 状态下 `signInOrRegisterWithEmailPassword()`：应调用 `ensureIdentityMapping(session, guestAppUserId)` 且最终 `activeAppUserId == guestAppUserId`（你已有核心用例）
  - 非 guest 状态下 `signInOrRegisterWithEmailPassword()`：走 `_activateFromSession → resolveAppUserId`（补一个用例，避免未来回归）
- FirebaseEmailAuthAdapter（可选，偏集成）：验证匿名 user + createIfMissing 时优先走 `linkWithCredential` 的分支（如果不跑 emulator，就只做“分支覆盖式”测试：用 fake FirebaseAuth 包一层适配器更好测）

## 4) 顺序 4：游客→登录既有账号三选一（组件测试为主）
目标：冲突被正确抛出、弹窗交互正确、三条路径都能走通。

- 单元测试（AuthCoordinator）
  - guest → `signInWithEmailPassword` 且 `resolveAppUserId != guestId`：抛 `GuestAccountConflict`（你已有）
  - guest → `signInWithEmailPassword` 且 `resolveAppUserId == guestId`：不冲突，直接激活（补一个用例）
- 组件测试（AuthPage）
  - 选择“合并”：应调用 `GuestAccountConflictDelegate.mergeGuestIntoAccount`，随后 `activateSession`
  - 选择“丢弃”：应调用 `discardGuest`，随后 `activateSession`
  - 选择“保留”：不调用 delegate，直接 `activateSession`
  - 取消弹窗：返回“已取消登录”，状态不变

## 5) 顺序 5：合并（冲突覆盖/保留两份）与 outbox 重写（集成测试）
目标：验证**真实数据层行为**（不是只验证 delegate 被调用），尤其是：
- “保留两份”时 entityId remap 的正确性
- outbox scopeUid 从 guest 改为 account，operationId 重生成

建议做法（为了可测试性）：
- 把当前在主工程装配层里的“合并/丢弃实现”提取成**可 import 的公开类/函数**（否则私有类/私有方法难以自动化验证真实迁移效果）
- 集成测试用例（使用临时目录创建两套 DB：guest/account）
  - 合并后：account DB 里模板/元信息/设置数量与内容符合预期；guest DB 被清空
  - 冲突场景：同一模板存在于两边时，验证“覆盖/保留两份”策略生效（重点检查 remap 后外键/引用一致）
  - outbox：guest outbox 记录迁移到 account scope，operationId 不复用；迁移后 guest outbox 清空

## 6) 集成验证（离线/重启/换机一致性）（手工为主，必要时补自动化）
目标：覆盖真实用户路径，发现环境类问题（网络、权限、规则、设备差异）。

按 M9 顺序执行：
- 离线使用 → 重启 → 数据仍在（同 appUserId_guest）
- 在线匿名绑定失败 → 不影响本地（确认不会卡启动、不会反复弹错/刷屏）
- 登录后同账号换机 → 仍能找到同 appUserId（通过 identity_map）
  - 这里强依赖 M8 权限策略/真实后端；建议先在 emulator 或测试项目环境跑通一次

## 建议的退出标准（M9 Done）
- 单元/组件测试：核心路径用例通过率 100%，且连续跑 3 次稳定
- 集成测试：合并/丢弃/outbox 重写用例全绿
- 手工验证：离线/重启/换机 3 条链路都有可复现记录（步骤+结果）

如果你愿意，我可以下一步把上述计划直接落成“新增哪些测试文件/用例名称/断言点”的清单，并按顺序开始把缺的测试补齐到仓库里。