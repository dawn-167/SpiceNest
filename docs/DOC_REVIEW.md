# SpiceNest 新增文档审阅意见

> 审阅日期：2026-08-27
> 审阅对象：`docs/QUALITY_ASSURANCE.md`（恢复版原稿）、`docs/CODE_STANDARDS.md`
> 审阅方式：全文精读 + 与项目现有 8 份文档交叉核对
> 原则：本文档只提意见，**不改动被审阅的原文档**；是否采纳由项目方决定

---

## 一、QUALITY_ASSURANCE.md 审阅

### 1.1 总体评价

质量很高，思路清晰：把"质量"拆成**计划执行保证、Bug 处理、系统性修复、不引入新 Bug** 四个维度，环环相扣，可执行性强。亮点：

- **4 道关卡**（开工前宣读 → 一步一反馈 → 完成后逐项验收 → 计划外变更报批）：把 DEVELOPMENT_PLAN 的"一步一确认"落实成了强制流程
- **Bug 处理 5 步**（复现定位 → 影响分析 → 根因修复 → 回归验证 → 记录归档）：是标准的缺陷生命周期，第 1 步要求"根因一句话说清楚"尤其好
- **机制 2 同类问题全局排查**：配了对照表（修一个参数错误 → 排查同类元器件所有参数），能有效避免"修一个留一片"
- **4 条原则**（最小化修改/编译+运行/行为对比/边界条件）：与 CODE_STANDARDS 的提交前自查互补
- **Bug 记录模板**：字段完整（编号/现象/复现/根因/影响/方案/文件/回归/同类排查），可直接照用

### 1.2 与现有文档的一致性核对

**✅ 一致的部分**

| QA 文档内容 | 对应文档 | 结论 |
|------------|---------|------|
| 关卡 1-3（宣读/反馈/验收） | DEVELOPMENT_PLAN 执行原则"一步一确认" | 一致 |
| 原则 2（修改后必须编译+运行） | CHECKLIST 4.1-4.2、CODE_STANDARDS 九 | 一致 |
| 原则 1（一次提交只做一件事） | CODE_STANDARDS 6.5 | 一致 |
| 内容类验证（官方文档交叉验证+用户审核） | DEVELOPMENT_PLAN 第 3 步、content-guide 第九章 | 一致 |
| 边界条件测试 | CHECKLIST 5.1 | 一致 |

**⚠️ 不一致的部分**

| 项 | QA 文档 | 现有文档 | 问题 |
|----|--------|---------|------|
| 性能指标 | 启动 < 1s、搜索 < 10ms、内存 < 50MB（五、验证手段） | CHECKLIST 4.2：启动 < 2s、搜索 < 100ms、内存 < 100MB；DEVELOPMENT_PLAN 第 8 步：启动 < 2s、搜索 < 100ms、内存 < 50MB | 三份文档三组数字，QA 文档与 architecture.md（<1s/<10ms/<50MB）一致，但与 CHECKLIST/DEVELOPMENT_PLAN 不一致 |
| 版本号 | v1.0 | 其他文档均 v0.x（0.1/0.2/0.3） | 版本风格不统一 |

### 1.3 建议（不强制，供决策）

