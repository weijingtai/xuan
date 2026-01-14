# Anonymous + 本地游客 + 账号体系：实施 Todo List

目标：支持“无需注册即可使用（游客）”，并在用户注册/登录后保留游客期数据；同时保持对具体 BaaS（如 Firebase）的低耦合，便于未来替换。

## 原则（低耦合约束）

- 业务与存储的唯一主键始终是 `appUserId`（不使用 BaaS uid 分桶）。
- “游客身份”优先定义为本地能力（离线可用、可迁移）；BaaS 匿名会话只作为可选加速层。
- 任何 BaaS 特性（匿名登录、账号升级、规则细节）只能存在于适配层：`AuthAdapter` / `IdentityResolver` / `RemoteGateway`。
- 允许未来 BaaS 不支持“匿名账号升级”语义：必须提供可用的降级路径。

## 里程碑与分步任务

### M1：身份与状态机（把概念固化为代码边界）

- [ ] 定义游客身份模型与状态机（guest/local/baas）
  - 输出：明确状态集合与状态转换（首次启动、匿名绑定、注册新账号、登录既有账号、登出、清理）。
  - 验收：团队对“游客是什么/什么时候切换 appUserId/什么时候合并”无分歧。

### M2：本地游客（无网络也可用的底座）

- [x] 新增本地 GuestIdentityStore 持久化 appUserId_guest
  - 建议：SharedPreferences 存 `guest:app_user_id`（或复用现有 registry 的 key 体系）。
  - 验收：首次启动生成，重启后仍为同一个 appUserId。

- [x] 扩展 ActiveAccountStore 支持 guest 与 signedIn 区分
  - 输出：能够表达当前处于 guest / signed-in / none（并给 UI 做决策）。
  - 验收：未登录时仍能进入主应用（使用 guest scope）。

### M3：认证适配层扩展（为 BaaS 匿名做“可插拔能力位”）

- [x] 扩展 AuthAdapter 支持匿名会话与账号升级能力
  - 输出：抽象出匿名登录、匿名升级（若支持）与常规登录注册。
  - 验收：业务层只依赖接口，不直接引用 FirebaseAuth。

- [x] 实现 FirebaseAuthAdapter 的匿名登录与升级注册
  - 输出：
    - 匿名登录：获取 baasUid
    - 注册新账号：优先走“匿名账号升级”（保持 uid）
    - 若升级不支持或失败：走降级分支（见 M6）
  - 验收：匿名→注册新账号后，仍使用同一个 appUserId。

### M4：身份映射（把 guest 的 appUserId 与会话绑定起来）

- [x] 扩展 IdentityResolver 支持 ensureIdentityMapping 绑定
  - 输出：在“已有 appUserId（guest）”与“新会话（baasUid）”之间建立安全绑定。
  - 验收：本地游客可以在登录后保留 appUserId（不依赖 uid 不变）。

- [x] 实现 FirebaseIdentityResolver 的绑定与冲突校验
  - 输出：
    - 若 identity_map 不存在：写入 appUserId_guest
    - 若存在且一致：更新 lastSeen
    - 若存在但指向另一个 appUserId：视为冲突，交由上层走“合并/保留/丢弃”流程
  - 验收：冲突可检测且不会悄悄覆盖。

### M5：启动流程（默认进入游客空间，并可无感获得匿名会话）

- [x] 实现启动流程：无账号先进入本地游客空间
  - 输出：App 启动时若无 active account，则设置 active=guest appUserId。
  - 验收：首次启动不强制进入登录页。

- [x] 实现启动流程：后台尝试匿名会话并绑定现有 guest
  - 输出：若 BaaS 可用则后台匿名登录，并调用 ensureIdentityMapping(anonSession, appUserId_guest)。
  - 验收：对用户无感；失败不影响本地使用。

### M6：游客 → 账号（注册新账号、登录既有账号、冲突决策）

- [ ] 实现游客转新账号：优先升级匿名会话保持 uid
  - 输出：
    - 若当前存在 anon 会话：使用升级/绑定凭证
    - 否则：正常注册后 ensureIdentityMapping(session, appUserId_guest)
  - 验收：注册后仍保留游客期数据（同 appUserId）。

- [x] 实现游客登录既有账号的三选一合并弹窗
  - 输出：合并 / 保留独立游客空间 / 丢弃游客数据 并登录。
  - 验收：三条路径都可走通且可回溯（至少在本机）。

- [ ] 实现“丢弃游客数据并登录”清理与回滚机制
  - 输出：清理 guest 分库与 outbox；若中途失败可重试或回到 guest。
  - 验收：丢弃后不再出现游客数据，也不会被同步。

- [ ] 实现“保留独立游客空间”账号切换与返回入口
  - 输出：能在账号与 guest 之间切换；guest 数据保持。
  - 验收：切换后数据严格隔离。

### M7：合并能力（把游客期数据同步进既有账号）

- [x] 实现“合并到账号”本地数据迁移与冲突策略
  - 默认策略：游客覆盖账号（可选：对创作型内容保留两份）。
  - 输出：账号本地库立即可见游客期内容。
  - 验收：合并后 UI 立刻呈现，且不破坏账号既有数据。

- [x] 实现 outbox 重写入队并触发账号同步
  - 输出：将 guest outbox 记录重写 scopeUid=account，并生成新 operationId 后入队。
  - 验收：同步后账号远端桶 `users/{appUserId_account}` 能看到合并结果。

### M8：权限与安全（支持 identity_map 安全写入）

- [ ] 更新远端权限策略以允许安全写入 identity_map
  - 输出：
    - “首次写入允许、后续不可改”或“仅云函数可改”的策略
    - 明确冲突处理（拒绝改写或走后台合并）
  - 验收：无法冒用他人 baasUid 绑定别人的 appUserId。

### M9：测试与验证（避免回归、保证迁移与降级可用）

- [ ] 新增单元测试覆盖游客、升级、登录合并三流程
  - 覆盖：
    - 首次启动生成 guest
    - 匿名绑定成功/失败降级
    - 匿名→注册新账号保留 appUserId
    - 游客→登录既有账号的三选一
    - 合并：冲突覆盖/保留两份（若实现）

- [ ] 跑通集成验证：离线、重启、换机登录一致性
  - 覆盖：
    - 离线使用 → 重启 → 数据仍在
    - 在线匿名绑定失败 → 不影响本地
    - 登录后同账号换机 → 仍能找到同 appUserId（通过 identity_map）

- [ ] 运行 lint 与 typecheck 并修复所有问题

## 验收清单（最终交付）

- 游客态可进入主应用并拥有稳定 `appUserId_guest`。
- 注册新账号后，游客期数据仍保留并归入该账号。
- 游客期使用后登录既有账号，用户可选择合并/保留/丢弃且都可用。
- 业务层不直接依赖 Firebase SDK；替换 BaaS 仅需替换适配层实现。

