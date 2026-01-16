# Shared Card Template（主题市场）原子化 ToDo

## 0. 前提（不回归约束）
- P0-1：EditableFourZhuCard 编辑器链路不变：只读写 `t_layout_templates`（模板 JSON schema 不改）。
- P0-2：市场“版本”不可变：安装永远基于 version payload 生成新的本地模板副本。
- P0-3：市场来源映射单独落表：不把 market_id/version_id 混进 `t_card_template_meta.createFromCardUuid`。
- P0-4：首版不引入 crypto；hash/size_bytes 由服务端返回（App 只透传 schema_version/template_json）。

---

## 1. Phase 1：本地数据库（Drift）

|ID|任务（原子）|输入|输出|改动（文件）|验收点|
|---|---|---|---|---|---|
|SCT-DB-001|新增表 `MarketTemplateInstalls`|表结构定义|可生成 drift 表|common/lib/database/tables/tables.dart|能编译通过|
|SCT-DB-002|为 installs 表增加索引（market_template_id/version_id）|索引名/DDL|drift indexes 生效|common/lib/database/tables/tables.dart|可按字段查询性能可控|
|SCT-DB-003|新增 DAO 文件与 accessor 声明|表名/Record 类型|DAO 可被注入使用|common/lib/database/daos/market_template_installs_dao.dart|能 build_runner 生成 g.dart|
|SCT-DB-004|DAO: findByLocalTemplateUuid|localTemplateUuid|Install 记录/空|同上|软删除数据不会返回|
|SCT-DB-005|DAO: upsertInstall|install 数据|插入或更新成功|同上|重复 upsert 不产生多条|
|SCT-DB-006|DAO: softDeleteByLocalTemplateUuid|localTemplateUuid|受影响行数|同上|deletedAt 写入且查询不可见|
|SCT-DB-007|DAO: listByMarketTemplateId（可选 limit）|marketTemplateId/limit|安装列表|同上|按 installedAt/id 排序一致|
|SCT-DB-008|注册 table/dao 到 AppDatabase 注解|表/dao 名|drift 识别|common/lib/database/app_database.dart|编译通过|
|SCT-DB-009|schemaVersion 6→7 + onUpgrade 创建表|from/to|可平滑升级|common/lib/database/app_database.dart|升级后 validateDatabaseSchema 通过|
|SCT-DB-010|新增 DAO 单测文件骨架|测试用 db/dao|测试可运行|common/test/database/market_template_installs_dao_test.dart|测试可执行|
|SCT-DB-011|单测：upsert + find roundtrip|样例 install|断言通过|同上|pass|
|SCT-DB-012|单测：softDelete 后 find 返回 null|样例 install|断言通过|同上|pass|
|SCT-DB-013|单测：listByMarketTemplateId 过滤 deleted|多条 install|断言通过|同上|pass|

---

## 2. Phase 2：市场 Remote Gateway 与 DTO（先无 UI 打通）

|ID|任务（原子）|输入|输出|改动（文件）|验收点|
|---|---|---|---|---|---|
|SCT-MKT-001|新增 DTO：MarketTemplateSummaryDto|列表字段定义|可反序列化列表项|common/lib/features/shared_card_template/market/dtos/market_template_summary_dto.dart|fromJson/toJson 单测通过|
|SCT-MKT-002|新增 DTO：MarketTemplateDetailDto|详情字段定义|可反序列化详情|common/lib/features/shared_card_template/market/dtos/market_template_detail_dto.dart|单测通过|
|SCT-MKT-003|新增 DTO：MarketTemplateVersionDto|版本字段定义|可反序列化版本列表|common/lib/features/shared_card_template/market/dtos/market_template_version_dto.dart|单测通过|
|SCT-MKT-004|新增 DTO：MarketTemplatePayloadDto|payload 字段定义|可反序列化 template_json|common/lib/features/shared_card_template/market/dtos/market_template_payload_dto.dart|单测通过|
|SCT-MKT-005|新增 MarketGateway 接口（list/detail/payload/publish）|接口契约|可被 usecase 依赖|common/lib/features/shared_card_template/market/market_gateway.dart|编译通过|
|SCT-MKT-006|DioMarketGateway：实现 listTemplates|baseUrl|能请求列表|common/lib/features/shared_card_template/market/dio_market_gateway.dart|手动 mock / 集成可跑|
|SCT-MKT-007|DioMarketGateway：实现 getTemplateDetail|get id|能请求详情|同上|同上|
|SCT-MKT-008|DioMarketGateway：实现 getVersionPayload|get versionId|能拉取 payload|同上|同上|
|SCT-MKT-009|DioMarketGateway：实现 publishTemplate/publishVersion|发布参数|能发布成功|同上|同上|

