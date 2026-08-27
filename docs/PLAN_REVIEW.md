# SpiceNest 开发计划审阅清单

> 生成日期：2026-08-27
> 说明：开工前对项目计划（README / SPECIFICATION / ROADMAP / CHECKLIST / docs/*4 + content/ 目录）进行逐份精读与交叉核对，发现计划中的瑕疵与矛盾。
> 目的：作为开工前"计划修订"的执行清单——先消除瑕疵、定夺分歧，再启动 MVP 开发，避免带着不一致的文档写代码。

---

## 检查范围

| 对象 | 状态 |
|------|------|
| README.md | ✅ 已通读 |
| SPECIFICATION.md（1088 行） | ✅ 已通读 |
| ROADMAP.md（358 行） | ✅ 已通读 |
| CHECKLIST.md（365 行） | ✅ 已通读 |
| docs/DEVELOPMENT_PLAN.md（372 行） | ✅ 已通读 |
| docs/architecture.md（449 行） | ✅ 已通读 |
| docs/content-guide.md（793 行） | ✅ 已通读 |
| docs/ui-design.md（597 行） | ✅ 已通读 |
| content/ 目录（含隐藏文件） | ✅ 已检查（原 5 个子目录全空；复核时已重建为 7 个库目录，内容仍为空） |

---

## 问题分类汇总

| 分类 | 问题数 | 优先级 |
|------|--------|--------|
| A. 目录结构与实际不符 | 4 | P0 |
| B. 文档间字段/数值/命名不一致 | 10 | P0/P1 |
| C. 内容准确性问题 | 2 | P1 |
| D. 规划矛盾（跨阶段） | 2 | P1 |
| E. 其他瑕疵 | 4 | P2 |

---

## A. 目录结构与实际不符（P0）

### A1. content/ 子目录与规划完全不一致 ✅ 已修订

- **位置**：README 项目结构 vs 实际 `content/` 目录
- **问题**：README 规划六大内容库 `commands/parameters/errors/formulas/tips/topologies`；实际只有 `errors/images/parameters/templates/tutorials` 五个，且**全部为空**（含隐藏文件检查）。
- **影响**：缺 4 个规划目录（commands/formulas/tips/topologies），多 2 个未规划目录（templates/tutorials）。
- **建议**：删掉多余的 images/templates/tutorials，或明确它们的用途；按文档规划建齐六大库目录。

### A2. content/images 与"纯文本、无截图"原则矛盾 ✅ 已修订（保留，标注为拓扑预览图预留）

- **位置**：实际 `content/images/` vs content-guide 1.3、architecture 5.3
- **问题**：文档明确"查询助手不使用截图，所有内容用文字和代码描述"，却存在 images 目录。
- **建议**：删除，或在文档中说明该目录的未来用途（如拓扑预览图，architecture 5.3 提到"可选"）。

### A3. content/tutorials 与"不做教程"原则矛盾 ✅ 已修订（已删除目录）

- **位置**：实际 `content/tutorials/` vs SPECIFICATION 1.4、README 定位
- **问题**：产品定位"查完就走，不做教程"，目录名却是 tutorials，疑似 v0.1 教程导向时代遗留。
- **建议**：删除。

### A4. content/templates 无任何文档规划对应 ✅ 已修订（已删除目录）

- **位置**：实际 `content/templates/` vs 全部文档
- **问题**：所有文档只提到外部 `Nexus/TEMPLATE/`（项目模板），项目内部无 templates 目录规划。
- **建议**：删除，避免与 Nexus TEMPLATE 混淆。

### A5. README 中规划的文件全部不存在 ✅ 已修订（README 加"规划中"标注）

- **位置**：README"项目结构"章节
- **问题**：`Sources/`、`Resources/`、`build.sh`、`nexus.json`、`Info.plist`、`CHANGELOG.md` 均不存在（项目处于纯文档阶段属正常，但 README 结构图未标注"规划中"）。
- **建议**：README 项目结构图加"规划中"标注，或在开工时按 DEVELOPMENT_PLAN 第 1 步补齐。

---

## B. 文档间字段/数值/命名不一致

### B1. 指令详情文件名前缀互相矛盾（P0） ✅ 已修订（统一为 command-<id>.json）

- **位置**：SPECIFICATION 6.1 vs DEVELOPMENT_PLAN 第 3b / content-guide 3.1
- **问题**：SPECIFICATION 写 `commands/tran.json`、`commands/ac.json`（不带 `command-` 前缀）；DEVELOPMENT_PLAN 和 content-guide 写 `commands/command-tran.json`（带前缀，与 id 一致）。
- **影响**：ContentLoader 按 id 找文件时会 404，属于会导致运行期 bug 的规则冲突。
- **建议**：统一为带前缀的 `command-<id>.json`（与 index.json 的 id 一致，DEVELOPMENT_PLAN/content-guide 为准），修订 SPECIFICATION 6.1。

### B2. 快捷键写法混用（Option vs Alt）（P1） ✅ 已修订（统一为 Ctrl+Option+S）

- **位置**：SPECIFICATION 4.5（`Ctrl+Alt+S`）、ui-design 首页布局图（`[Ctrl]+[Alt]+[S]`）vs README、SPECIFICATION 9.1、ROADMAP、DEVELOPMENT_PLAN、ui-design 8.2（`Ctrl+Option+S`）
- **问题**：同一全局热键三种写法混用。macOS 上 Alt 键帽就是 Option，但文档应统一。
- **建议**：全项目统一为 `Ctrl+Option+S`（与 macOS 键帽命名一致），4.5 表格和 ui-design 首页图同步修改。

### B3. 快捷键清单不一致（P1） ✅ 已修订（SPECIFICATION 补齐 Cmd+F、Cmd+1~6）

- **位置**：SPECIFICATION 4.5 vs ui-design 8.2
- **问题**：ui-design 多了 `Cmd+F`（聚焦搜索框）、`Cmd+1~6`（快速分类切换），SPECIFICATION 键盘交互表没有。
- **建议**：以一处为准（建议 ui-design 为准，补齐 SPECIFICATION 4.5 表格）。

### B4. 主题色叠加 alpha 内部矛盾（P0） ✅ 已修订（统一 alpha 0.12，green 0.584）

- **位置**：SPECIFICATION 4.1（alpha 0.15）vs SPECIFICATION 8.1 与 ui-design 2.2（alpha 0.12）
- **问题**：同一文档内部两处数值不一致（0.15 vs 0.12）；另有 green 通道 0.58（SPECIFICATION 8.1）vs 0.584（ui-design 2.2）的微小差异。
- **影响**：视觉实现时不知道以哪个为准。
- **建议**：统一 alpha 0.12（8.1/ui-design 为准），green 通道统一 0.584。

### B5. 卡片悬停上浮高度不一致（P1） ✅ 已修订（统一为 3pt）

- **位置**：SPECIFICATION 8.3（4pt）vs DEVELOPMENT_PLAN 第 5 步、ui-design 6.2（3pt）
- **建议**：统一为 3pt（两处为准），修订 SPECIFICATION 8.3。

### B6. TopologyDetail 缺 difficulty 字段（P1） ✅ 已修订（SPECIFICATION 5.2 补上）

- **位置**：SPECIFICATION 5.2 vs DEVELOPMENT_PLAN 第 2 步、content-guide 8.3
- **问题**：后两者都有 `difficulty`（入门/基础/进阶/高级），SPECIFICATION 的 TopologyDetail 没有。
- **建议**：SPECIFICATION 5.2 补上 difficulty 字段。

### B7. FormulaDetail 字段不一致（P1） ✅ 已修订（SPECIFICATION 5.2 补上 description，删除 expression）

- **位置**：SPECIFICATION 5.2 vs content-guide 6.3、DEVELOPMENT_PLAN 第 2 步
- **问题**：SPECIFICATION 的 FormulaDetail 没有 `description` 字段，content-guide/DEVELOPMENT_PLAN 都有（且 SPECIFICATION 自己的 3.5 公式卡片结构也展示了说明文字）。
- **建议**：SPECIFICATION 5.2 补上 description。

### B8. 元器件参数数量规划不一致（P1） ✅ 已修订（ROADMAP 注明首批与最终关系）

- **位置**：SPECIFICATION 3.3（BJT 40+ / MOSFET 35+ / 二极管 25+）vs ROADMAP 第二阶段（BJT 25+ / MOSFET 20+ / 二极管 15+）vs content-guide 4.5（BJT 40 / MOSFET 35 / JFET 15 / 二极管 25）
- **问题**：SPECIFICATION 与 content-guide 一致，ROADMAP 数字偏小且二极管 15+ 差异明显。
- **建议**：ROADMAP 数字对齐 SPECIFICATION/content-guide（或明确注明是"第二阶段首批"而非最终量）。

### B9. 拓扑数量规划不一致（P1） ✅ 已修订（ROADMAP 注明首批 20 个，最终 25+）

- **位置**：SPECIFICATION 3.7（清单约 34 个，预计 25+）vs ROADMAP 第三阶段（20 个）vs ROADMAP M3 里程碑（20 拓扑）
- **建议**：明确"第三阶段首批 20 个"与"最终 25+（34 个）"的关系，或统一数字。

### B10. 内容总量规划不一致（P2） ✅ 已修订（ROADMAP 注明 150+ 是 M3 下限，200-300 是最终目标）

- **位置**：SPECIFICATION 7.3 决策5、architecture 8.3（200-300 条）vs ROADMAP M3（150+ 条）
- **建议**：注明 150+ 是 M3 交付下限，200-300 是最终目标，两者不冲突但应写明。

### B11. 指令扩充阶段重复规划（P1） ✅ 已修订（ROADMAP 改为"将 SPECIFICATION 清单中剩余指令分批落地"）

- **位置**：ROADMAP 第三阶段 vs SPECIFICATION 3.2 指令清单
- **问题**：ROADMAP 说第三阶段"扩充到 25+（补充 .noise, .four, .save, .plot, .subckt, .include, .lib, .param, .func, .global, .nodeset 等）"，但这些指令在 SPECIFICATION 3.2 的完整清单（含第一阶段 10 个之外的其余）里已经全部列出。
- **建议**：ROADMAP 第三阶段改为"把 SPECIFICATION 清单中的指令分批落地"，避免"补充"表述误导。

---

## C. 内容准确性问题（P1）

### C1. "Timestep too small" 拼写混乱且疑似重复条目 ✅ 已修订（验证确认原文为"Time step too small"带空格，删除无空格重复条目）

- **位置**：SPECIFICATION 3.4、ROADMAP 第一阶段、DEVELOPMENT_PLAN 第 3b、content-guide 5.2 用 "Time step too small"（带空格）；SPECIFICATION 3.4 清单里又单独列了 "Timestep too small"（无空格）
- **问题**：LTspice 实际报错原文是 **"Timestep too small"**（无空格）。带空格的版本会影响 errorPattern 精确匹配；SPECIFICATION 3.4 同时列两条同一错误，有凑数嫌疑。
- **建议**：errorPattern 统一为无空格原文；如担心用户复制带空格的版本，可在 tags 里加同义词，而不是重复列条目。所有文档核对一遍。

### C2. 错误类别分类缺少"命名错误"类 ✅ 已修订（content-guide 补充 Duplicate device name → structure 映射说明）

- **位置**：SPECIFICATION 3.4 错误类别含"命名错误"（Duplicate device name）；content-guide 5.3 的六类（convergence/structure/parameter/syntax/file/model）没有对应类别
- **问题**：Duplicate device name 在 content-guide 分类下无处安放（可归 structure，但未说明）。
- **建议**：在 content-guide 5.4 category 说明里补充映射（如 Duplicate device name → structure），或新增 naming 类并同步 CHECKLIST。

---

## D. 规划矛盾（P1）

### D1. 公式计算器"自定义表达式"三处冲突 ✅ 已修订（定硬编码方案，删 SPECIFICATION expression 字段，ROADMAP 第四阶段改"仅支持预设公式选择"）

- **位置**：SPECIFICATION 5.2 `Calculator.expression` 字段（暗示自定义表达式求值）vs architecture 8.4（"硬编码，不做通用表达式解析器"）vs ROADMAP 第四阶段（"用户自定义公式 JSON 导入 + **自定义计算器表达式**"）
- **问题**：架构决策明确拒绝通用表达式解析，但第四阶段又规划自定义表达式；SPECIFICATION 的 expression 字段也与硬编码决策冲突。
- **建议**：提前定夺方案二选一：
  1. 维持硬编码：删掉 SPECIFICATION 5.2 的 expression 字段，第四阶段"自定义计算器表达式"改为"仅支持从预设公式列表中选择"；
  2. 支持自定义：architecture 8.4 和 content-guide 6.5（"新公式必须加计算函数"）相应放宽，并评估安全风险（表达式注入）。

### D2. content/tutorials 与"不做教程"定位矛盾 ✅ 已修订（同 A3，已删除目录）

- **位置**：实际目录 vs SPECIFICATION 1.4（"查完就走：不做教程、不做长文"）
- **说明**：与 A3 重复记录，此处标注为规划层面矛盾，处理方式同 A3。

---

## E. 其他瑕疵（P2）

### E1. .tran 语法展示与完整语法顺序不符 ✅ 已修订（SPECIFICATION 和 ui-design 统一改为 .tran tstart tstop [tmax [tstep]]）

- **位置**：ui-design 6.2 搜索结果卡片示例（`语法: .tran tstop [tstart [tmax]]`）
- **问题**：完整语法顺序是 `.tran <tstart> <tstop> <tmax> <tstep>`（tstart 在 tstop 前，见 SPECIFICATION 3.2 / content-guide 3.2），卡片示例顺序相反且漏了 tstep。
- **建议**：卡片示例改为 `.tran tstart tstop [tmax [tstep]]` 或直接复用 content-guide 的语法列表。

### E2. 指令参数被归入"参数词典"分组 ✅ 已修订（SPECIFICATION 和 ui-design 删除搜索结果中独立参数词典项）

- **位置**：SPECIFICATION 3.1 搜索结果布局示例
- **问题**：把 `tmax — 最大时间步长` 放进"📖 参数词典"分组；但参数词典定义是**元器件参数**（BJT/MOSFET 等），指令参数应属于指令卡片的"参数说明"区，不属于独立搜索结果。
- **建议**：删掉该行，或明确"指令参数也可作为独立结果返回（type 仍为 command）"的规则。

### E3. SPECIFICATION 9.2 Nexus 合规清单全部标 [x] ✅ 已修订（全部改为 [ ]，加注"实现后逐项勾选"）

- **位置**：SPECIFICATION 9.2
- **问题**：项目 0 实现，清单却全部勾选 [x]，容易误导为"已完成"（实际是"承诺遵守"）。
- **建议**：改为全部 [ ] 并加注"实现后逐项勾选"，与 CHECKLIST 4.4 的勾选状态保持一致。

### E4. CHECKLIST 发布版本为占位符 ⬜ 无需修改（发布前更新即可）

- **位置**：CHECKLIST 末尾（发布版本 v0.0.0、发布日期 YYYY-MM-DD）
- **说明**：占位属正常，仅提示发布前需更新。不强制修改。

---

## 修订优先级建议

1. **P0（开工前必改）**：A1-A5 目录整理；B1 指令文件名前缀；B4 alpha 数值。
2. **P1（MVP 前改）**：B2-B3 快捷键统一；B5 悬停高度；B6-B7 数据模型补字段；B8-B9 数量对齐；B11 阶段表述；C1-C2 错误内容；D1 计算器方案定夺。
3. **P2（顺手改）**：B10 总量表述；E1-E3 细节修正。

---

---

## 复核记录（2026-08-27 二次审阅）

对用户修订后的全部文档逐项抽查，**19/19 项全部确认修复**：

| 项 | 结论 | 抽查证据 |
|----|------|---------|
| A1 目录建齐 | ✅ | content/ 现有 commands/errors/formulas/images/parameters/tips/topologies 7 个目录 |
| A2 images 保留说明 | ✅ | README 结构图标注"预留：拓扑预览图（可选，MVP 阶段不用）" |
| A3/A4 templates/tutorials | ✅ | 目录已删除 |
| A5 规划中标注 | ✅ | README 加"注意：以下为规划中的完整结构"，各文件标【规划中】 |
| B1 文件名前缀 | ✅ | SPECIFICATION 6.1 统一为 command-tran.json 等，与 DEVELOPMENT_PLAN/content-guide 一致 |
| B2 快捷键写法 | ✅ | SPECIFICATION 4.5 统一 Ctrl+Option+S（原 Ctrl+Alt+S） |
| B3 快捷键清单 | ✅ | SPECIFICATION 4.5 已补 Cmd+F、Cmd+1~6 |
| B4 alpha/green | ✅ | 4.1 与 8.1 均 alpha 0.12、green 0.584，ui-design/DEVELOPMENT_PLAN 一致 |
| B5 悬停高度 | ✅ | SPECIFICATION 8.3 改 3pt |
| B6 TopologyDetail | ✅ | SPECIFICATION 5.2 补 difficulty |
| B7 FormulaDetail | ✅ | 补 description，删 expression，Calculator 注释明确硬编码 |
| B8-B10 数量 | ✅ | ROADMAP 注明"首批…最终对齐 SPECIFICATION…"，150+ 标注为 M3 下限 |
| B11 指令扩充 | ✅ | ROADMAP 改"将 SPECIFICATION 清单中剩余指令分批落地" |
| C1 错误拼写 | ✅ | 删除无空格重复条目；用户实测确认原文为"Time step too small"（带空格） |
| C2 错误类别 | ✅ | content-guide 5.4 structure 类补充 Duplicate device name 映射 |
| D1 计算器方案 | ✅ | 定硬编码方案：删 expression 字段，ROADMAP 第四阶段改"仅支持预设公式选择" |
| D2 tutorials 矛盾 | ✅ | 同 A3 |
| E1 .tran 语法 | ✅ | SPECIFICATION 3.1 与 ui-design 6.2/7.2 统一为 `.tran tstart tstop [tmax [tstep]]` |
| E2 参数词典分组 | ✅ | 搜索结果布局已删除独立参数词典项 |
| E3 合规清单勾选 | ✅ | SPECIFICATION 9.2 全部改为 [ ] |
| E4 CHECKLIST 占位 | ⬜ | 无需修改（发布前更新即可） |

**附加确认**：SPECIFICATION / ROADMAP / content-guide / ui-design 四份文档版本历史均已补记 v0.3（PLAN_REVIEW 修订），变更可追溯。

**结论**：清单全部清零，计划文档已对齐，可以按 DEVELOPMENT_PLAN 启动 MVP 开发。

---

*本清单由文档交叉核对生成，修订时以 SPECIFICATION / content-guide / ui-design 三份为准，逐项回填后删除本文件或转入 CHANGELOG 记录。*
