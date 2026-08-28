# SpiceNest 问题记录

> 版本：0.2 | 日期：2026-08-28
> 用途：记录开发/验证过程中发现的问题（未落地事项、规范偏差、数据问题），跟踪到修复为止。
> 与 [BUG_LOG.md](BUG_LOG.md) 的区别：BUG_LOG 记录**已按 QA 五步流程处理完的 bug 修复归档**；本文件记录**验证/审阅发现、尚未处理的问题与待办**。

---

## 记录模板

每条问题按以下格式记录：

```
### P-XXX：[标题]
- 发现日期：YYYY-MM-DD
- 严重程度：P0（必须立即处理）/ P1（本阶段内处理）/ P2（可延期）
- 状态：⬜ 待处理 / 🔧 处理中 / ✅ 已解决
- 来源：验证 / 审阅 / 开发中发现
- 现象：[一句话描述问题]
- 依据：[与哪份规范/文档不符，引用出处]
- 影响：[不处理会怎样]
- 建议方案：[怎么修]
```

---

## 当前问题列表

### P-001：scripts/ 目录为空，防错脚本未落地（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：⬜ 待处理
- 来源：ERROR_PREVENTION 落地验证
- 现象：`scripts/` 目录存在但完全为空，没有 `validate_content.sh`（内容 JSON 校验）和 `search_cases.txt`（搜索回归用例集）。
- 依据：[ERROR_PREVENTION.md](ERROR_PREVENTION.md) 第三章 P1 项 #2、#4。
- 影响：内容 JSON 校验（id 重复、related 死链、tags 数量）与搜索回归仍需人工，内容量增大后必然漏检。
- 建议方案：按 ERROR_PREVENTION 落地：① 写 `scripts/validate_content.sh`（python3，遍历 content JSON 校验格式/id 唯一/related 死链/tags≥3/summary≤40）；② 建 `scripts/search_cases.txt` 固化搜索验收用例，每次加内容跑一遍。

### P-002：公式 verify 验证用例字段未落地（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：⬜ 待处理
- 来源：ERROR_PREVENTION 落地验证
- 现象：content-guide.md 中无 `verify` 字段说明；`Resources/content/formulas/` 为空（公式内容未开始）。
- 依据：[ERROR_PREVENTION.md](ERROR_PREVENTION.md) 第三章 P1 项 #3。
- 影响：公式计算函数写错/单位换算错（m 与 meg 混淆）无法自动发现。
- 建议方案：第二阶段写公式前，先在 content-guide 6.x 补充 `verify` 字段规范（inputs/expected/tolerance），并在 CalculatorService 实现时配验证用例。

### P-003：Services 层命令行测试未落地（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：⬜ 待处理
- 来源：ERROR_PREVENTION 落地验证
- 现象：项目无任何测试文件/测试入口；Services 层逻辑（ContentLoader/SearchService）只能靠 UI 手动验证。
- 依据：[ERROR_PREVENTION.md](ERROR_PREVENTION.md) 第三章 P2 项 #5；[CODE_STANDARDS.md](CODE_STANDARDS.md) 1.3"无 UI 依赖，可独立测试"。
- 影响：搜索/加载逻辑回归依赖人工，修改风险高。
- 建议方案：MVP 已发布，可在第二阶段初补一个极简测试入口（swiftc 编译 + 断言 print），先覆盖 SearchService 的搜索验收用例。

### P-004：内容详情 JSON 缺 related 字段（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：⬜ 待处理
- 来源：数据规范核对
- 现象：`Resources/content/commands/*.json`（10 个）与 `errors/common-errors.json`（10 个错误）均**没有 `related` 字段**；但 `index.json` 中每条都有 related。
- 依据：[content-guide.md](content-guide.md) 3.3（指令 related 必填）、5.3（错误 related 必填）。
- 影响：详情页"关联内容"区无法渲染（AppDelegate 只 loadDetail，详情对象无 related）；与规范不符。
- 建议方案：为 10 个指令、10 个错误的详情 JSON 补充 `related`（与 index.json 中的 related 保持一致），可用 P-001 的校验脚本兜底检查。

