下面按“方案 B（Canonical `appUserId`）”重新设计 **程序结构 + 开发方案**，目标是：Auth/存储可插拔、同端多账号分库、未来从 Firebase 迁移到国内 BaaS 时 **不需要迁移业务数据桶（users/{appUserId} 不变）**，最多只做“身份映射”的迁移。

---

**一、方案 B 的核心约束（必须先固化）**
- **业务主键**：`appUserId`（你自己生成的 UUID），跨 BaaS 永久不变。
- **BaaS uid**：仅作为“会话身份凭证”，用来查出 `appUserId`，不再作为数据分桶主键。
- **远端数据路径**：统一为 `users/{appUserId}/...`（或等价租户空间）。
- **权限判断**：由“`request.auth.uid == pathUid`”改为“`mapping(request.auth.uid) == pathAppUserId`”。

---

## 二、程序结构（建议的模块边界）

### 1) `auth_core`（纯 Dart，业务可依赖）
定义跨平台、跨 BaaS 的认证抽象（只给业务提供稳定能力）：
- `AuthProviderType`：google/apple/microsoft/wechat/alipay/douyin/kuaishou/…
- `AuthSession`：`{ baasUid, idToken?, providerType, issuedAt }`
- `AuthAdapter` 接口：
  - `Future<AuthSession> signIn(AuthProviderType provider)`
  - `Future<void> signOut()`
  - `Stream<AuthSession?> sessionChanges()`
- `IdentityResolver` 接口（关键）：
  - `Future<String> resolveAppUserId(AuthSession session)`  // 返回 canonical appUserId
  - `Future<void> ensureIdentityMapping(AuthSession session, String appUserId)` // 绑定/迁移用

业务层与同步层只允许拿到 `appUserId`，不得直接使用 `baasUid`。

### 2) `identity_store`（本地账号注册表 + 同端多账号）
负责管理“这个设备上有哪些账号 + 当前激活账号是谁”，并驱动分库：
- `AccountRecord { appUserId, providerType, displayName?, avatarUrl?, lastLoginAt, localDbId }`
- `AccountRegistry`：
  - `listAccounts()`
  - `setActive(appUserId)`
  - `watchActive()`（active 变化时重建依赖）
  - `upsertAccount(record)`
  - `removeAccount(appUserId, wipeLocalData: bool)`

`localDbId` 建议与 `appUserId` 相同（更简单、稳定），或使用独立 UUID（更隐私，但需要映射）。你已经倾向分库，推荐 **直接用 `appUserId` 作为分库 key**，实现最简单。