---

## 3. Phase 3：安装/发布 UseCase（对齐现有模板 UseCase）

|ID|任务（原子）|输入|输出|改动（文件）|验收点|
|---|---|---|---|---|---|
|SCT-UC-001|新增 InstallMarketTemplateVersionUseCase 壳|依赖清单|可实例化 usecase|common/lib/domain/usecases/shared_card_template/install_market_template_version_use_case.dart|编译通过|
|SCT-UC-002|实现安装：拉 payload→生成新 uuid→写模板|marketTemplateId/versionId/collectionId|localTemplateUuid|同上 + common/lib/datasource/...（若需要）|安装后可从本地读到模板|
|SCT-UC-003|安装时写入 installs 映射|localTemplateUuid + market ids|install 记录落库|Phase1 DAO|DB 有映射且未软删|
|SCT-UC-004|安装时 touch meta（created/modified）|localTemplateUuid|meta 存在|common/lib/database/daos/card_template_meta_dao.dart|meta 可查询|
|SCT-UC-005|安装 usecase 单测（FakeGateway + 内存 DB）|fake payload|断言通过|common/test/.../install_market_template_version_use_case_test.dart|pass|
|SCT-UC-006|新增 PublishMarketTemplateUseCase 壳|依赖清单|可实例化 usecase|common/lib/domain/usecases/shared_card_template/publish_market_template_use_case.dart|编译通过|
|SCT-UC-007|实现发布：读取本地模板→调用 gateway 发布|localTemplateUuid + 表单字段|marketTemplateId/versionId|同上|fake gateway 可断言入参|
|SCT-UC-008|发布 usecase 单测（FakeGateway）|fake gateway|断言通过|common/test/.../publish_market_template_use_case_test.dart|pass|

---

## 4. Phase 4：UI 集成（最小侵入编辑器）

|ID|任务（原子）|输入|输出|改动（文件）|验收点|
|---|---|---|---|---|---|
|SCT-UI-001|新增 MarketListViewModel|MarketGateway|列表状态管理|common/lib/features/shared_card_template/viewmodels/market_list_view_model.dart|加载/错误态可用|
|SCT-UI-002|新增 MarketDetailViewModel|MarketGateway|详情/版本/下载状态|common/lib/features/shared_card_template/viewmodels/market_detail_view_model.dart|可触发下载动作|
|SCT-UI-003|新增市场列表页|viewmodel|可浏览列表|common/lib/features/shared_card_template/pages/shared_template_market_list_page.dart|能进入详情页|
|SCT-UI-004|新增市场详情页|market_template_id|可展示版本并下载|common/lib/features/shared_card_template/pages/shared_template_market_detail_page.dart|下载成功提示|
|SCT-UI-005|在编辑器入口增加“主题市场”按钮|导航策略|可进入市场页|common/lib/pages/four_zhu_edit_page.dart|入口可达|
|SCT-UI-006|下载后跳回编辑器并选中新模板|localTemplateUuid|选中模板并渲染|common/lib/viewmodels/four_zhu_editor_view_model.dart|selectTemplate 生效|
|SCT-UI-007|新增发布表单页|本地模板 id + 表单字段|可提交发布|common/lib/features/shared_card_template/pages/publish_market_template_page.dart|能调用 Publish usecase|
|SCT-UI-008|编辑器增加“发布到主题市场”入口|当前模板|进入发布页|common/lib/...（编辑器菜单所在文件）|入口可达|

---

## 5. Phase 5：回归验证（原子检查项）

|ID|检查项（原子）|步骤|期望|
|---|---|---|---|
|SCT-QA-001|编辑器加载模板列表|打开编辑页|模板列表正常展示|
|SCT-QA-002|编辑器保存模板|修改并保存|保存成功且可重新加载|
|SCT-QA-003|编辑器复制/创建模板|执行复制/创建|新模板 uuid 不冲突|
|SCT-QA-004|setting overlay 对安装模板生效|为新 uuid 写 setting 后重进|主题覆盖生效|
|SCT-QA-005|切换模板写入使用日志（若注入 DAO）|切换模板|`t_card_template_skill_usage` 新增记录|
|SCT-QA-006|DB 升级校验|从旧版本启动|validateDatabaseSchema 通过|