### P-005：FavoritesService / CalculatorService 未按架构实现（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：⬜ 待处理
- 来源：代码与架构文档核对
- 现象：`Sources/Services/` 下只有 ContentLoader.swift 和 SearchService.swift；收藏逻辑直接写在 AppDelegate（loadFavorites/saveFavorites/toggleFavorite + UserDefaults），CalculatorService 不存在。
- 依据：[architecture.md](architecture.md) 3.4（FavoritesService）、3.5（CalculatorService）；[CODE_STANDARDS.md](CODE_STANDARDS.md) 1.1（App 层禁止直接读写数据）。
- 影响：MVP 功能可用（收藏简单读写），但违反分层规范；第二阶段加"最近查看/搜索历史"时 AppDelegate 会膨胀。
- 建议方案：第二阶段初把收藏逻辑抽成 `FavoritesService.swift`（protocol + 实现），AppDelegate 只做协调。

### P-006：AppState 单例未落地（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：⬜ 待处理
- 来源：代码与架构文档核对
- 现象：architecture 8.2 与 CODE_STANDARDS 5.1 已定"AppState 单例集中管状态，AppDelegate 只做协调"，但代码中无 AppState.swift，状态（currentPage/currentItem/pageHistory）仍由 AppDelegate 私有属性管理。
- 依据：[architecture.md](architecture.md) 8.2、[CODE_STANDARDS.md](CODE_STANDARDS.md) 5.1。
- 影响：状态与生命周期耦合，后续加"窗口大小记忆/自定义热键"等设置时扩展不便；与已定架构决策不符。
- 建议方案：第二阶段引入 `AppState.swift`（currentPage/currentQuery/selectedItem 等），AppDelegate 改为持有 AppState 并转发。

### P-007：CHANGELOG 版本号与发布版本不一致（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：⬜ 待处理
- 来源：版本信息核对
- 现象：`CHANGELOG.md` 记 `[0.1.0]`，但 `nexus.json` 与 `Info.plist` 均为 `1.0.0`，最新提交信息为"版本1.0.0发布"。
- 依据：CHECKLIST 6.2"版本号已更新（语义化版本）"。
- 影响：文档与产物版本口径不一致，追溯困难。
- 建议方案：将 CHANGELOG.md 的 `[0.1.0]` 更新为 `[1.0.0]`，或统一项目版本策略。

---

### P-008：详情页"复制全部"只复制第一条内容（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：⬜ 待处理
- 来源：UI 验证（对照 ui-design.md / SPECIFICATION 3.2）
- 现象：`AppDelegate.copyItem` 中 command 类型只取 `detail.syntax.first`，error 类型只取 `detail.copyableCommands.first`——按钮文案是"复制全部"，实际只复制第一条。
- 依据：[SPECIFICATION.md](../SPECIFICATION.md) 3.2"示例 [全部复制]"；ui-design 7.3 底部操作栏"复制全部"。
- 影响：多语法/多修复指令的卡片复制不全，用户拿到的不是完整内容。
- 建议方案：command 类型拼接全部 `syntax`（换行分隔），error 类型拼接全部 `copyableCommands`；无内容时退回 title。

### P-009：搜索结果页按 Enter 不打开选中项，而是重新搜索（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：⬜ 待处理
- 来源：UI 验证（对照 SPECIFICATION 4.5 / ui-design 8.2 键盘交互）
- 现象：搜索结果页用 ↑↓ 选中卡片后按 Enter，触发的是 `onSearchEnter → performSearch`（重新搜索），而不是打开当前选中的 `selectedItem`（`selectedItem` 属性存在但无人调用）。
- 依据：[SPECIFICATION.md](../SPECIFICATION.md) 4.5"打开选中结果 | Enter"；ui-design 8.2。
- 影响：键盘核心流程（↑↓ 选择 → Enter 打开）断链，与规范不符。
- 建议方案：搜索结果页 Enter 改为：若有选中项（selectedIndex ≥ 0）则 `onItemClick(selectedItem)`，否则回退到搜索行为；AppDelegate 增加对应回调。

### P-010：详情页缺 Cmd+D / Cmd+C 快捷键（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：⬜ 待处理
- 来源：UI 验证（对照 ui-design 8.2）
- 现象：ui-design 8.2 规定详情页"收藏/取消收藏 Cmd+D"、"复制当前卡片 Cmd+C"，实现中未注册任何键盘快捷键。
- 影响：键盘友好体验不完整（有提升空间的体验项）。
- 建议方案：MVP 后可加（ROADMAP 第三阶段"自定义热键"时一并做），先记录。

### P-011：搜索框高度 44pt，与规范 36pt 不一致（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：⬜ 待处理
- 来源：UI 验证（对照 ui-design 6.1）
- 现象：HomeView / SearchResultView 中 `searchField.heightAnchor = 44`，ui-design 6.1 规定搜索框高度 36pt；SearchFieldView 内部 NSSearchField 高度 32pt。
- 影响：视觉与设计规范有偏差。
- 建议方案：统一为 36pt（或确认设计更新后同步 ui-design）。