### 3) `persistence_core`（你现有，保持不动为主）
- `scopeUid` 的语义升级：**现在 `scopeUid == appUserId`**。
- 你已有 [AuthScopeProvider](file:///Users/jingtaiwei/Git/codex/xuan/persistence_core/lib/model/ports.dart#L262-L268)，可以让它返回 `appUserId`。

### 4) `remote_gateway` 可插拔层（每个 BaaS 一个实现）
- `RemoteGateway` 实现 A：Firebase/Firestore（已有 `persistence_firebase`，需要把路径从 `users/{scopeUid}` 的语义改成 `users/{appUserId}`，本质一样）
- 未来实现 B：腾讯云/其他 BaaS 的 RemoteGateway（保持同样的 oplog/entity/cursor 协议）

### 5) `app_composition`（装配层，main.dart）
- 只在这里做“选择具体 BaaS 实现”“注入 AuthAdapter/IdentityResolver/RemoteGateway”
- active 账号变化时：重建 `AppDatabase` / `PersistenceDriftDatabase` / `SyncCoordinator` 等实例

---

## 三、数据模型（远端与本地）

### 1) 远端数据结构（统一以 appUserId 分桶）
- `users/{appUserId}/profile`
- `users/{appUserId}/oplog/{operationId}`
- `users/{appUserId}/modules/{module}/layout_templates/{entityId}`
- （可选）`users/{appUserId}/settings/...`

### 2) 关键：身份映射表（baasUid -> appUserId）
用于权限与解析：
- `identity_map/{baasUid}`：
  - `appUserId: string`
  - `createdAt, lastSeenAt`
  - `providerType`（可选）
  - `schemaVersion`

> 注意：这个集合/表本身需要严格权限：只允许“用户本人（baasUid）写自己的映射”，或仅允许云函数写（更安全）。

### 3) 本地分库（同端多账号）
- 每个 `appUserId` 一套本地库文件：
  - `app_database_<appUserId>`
  - `persistence_drift_<appUserId>`
- 这样你现有业务表无需加 `scopeUid` 列（例如 [LayoutTemplates 表](file:///Users/jingtaiwei/Git/codex/xuan/common/lib/database/tables/tables.dart#L193-L212) 保持不动），天然隔离。

---

## 四、Auth（Register/Login）在方案 B 下的标准流程

### 0) 游客模式（无需注册即可使用）

目标：用户无需注册即可进入主应用并产生可持久化的 `appUserId`；后续注册/登录时可以保留游客期数据。

**核心定义**
- **游客身份**：一种“临时会话形态”，用于在无注册状态下启动 `appUserId` 分桶与本地分库。
- **游客期数据**：游客激活的 `appUserId_guest` 下产生的本地数据与待同步操作。

**实现策略（推荐优先级）**
1. **BaaS 匿名会话（优先，Firebase 现成支持）**
   - 游客进入时：`AuthAdapter.signInAnonymously()` 获取 `baasUid`；随后走 `resolveAppUserId` 创建/命中 `identity_map/{baasUid}`。
   - 游客注册（创建新账号）时：在匿名会话上做“账号升级/绑定凭证”，尽量保持同一个 `baasUid` 不变，从而天然保留 `identity_map -> appUserId`。
   - 依赖约束：要求 BaaS 提供匿名登录与匿名账号升级能力（不同 BaaS 差异较大）。
2. **本地游客（保底，弱依赖 BaaS）**
   - 游客进入时：本地生成并持久化 `appUserId_guest`，直接进入主应用并用其分库。
   - 游客注册/登录后：通过 `ensureIdentityMapping(session, appUserId_guest)` 将现有登录会话绑定到该 `appUserId_guest`。
   - 依赖约束：需要后端/规则允许安全写入映射（可用云函数代理）。

**验收标准（MVP）**
- 首次安装打开即可进入主应用（不强制登录）。
- 游客态产生的数据在重启 App 后仍可见（同一个 `appUserId_guest`）。
- 游客注册“新账号”后，游客期数据仍可见且后续同步归入该账号。

### 1) Login（任意第三方）
1. `AuthAdapter.signIn(provider)` → 得到 `AuthSession(baasUid, idToken, …)`
2. `IdentityResolver.resolveAppUserId(session)`：
   - 先读 `identity_map/{baasUid}`，若存在取 `appUserId`
   - 若不存在：生成新 `appUserId`，写入 `identity_map/{baasUid}`（这一步就是“Register 语义”）
3. `AccountRegistry.upsertAccount(appUserId, provider, localDbId=appUserId)`
4. `AccountRegistry.setActive(appUserId)`
5. 装配层重建依赖：
   - 以 `appUserId` 打开两套 drift 库
   - SyncCoordinator 使用 `scopeUid = appUserId`
6. 初始化 `users/{appUserId}/profile`（若不存在则创建）

### 2) 多 Provider 绑定（同一人绑定多个三方）
- 目标：多个 baasUid 都映射到同一个 appUserId
- 实现：提供 `bindProvider(newProvider)`：
  1) 当前已登录且已知 `appUserId`
  2) 用 `newProvider` 再登录一次得到 `newBaasUid`
  3) 写 `identity_map/{newBaasUid} -> appUserId`（如需防止冒用，建议用云函数校验当前会话）

### 3) 游客注册与“已有账号登录”的冲突处理

场景：用户在游客态已产生 `appUserId_guest` 并产生数据；之后用户尝试登录一个“已存在账号”（对应 `appUserId_account`）。

**问题本质**
- `appUserId_guest` 与 `appUserId_account` 两个数据桶需要明确归属。
- 目标是让用户既能进入已有账号，又不丢失游客期数据。

**产品交互（推荐）**
- 当检测到“游客态 + 登录既有账号”时，给出三选一：
  1) **合并到已有账号（推荐）**：游客期数据并入 `appUserId_account`。
  2) **保留为独立访客空间**：仅切换到已有账号；访客空间保留但不合并。
  3) **丢弃访客数据并登录**：清除 `appUserId_guest` 的本地数据后登录。