1. **性能指标统一**：建议明确"开发目标（严）与发布下限（宽）"两层口径——如 QA/architecture 的 <1s/<10ms/<50MB 为开发目标，CHECKLIST 的 <2s/<100ms/<100MB 为发布下限，并在 CHECKLIST 或 QA 文档注明关系；否则将来验收时"谁说了算"会扯皮。
2. **Bug 归档位置**：第 5 步说"记录到本文档末尾的「Bug 记录」章节"，但文档里只有「Bug 记录模板」章节，没有实际记录区。建议：要么在末尾加一个「Bug 记录」实际章节（列表式追加），要么独立成 `docs/BUG_LOG.md`（更推荐，避免 QA 文档越来越长）。
3. **文档关系定位**：建议在开头补一小节"与现有文档的关系"——PLAN_REVIEW=计划审阅（开工前一次性）、QUALITY_ASSURANCE=开发过程质量（持续）、CHECKLIST=发布前全量检查（门禁）、content-guide 第九章=内容逐条审核（内容类）。四者目前职责清晰不重叠，但文档间没有互相引用，后续维护时容易迷失。
4. **全量回归的成本**：机制 3 要求每修一个 bug 跑"当前阶段所有已通过验收项"，MVP 阶段内容少可接受；到第三阶段（150+ 内容）后建议引入自动化或抽样，否则回归会越来越重。可在 ROADMAP 第三阶段"体验优化"里挂一条。
5. **严重程度分级**：阻断性/影响功能/体验问题/文案错误——建议与 CHECKLIST 的"有条件通过"定义挂钩（阻断性未清 → 不通过），形成闭环。

---

## 二、CODE_STANDARDS.md 审阅

### 2.1 总体评价

（此前审阅结论，汇总至此）整体质量很高——五层架构、单向依赖、协议驱动、状态集中，规则可执行，还带提交前自查清单。

### 2.2 与现有文档一致的部分

| 规范内容 | 对应文档 | 结论 |
|---------|---------|------|
| 五层架构 App/Models/Services/Views/Common | architecture.md 二 | 一致 |
| Common 只读不改 | SPECIFICATION 9.2、CHECKLIST 4.4 | 一致 |
| 无强制解包、文件顶部标注用途 | CHECKLIST 4.1 | 一致 |
| 错误处理（加载/搜索/计算器） | architecture.md 七 | 逐条吻合 |
| 空关键词→首页、无结果→空状态 | architecture.md 7.2 | 一致 |

### 2.3 需对齐的 3 处

1. **AppState vs 单例 AppDelegate**：architecture.md 决策 8.2 明确"单例 AppDelegate 管理页面状态，不引入额外抽象"；CODE_STANDARDS 5.1 却引入独立单例 `AppState`（currentPage/currentQuery/selectedContent）。两处是重叠状态源，**需二选一或明确分工**（建议：状态归 AppState，AppDelegate 只管生命周期/窗口/路由，并同步修订 architecture 8.2）。
2. **Protocol 强制要求**：CODE_STANDARDS 4.2"所有 Service 必须定义 protocol"，但 architecture.md 3.2/3.3 的 `ContentLoader`/`SearchService` 都是直接 `final class`，未提 protocol。建议在 architecture.md 补一句"Service 层遵循 CODE_STANDARDS 协议驱动约定"。
3. **内部表述矛盾**：1.4 说 View 把操作"上报给 App 层**或 Service**"，5.2 却说"上报给 App 层"。统一为一种（建议：统一走 App 层，保持单一路由）。

### 2.4 小建议

- **版本号风格**：v1.0 与全项目 v0.x 不统一（与 QA 文档同样问题）
- **"回归测试"超前**：6.5 说"提交前跑回归测试"，但 DEVELOPMENT_PLAN 用的是临时测试代码，MVP 无测试框架；建议注明"MVP 阶段以手动验证代替"
- **全局常量命名**：7.1"大驼峰**或** k 前缀（项目内统一）"给了两个选项又没定死，建议直接指定一个
- **魔法数字示例**：7.2 用"为什么是 0.12 而不是 0.15"举例，正好呼应 alpha 修订，例子选得好

---

## 三、两份文档与现有体系的衔接

| 场景 | 走哪份文档 |
|------|-----------|
| 开工前计划审阅 | PLAN_REVIEW.md（已清零） |
| 每步开发执行 | DEVELOPMENT_PLAN.md + QA 关卡 1-4 |
| 开发中遇到 bug | QA 五步流程 + CODE_STANDARDS 提交自查 |
| 写代码前看规范 | CODE_STANDARDS.md |
| 写内容前看格式 | content-guide.md |
| 发布前全量检查 | CHECKLIST.md |