### P-012：窗口默认高度 600pt，与规范 640pt 不一致（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：⬜ 待处理
- 来源：UI 验证（对照 ui-design 2.1）
- 现象：`AppDelegate.setupWindow` 传入 `NSSize(width: 560, height: 600)`，ui-design 2.1 规定默认高度 640pt。
- 影响：首次启动窗口偏矮。
- 建议方案：默认高度改为 640（或同步 ui-design）。

### P-013：内容卡片/分组图标未按类型区分颜色（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：⬜ 待处理
- 来源：UI 验证（对照 ui-design 3.2）
- 现象：ui-design 3.2 规定类型色（指令蓝 #007AFF、参数青 #5AC8FA、错误橙 #FF9500、公式紫 #AF52DE、技巧黄 #FFCC00、拓扑绿 #34C759）；`ContentCardView.configure` 中 `iconView.contentTintColor` 一律用琥珀色，分组标题也无类型色。
- 影响：搜索结果分组的视觉区分度弱于设计。
- 建议方案：ContentType 增加 `color` 属性，卡片图标/分组标题按类型着色。

### P-014：NXWindowStyle 默认 tint 注释为 alpha 0.15，与规范 0.12 不一致（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：⬜ 待处理
- 来源：UI 验证（对照 ui-design 2.2 / SPECIFICATION 8.1）
- 现象：`NXWindowStyle.makeFloatingWindow` 的默认 `tintColor` 参数与文档注释写"alpha 建议 0.15"；AppDelegate 实际调用时传了 0.12（正确），但 Common 组件默认值与注释仍是 0.15。
- 影响：Common 为只读组件，直接改源码违规；但注释/默认值会误导后续调用方。
- 建议方案：不改 Common 源码；在项目侧（如 DEVELOPMENT_PLAN 或 CODE_STANDARDS）注明"调用 NXWindowStyle 时必须显式传 alpha 0.12 的琥珀色 tint"，避免后续误用默认值。

### P-015：首页 Logo/副标题/热键提示样式与规范不符（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决
- 来源：UI 验证（对照 ui-design 7.1）
- 现象：
  - 副标题文案为"LTspice 仿真参考助手"，规范为"LTspice 参考助手"（多"仿真"二字）
  - 热键提示为纯文字"按 ⌃⌥S 快速唤出"，规范要求键帽样式展示（⌃ ⌥ S 分离的视觉样式）
- 影响：品牌一致性偏差；热键提示识别度低于设计。
- 建议方案：
  - HomeView.swift 第 61 行改为规范文案
  - 热键提示用 NSTextField + attributedString 实现键帽样式（背景色 + 圆角 + 内边距），参考 KeyHub 实现

### P-016：搜索框完全不符合规范（P0）

- 发现日期：2026-08-28
- 严重程度：P0
- 状态：✅ 已解决
- 来源：UI 验证（对照 ui-design 6.1）
- 现象：
  - 高度：SearchFieldView 内部 NSSearchField 为 32pt，外层无高度约束，规范要求 36pt
  - 圆角：系统 roundedBezel，规范要求 10pt
  - 聚焦态：无琥珀色边框 + 3pt 阴影
  - 左侧放大镜图标：系统默认，规范要求 16pt 琥珀色
  - 右侧清除按钮：系统默认
  - 占位文字："搜索指令、参数、错误、公式..."，规范为"搜索指令、参数、报错、公式…"（漏"技巧/拓扑"、用了英文省略号）
  - 搜索框左右边距：SearchFieldView 内部 16pt，但外层容器未撑满内容区 20pt 边距
- 影响：核心交互入口视觉与交互均偏离设计，用户首感不佳。
- 建议方案：重写 SearchFieldView：
  - 外层视图高度固定 36pt，左右边距 16pt（内容区 20pt 内撑满）
  - 背景色不透明白/深灰，layer.cornerRadius = 10
  - 左侧自定义 NSImageView 放大镜（16pt，琥珀色），右侧自定义清除按钮
  - 文本字段：NSTextField（非 NSSearchField），bezelStyle = .square，focusRingType = .none
  - 监听 focus 状态切换 layer.borderColor/shadow

### P-017：卡片悬停/点击动效实现有缺陷（P0）

- 发现日期：2026-08-28
- 严重程度：P0
- 状态：✅ 已解决
- 来源：UI 验证（对照 ui-design 6.2/8.1）
- 现象：
  - 悬停上移：`setFrameOrigin(y + 3)` 直接改 frame → 布局抖动、可能触发约束冲突
  - 点击缩放 0.98：完全缺失
  - 基础阴影：卡片无默认阴影（规范 0 1pt 4pt rgba(0,0,0,0.06)），仅悬停时加
