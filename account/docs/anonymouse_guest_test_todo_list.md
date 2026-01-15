# Anonymouse Guest（M9）测试 Todo List

关联文档：anonymouse_guest_test_PRDs.md

执行顺序：按本清单从上到下依次完成。

## 0) 基线与约束（先做一次）

- [ ] 运行 flutter analyze（全仓）
- [ ] 运行 flutter test（全仓）
- [ ] 统一测试初始化：涉及 SharedPreferences 的用例先 setMockInitialValues({})
- [ ] 统一外部依赖策略：FirebaseAuth/Firestore/网络优先 fake/mock（避免不稳定）

## 1) 顺序 1：首次启动生成 guest（单元测试）

目标：验证“游客底座”稳定，不被后续登录流程破坏。

- [x] GuestIdentityStore：首次生成、二次读取一致、clear 后重新生成（account/test/account_test.dart）
- [x] ActiveAccountStore：无 active account → 进入 guest（account/test/account_test.dart）
- [x] ActiveAccountStore：已有 active account → 启动优先进入账号（account/test/account_test.dart）
- [x] ActiveAccountStore：可切回 guest 并清空 active（account/test/account_test.dart）

## 2) 顺序 2：匿名绑定成功/失败降级（单元 + 少量组件测试）

目标：匿名绑定不影响可用性；失败不阻断；成功时 ensureIdentityMapping 被调用。

- [x] AuthCoordinator：guest 模式下 signInAnonymously 会调用 ensureIdentityMapping（account/test/account_test.dart）
- [ ] AuthCoordinator：ensureIdentityMapping 抛错时状态不被破坏（保持 guest 可用）
- [ ] 启动流程：E3 冷启动只尝试一次匿名绑定（可自动化验证）
- [ ] 启动流程：遇到配置型错误码后停止自动重试（可自动化验证）

## 3) 顺序 3：匿名 → 注册新账号保留 appUserId（单元测试）

目标：游客注册后仍使用同一个 appUserId_guest。

- [x] AuthCoordinator：guest 模式下 signInOrRegisterWithEmailPassword 保留 appUserId（account/test/account_test.dart）
- [ ] AuthCoordinator：非 guest 模式下 signInOrRegisterWithEmailPassword 走 resolveAppUserId 分支
- [ ] FirebaseEmailAuthAdapter：匿名 user + createIfMissing 优先走 linkWithCredential（选择其一）
  - [ ] A：通过 emulator 做适配层集成验证
  - [ ] B：引入可控 fake FirebaseAuth，做分支覆盖式测试

## 4) 顺序 4：游客 → 登录既有账号三选一（组件测试为主）

目标：冲突可检测；弹窗交互正确；合并/保留/丢弃三条路径都走通。

- [x] AuthCoordinator：guest 登录既有账号抛 GuestAccountConflict（account/test/account_test.dart）
- [ ] AuthCoordinator：guest 登录账号但 resolveAppUserId == guestId 时不冲突并激活
- [ ] AuthPage：选择“合并”会调用 mergeGuestIntoAccount，随后 activateSession
- [ ] AuthPage：选择“丢弃”会调用 discardGuest，随后 activateSession
- [ ] AuthPage：选择“保留”不调用 delegate，直接 activateSession
- [ ] AuthPage：取消弹窗返回“已取消登录”，active 不改变

## 5) 顺序 5：合并（冲突覆盖/保留两份）与 outbox 重写（数据层集成测试）

目标：验证真实数据迁移与 outbox 重写正确（不仅是方法被调用）。

- [ ] 为可测性重构：把主工程中的合并/丢弃实现抽成可 import 的公开类/函数
- [ ] 合并后：account DB 可见游客期数据；guest DB 被清空
- [ ] 冲突场景：验证覆盖策略或保留两份策略（检查 remap 后引用一致性）
- [ ] outbox：scopeUid 从 guest 改为 account，operationId 重新生成；guest outbox 清空

## 6) 集成验证：离线 / 重启 / 换机一致性（手工为主）

目标：覆盖真实用户路径，发现环境类问题（网络/权限/规则/设备差异）。

- [ ] 离线使用 → 重启 → 数据仍在（同 appUserId_guest）
- [ ] 在线匿名绑定失败 → 不影响本地（不阻断启动、不刷屏）
- [ ] 登录后同账号换机 → 仍能找到同 appUserId（通过 identity_map）

## 退出标准（M9 Done）

- [ ] 单元/组件测试：核心路径用例通过率 100%，连续跑 3 次稳定
- [ ] 数据层集成测试：合并/丢弃/outbox 重写用例全绿
- [ ] 手工验证：离线/重启/换机三条链路均有可复现记录