两份新文档与现有体系**职责互补、无冲突**，主要遗留问题是：

1. 性能指标三处数字不统一（QA/architecture vs CHECKLIST vs DEVELOPMENT_PLAN）
2. AppState 与"单例 AppDelegate"的架构决策冲突
3. 版本号风格不统一（v1.0 vs v0.x）
4. QA 文档缺实际"Bug 记录"归档区

---

## 四、审阅结论

两份文档均可**原样投入使用**，无阻断性问题。建议按上述清单择机对齐（预计改动量小、都是文档级调整），优先级：性能指标统一（P1）> AppState 分工（P1）> Bug 记录归档区（P2）> 版本号风格（P2）。

---

---

## 五、复核记录（2026-08-27 二次审阅）

对项目方修订后的文档逐项抽查，**全部问题已确认修复**：

| 项 | 结论 | 抽查证据 |
|----|------|---------|
| 1. 性能指标统一 | ✅ | QUALITY_ASSURANCE 五：明确"开发目标 <1s/<10ms/<50MB，发布下限见 CHECKLIST"；CHECKLIST 4.2 标注"发布下限"，并注明开发目标见 architecture/QA；DEVELOPMENT_PLAN 第 8 步同步"发布下限 + 开发目标"两层口径 |
| 2. Bug 归档位置 | ✅ | 新建独立 docs/BUG_LOG.md（含使用说明/编号规则/模板/统计表），QA 第 5 步改为"记录到 BUG_LOG.md，不在本文档内追加" |
| 3. 文档关系定位 | ✅ | QUALITY_ASSURANCE 新增「〇、与现有文档的关系」章节（PLAN_REVIEW/QA/CHECKLIST/content-guide/CODE_STANDARDS 职责表 + 流程衔接）；README 文档导航同步补充三份新文档 |
| 4. 全量回归成本 | ✅ | QA 机制 3 加备注：MVP 手动回归可接受，第三阶段规划自动化/抽样回归 |
| 5. 严重程度分级 | ✅ | QA 第 2 步与 BUG_LOG 使用说明均将严重程度与 CHECKLIST 结论挂钩（阻断性→不通过，影响功能→有条件通过） |
| 6. AppState vs AppDelegate | ✅ | architecture 8.2 决策改为"AppState 单例管状态，AppDelegate 只做协调"，3.1 关键属性同步，CODE_STANDARDS 5.1 保持一致 |
| 7. Protocol 强制同步 | ✅ | architecture 3.2/3.3 补充"协议驱动：遵循 CODE_STANDARDS 第四章，定义 ContentLoaderProtocol/SearchServiceProtocol" |
| 8. 1.4 vs 5.2 表述 | ✅ | CODE_STANDARDS 1.4 统一为"上报给 App 层（统一走 App 层路由，不直接调 Service）" |
| 9. 版本号风格 | ✅ | QUALITY_ASSURANCE / CODE_STANDARDS / BUG_LOG 均为 v0.4，与全项目 v0.x 风格统一，版本历史完整 |
| 10. 回归测试超前 | ✅ | CODE_STANDARDS 6.5 注明"MVP 阶段以手动验证代替自动化测试" |
| 11. 全局常量命名 | ✅ | CODE_STANDARDS 7.1 定死"k 前缀 + 大驼峰（项目内统一）" |

**附加确认**：architecture.md 版本历史补记 v0.4；QUALITY_ASSURANCE / CODE_STANDARDS 版本历史均含 v0.3（初始）→ v0.4（修订）两行。

**结论**：DOC_REVIEW 全部意见已落实，两份新文档与现有体系完全对齐，可进入 MVP 开发。

---

*本审阅意见只记录问题与建议，未修改任何被审阅文档；是否采纳、由谁修改，请项目方决定。*