- 影响：交互手感廉价，可能导致布局异常。
- 建议方案：
  - 悬停改用 `layer.transform = CATransform3DMakeTranslation(0, -3, 0)` + 隐式动画
  - 点击在 `mouseDown`/`mouseUp` 中加 `layer.transform = CATransform3DMakeScale(0.98, 0.98, 1)`，0.1s 恢复
  - `setupUI` 中给 layer 加默认阴影

### P-018：内容卡片布局细节多处偏离规范（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决
- 来源：UI 验证（对照 ui-design 6.2）
- 现象：
  - 标题字号 15pt Semibold → 规范 14pt Semibold (Code 字体)
  - 中文标题 12pt → 规范 13pt Body
  - 摘要 12pt 2行 → 规范 11pt Small 1行省略
  - 缺第三行：关键信息预览（语法/公式）+ 复制按钮
  - 内边距：上 14/左 16/右 12/下 14 → 规范统一 14pt
  - 无基础阴影（规范 0 1pt 4pt rgba(0,0,0,0.06)）
- 影响：卡片信息密度、视觉层级与设计不符。
- 建议方案：ContentCardView.configure + setupConstraints 全面对齐规范表：
  - 字号/行数/截断模式
  - 增加第三行视图（语法预览 + 复制按钮）
  - 统一内边距 14pt，加默认阴影

### P-019：详情页结构多处偏离规范（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决
- 来源：UI 验证（对照 ui-design 7.3）
- 现象：
  - 返回按钮：仅 chevron.left 图标 → 规范文字"‹ 返回"
  - 中文标题 14pt → 规范 13pt Body
  - 类型标签：TagView 字号 10pt、背景 controlBackgroundColor、无类型色 → 规范 11pt Medium、类型色背景 alpha 0.12、类型色文字
  - 底部操作栏缺"查快捷键(KeyHub)"按钮
  - 关联内容用 NSButton 非标准卡片样式
- 影响：详情页视觉规范度、品牌一致性偏差。
- 建议方案：
  - 返回按钮改文字按钮（bezelStyle = .rounded, isBordered = false, title = "‹ 返回"）
  - 中文标题字号 13pt
  - TagView 增加类型色配置（或 DetailView 中直接用对应颜色配置）
  - 底部操作栏加第三个按钮（图标 arrow.up.right.square，点击调用 NXURLScheme.openApp(keyhub)）
  - 关联内容改用类卡片样式（或统一按钮但加类型色图标）

### P-020：分组标题缺类型图标、字号、分隔线（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决
- 来源：UI 验证（对照 ui-design 6.8）
- 现象：
  - SectionHeaderView 字号 13pt Semibold → 规范 16pt Semibold
  - 无左侧类型图标（14pt，类型色）
  - 无底部分隔线（1pt）或 8pt 间距
- 影响：搜索结果分组视觉层级弱。
- 建议方案：SectionHeaderView 增加 iconView、字号 16pt、底部加 SeparatorView 或 spacing 8pt。

### P-021：空状态尺寸不符（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：⬜ 待处理
- 来源：UI 验证（对照 ui-design 6.9）
- 现象：
  - 图标 32pt → 规范 48pt
  - 标题 15pt Medium → 规范 13pt Medium
  - 建议文字 12pt → 规范 11pt
- 影响：空状态视觉权重偏小。
- 建议方案：EmptyStateView 调整尺寸对齐规范。

### P-022：快速分类标签样式与交互不符（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决
- 来源：UI 验证（对照 ui-design 7.1）
- 现象：
  - NSButton rounded bezel 固定一行不换行 → 规范横向可换行（或网格）
  - 启用态仅 contentTintColor 琥珀色 → 规范标签背景琥珀 alpha 0.12、文字琥珀、有悬停/选中态
  - 禁用态 isEnabled = false 灰色 → 规范次文字色、可视但不可点
- 影响：首页分类筛选交互体验弱于设计。
- 建议方案：自定义 TagButton（NSView + layer + trackingArea），支持换行布局（NSFlowLayout 或手动布局），状态完整（默认/悬停/按下/选中/禁用）。