**技术实现（MVP：本地合并 + 重放同步）**
- 合并目标：让 `users/{appUserId_account}` 成为唯一权威远端桶；不要求迁移/删除 `users/{appUserId_guest}`。
- 合并方法：
  - 将游客期产生的本地业务数据写入到账号库（可通过重放“本地写操作”实现）。
  - 将游客 outbox 中可重试记录重写为账号 outbox 记录并入队：
    - `scopeUid` 从 `appUserId_guest` 改为 `appUserId_account`
    - `operationId` 建议重新生成，避免跨桶幂等键语义混淆
    - 其余字段保持不变（`entityType/entityId/opType/payloadJson/createdAtUtc`）

**冲突策略（默认规则）**
- 当同一 `entityType + entityId` 在游客与账号均存在：
  - 默认：游客覆盖账号（更贴近用户“刚刚在本机做的最新意图”）。
  - 可选增强：对“用户创作型内容”冲突时保留两份（为游客内容生成新 `entityId`）。

**验收标准（MVP）**
- 游客态产生的数据在登录既有账号并选择“合并”后：
  - 账号态本地立刻可见
  - 同步后账号远端可见（落入 `users/{appUserId_account}`）
- 选择“不合并”时：登录后不显示游客数据；退出后仍可回到游客空间。
- 选择“丢弃”时：游客本地数据与待同步操作被清理，且不会再同步到任何远端桶。

---

## 五、存储访问权限设计（以 Firebase Rules 思路类比）
从“按 uid 相等”改为“按映射相等”：

- 任何对 `users/{appUserId}` 的读写，都必须满足：
  - `identity_map[request.auth.uid].appUserId == appUserId`

同时保留你原本对 oplog、实体字段校验、状态机的限制（你在 [firestore.rules](file:///Users/jingtaiwei/Git/codex/xuan/tools/firestore_emulator/firestore.rules) 已经写了很好的模板）。

> 迁移到其他 BaaS 时，只要它支持“按当前登录用户读取一条映射记录并比对路径变量”，就能复用该安全模型；如果规则能力不足，就用云函数代理写入（读可直连，写走函数）。

---

## 六、开发方案（阶段化，最小可用优先）

**阶段 1：引入 Canonical appUserId（不换远端也能先落地）**
- 实现 `AuthAdapter`（先只做你当前可用的 provider）
- 实现 `IdentityResolver`（Firebase 场景：用 Firestore 的 `identity_map`）
- 改造装配层：把 `scopeUid` 从“未来的 baasUid”统一改成 `appUserId`
- 完成：登录后能拿到 appUserId，并用 appUserId 分库

**验收标准**
- 同端登录两个账号 → 本地数据完全隔离（切换账号后看不到对方的本地模板）
- 同一账号换设备登录 → 能通过 `identity_map` 找回同一 appUserId（数据不丢）

**阶段 2：规则/权限切换到映射模式**
- 更新远端安全规则：从 `request.auth.uid == {uid}` 改为 `identity_map` 比对
- 确保 `identity_map` 的写入权限安全（最好：首次写入允许、后续不可改；或仅云函数改）

**验收标准**
- 未登录无法访问任何 `users/*`
- 登录后仅能访问 `users/{自己的appUserId}`

**阶段 3：多 Provider 绑定（可选但强烈推荐）**
- 增加绑定流程：把第二个 provider 的 baasUid 绑定到同一 appUserId

**验收标准**
- 用 Apple 登录生成 appUserId 后，再绑定微信登录；以后用微信也能访问同一份 `users/{appUserId}` 数据

**阶段 4：为未来迁移 BaaS 做准备（真正可插拔）**
- 把 `RemoteGateway` 作为依赖注入的“实现位”，不在业务层引用具体 BaaS SDK
- 抽象出 `RemoteGatewayFactory`，按配置切换 Firebase / 腾讯云实现

**验收标准**
- 仅改装配层配置即可切换远端实现（核心业务代码与同步 core 不改）

---

## 七、你当前代码里最关键的改造点（方向性）
- `scopeUid` 统一语义：改为 `appUserId`
- 远端路径：仍是 `users/{scopeUid}`，但 now `scopeUid` 已是 appUserId（FirestoreRemoteGateway 逻辑不一定要大改）
- `main.dart`：数据库 `name:` 参数从固定值（如 `app_database`）改成拼接 `appUserId`，实现分库（见 [AppDatabase 构造](file:///Users/jingtaiwei/Git/codex/xuan/common/lib/database/app_database.dart#L35-L110) 与 [main.dart 注入](file:///Users/jingtaiwei/Git/codex/xuan/lib/main.dart#L96-L180)）

---
