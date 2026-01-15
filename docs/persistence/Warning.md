亟待解决的潜在问题（我认为是 P0 级别）

- 同步调度尚未接入应用运行时 ：当前应用装配里有 SyncCoordinator （见 main.dart ），但仓库里没有任何地方在 App 层使用 SyncRuntime （全仓仅在库/文档内出现），意味着“自动 push/pull、backoff、前后台生命周期联动、在线状态 gating”并未真正跑起来。
- 同步只覆盖了 layout_template 的 pull 回填 ： SyncCoordinator.localApplier 目前注入的是 LayoutTemplateLocalDataSource （见同上 main.dart），而 LocalApplier 在设计上是“单入口”，要扩展到多表必须做路由/组合，否则其它 entityType 即使能从远端拉到变更，也无法回填到本地。
- Firestore 远端映射只实现了 layout_template ： FirestoreRemoteGateway._entityDoc 目前只支持 entityType == 'layout_template' （见 persistence_firebase.dart ），你要扩展 common 全表同步和 public 集合，必须把映射与 schema 校验体系化，否则会频繁“unsupported entityType”。
- 主键稳定性是全表同步的硬阻塞 ：common 里存在多张 AutoIncrementingPrimaryKey 的映射/日志表（见 tables.dart ），这些若跨设备同步会产生幂等与冲突灾难，必须先落地你文档 V1 的 stable id/event id 迁移。
- 字典类表缺少一致的数据访问层/DAO 覆盖 ：例如 SubDivinationTypes 当前未看到对应 DAO（而 DivinationTypesDao/SkillsDao/SkillClassesDao 已存在），会导致“公共 pull 回填/用户自定义写入/overlay 计算”在实现时缺统一入口，容易散落在 ViewModel。
- schema/migration 风险 ： AppDatabase.schemaVersion == 6 但 upgrade 分支只处理到 <5 （见 app_database.dart ），后续你一旦增加表或列，很容易在老用户升级路径上出问题（需要尽早建立“每次 schemaVersion 变更必补 migration”的门禁）。
- Firestore Rules 尚未覆盖 public 模型与 entitlement ：目前只有 identity_map/users 的示例规则（见 firebase.rules ），但你要引入 public 读、客户端禁写、以及用户 entitlement 只读等规则，需要尽早定下来，否则测试环境能跑、线上会卡权限。