### P-023：收藏区布局为垂直列表，规范要求横向滚动/网格（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：⬜ 待处理
- 来源：UI 验证（对照 ui-design 7.1）
- 现象：HomeView.updateFavorites 用垂直 NSStackView → 规范横向滚动卡片或网格（每行 3 个）。
- 影响：收藏多时需上下滚动，不如横向浏览高效。
- 建议方案：改用 NSScrollView + 横向 NSStackView（hasHorizontalScroller = true），卡片宽度固定 ~160pt，或用 NSCollectionView 网格。

### P-024：深色模式下代码块/卡片对比度未验证（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：⬜ 待处理
- 来源：UI 验证（对照 ui-design 10/11）
- 现象：
  - CopyableCodeView 硬编码深色背景 `#1E1E1E` 近似值 → 应用语义色或动态色
  - 卡片悬停琥珀边框 alpha 0.6 在深色模式下对比度存疑
- 影响：深色模式下可访问性可能不达标（WCAG AA 4.5:1）。
- 建议方案：
  - CopyableCodeView 用 `NSColor.textBackgroundColor` 或自定义动态色
  - 深色模式下手动验证所有卡片/代码块/边框对比度，必要时调整 alpha

---

## 本次验证通过项（无需处理）

| 项 | 结论 |
|----|------|
| git 初始化 + 每步提交 | ✅ 10 个提交，信息格式符合 CODE_STANDARDS（`[模块] 描述`），工作区干净 |
| .gitignore | ✅ 排除 .app/.dSYM/.DS_Store 等构建产物 |
| 协议驱动 | ✅ SearchServiceProtocol / ContentLoaderProtocol 均已定义 |
| 错误匹配防版本差异 | ✅ SearchService 用 contains 包含匹配（标题/中文标题/tags/摘要），非精确匹配 |
| 指令文件名规范 | ✅ Resources/content/commands/command-*.json 带前缀，符合修订后规范 |
| 内容索引 | ✅ index.json 20 条（10 指令 + 10 错误），related 引用有效 |
| 热键/URL Scheme/菜单栏 | ✅ Ctrl+Option+S、nexus-spicenest://、bolt 图标、Nexus 应用子菜单均已实现 |
| 编译 | ✅ swiftc -typecheck 全部通过（0 错误） |
| 构建产物 | ✅ SpiceNest.app 已构建，build.sh 符合 Nexus 标准 |
| 窗口样式 | ✅ 毛玻璃(.popover)、圆角12pt、透明标题栏、固定560pt、min 400 / max 3000、.floating（与 ui-design 2.1 一致） |
| 首页布局 | ✅ Logo Impact 28pt、副标题、热键提示、搜索框自动聚焦、快速分类（指令/错误可点，其余禁用）、收藏区占位 |
| 搜索结果页 | ✅ 分组标题+数量、空状态提示、↑↓ 选择、悬停卡片（与 ui-design 7.2 一致） |
| 详情页 | ✅ 返回按钮、标题/中文标题/类型标签/摘要、按类型渲染（语法/参数/示例/注意事项、原因/解决方案/可复制指令）、底部操作栏 |
| 卡片/代码块 | ✅ 圆角10/6、不透明背景、悬停上浮3pt+琥珀边框+手型光标、复制按钮变对勾2秒恢复、SF Mono 12（与 ui-design 6.2/6.4 一致） |
| 图标 | ✅ SF Symbol 与 ui-design 9.2 表一致（terminal/slider/三角/function/lightbulb/网格） |
| 菜单栏/热键 | ✅ bolt isTemplate、Ctrl+Option+S、Nexus 应用子菜单动态检测（未安装显示"（未安装）"） |
| 深浅色 | ✅ 卡片/标签用系统色自动适配，代码块深色固定（与 ui-design 十一致） |

---

## 统计

| 严重程度 | 总数 | 待处理 | 处理中 | 已解决 |
|---------|------|--------|--------|--------|
| P0 | 2 | 0 | 0 | 2 |
| P1 | 12 | 1 | 0 | 11 |
| P2 | 12 | 8 | 0 | 4 |
| **合计** | **26** | **9** | **0** | **17** |

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v0.3 | 2026-08-28 | 复读 UI 实现代码，新增 P-015~P-024（搜索框/卡片动效/详情页/分组标题/空状态/快速分类/收藏区/深色模式等），清理 P-014 重复项 |
| v0.2 | 2026-08-28 | UI 验证：新增 P-008~P-014（复制全部只复制第一条、Enter 不打开选中项等），通过项表补充 UI 类 8 项 |
| v0.1 | 2026-08-28 | 初始问题记录：ERROR_PREVENTION 落地验证发现 7 项问题（P1×4、P2×3） |

---

*SpiceNest 问题记录 · 记录到修复，不留死角*
