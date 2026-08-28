# SpiceNest 问题记录

> 版本：0.8 | 日期：2026-08-29
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

## 二、UI 视觉问题专项（2026-08-28 复盘新增）

> 真实运行 `nexus-spicenest://snapshot` 截图复核 v1.0.0 视觉，记录与"现代 macOS 原生感"的偏差。

### P-025：窗口背景呈浑浊棕黄色，整体观感脏（P0）

- 发现日期：2026-08-28
- 严重程度：**P0**（影响首感、用户对整个产品美感的判断）
- 状态：✅ 已解决（2026-08-28 · UI v2.0：去纯色 tint，改顶部 0.06 琥珀渐变）
- 来源：实际运行截图复核
- 现象：
  - 首页 / 搜索结果页 / 详情页整片背景呈"浑浊的米黄/卡其色"，看起来像旧报纸或牛皮纸
  - 用户感受：太丑、不专业、不像 macOS 原生应用
- 根因（推测）：
  - `NXWindowStyle.makeFloatingWindow` 使用 `.popover` material + 琥珀色 `alpha 0.12` 叠加层
  - `.popover` 本身在浅色系统下底色偏暖（米白偏米黄），再叠加琥珀（红+绿、无蓝）= 黄褐色调
  - 即便 alpha 0.12 已经很弱，**红色 + 绿色 都不为零、蓝色 0.0** 的颜色叠加到任何浅底上都会"拉黄"
  - 加之 macOS Sonoma+ 强调色被压暗时，popover 进一步发灰
- 依据：[ui-design.md](ui-design.md) 2.2 / [SPECIFICATION.md](../SPECIFICATION.md) 8.1
- 影响：**第一印象塌方**——即使后续交互、卡片、内容都做得不错，背景脏就足以让用户卸载
- 建议方案（任选其一，按推荐度排序）：
  1. **首选**：去掉纯色 tint 叠加层，改用极轻的双色径向 / 线性渐变（顶部 0.06 琥珀 → 底部 0.0 透明），避免与底色叠加产生浊色
  2. **次选**：material 改用 `.hudWindow` 或 `.underWindowBackground`，底色更中性，再叠 0.08 琥珀更克制
  3. **保底**：把琥珀 tint 改成更"中性的暖灰"（如 RGB 0.55/0.55/0.55 alpha 0.06），仅做底纹感不抢戏
  4. 给用户一个设置开关："纯色背景" vs "毛玻璃背景"

---

### P-026：首页 Logo "SpiceNest" 视觉发糊、字重不足（P0）

- 发现日期：2026-08-28
- 严重程度：**P0**
- 状态：✅ 已解决（2026-08-28 · UI v2.0：SF Pro Rounded Heavy 36pt + 琥珀渐变 + 去阴影）
- 来源：实际运行截图复核
- 现象：
  - "SpiceNest" 用 Impact 28pt + 琥珀色 + 黑色阴影，渲染出来发糊，像隔了层纱
  - 整体偏小，与下方"LTspice 参考助手"副标题权重对比偏弱
- 根因：
  - Impact 是衬线/压缩字体，在 28pt 字号下若未做像素对齐 + 未开启字体平滑优化易模糊
  - 阴影（offset 0,-1 blur 2）让字母边缘与底色交融
  - 字母宽高比偏扁，28pt 视觉面积不够"logo 感"
- 建议方案：
  - 字号提到 34~36pt，加 `NSPixelUtils.align` 处理
  - 改用 `SF Pro Rounded Bold` 或 `SF Pro Display Heavy`，更现代、清晰
  - 阴影去掉或改成"内描边 + 极轻外发光"
  - 颜色用琥珀 `#FF9500` 渐变到 `#FF6A00` 提升质感

---

### P-027：热键提示"⌃ ⌥ S 快速唤出"排版拥挤（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决（2026-08-28 · UI v2.0：键帽琥珀底+琥珀描边，文字 12pt Medium + 6pt 间距）
- 来源：实际运行截图复核
- 现象：
  - 三个键帽 + "快速唤出"文字横排，"快速唤出"4 个汉字紧贴最后一个键帽，视觉上像被挤压
  - 键帽样式朴素，只有 1pt 灰边，无任何品牌感
- 建议方案：
  - 键帽背景换为琥珀色 alpha 0.12，文字琥珀色，呼应主题
  - 在键帽和文字间加 4pt 间距，文字加 secondaryLabelColor
  - 整体下移避免和上方副标题粘连

---

### P-028：搜索框占位文字被截断成"…公式…"（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决（2026-08-28 · UI v2.0：左右内边距收窄 + 字号 13pt，占位完整显示）
- 来源：实际运行截图复核
- 现象：
  - 规范 placeholder："搜索指令、参数、报错、公式…"
  - 实际渲染：右侧 1/3 区域被截断，只看到"…公式…"
  - 视觉上像输入框被卡住、不可用
- 根因：
  - SearchFieldView 内层 textField 与左右图标间的横向间距较大，可写宽度不足
  - 截断时优先保留前缀，所以看起来像"不完整"
- 建议方案：
  - 缩小左右内边距（icon 8pt / clear 8pt → icon 6pt / clear 6pt）
  - 或将 placeholder 精简为"搜索…"（更现代）
  - 或允许 placeholder 改用两行（用 NSTextField 的 lineBreakMode）

---

### P-029：首页快速分类像"纯文字"而非"标签"（P0）

- 发现日期：2026-08-28
- 严重程度：**P0**
- 状态：✅ 已解决（2026-08-28 · UI v2.0：CategoryTagView 重做，类型图标+类型色描边胶囊，3 行 2 列）
- 来源：实际运行截图复核
- 现象：
  - 6 个分类（仿真指令/常见错误/元器件参数/公式速算/操作技巧/电路拓扑）渲染得像 6 个普通文字
  - 没有胶囊/圆角底色、没有图标、没有视觉分组，看起来像"目录段落标题"
- 根因：
  - CategoryTagView 默认态 `layer?.backgroundColor = NSColor.clear.cgColor` + `label.textColor = .secondaryLabelColor`
  - 视觉上完全没有"按钮/标签"感
  - 启用态和禁用态没有视觉区分
- 建议方案（彻底重做）：
  - **必须**：默认态给一个 1pt 琥珀描边的胶囊背景（背景透明，描边琥珀 alpha 0.3）
  - **必须**：左侧加一个该类型的小图标（14pt，类型色）
  - 可选：悬停态用琥珀填充（alpha 0.12）+ 文字变琥珀
  - 禁用态：去掉描边、文字变 placeholder 色
  - 整个分类区块背景用一个极浅的卡片底（与下方的收藏区分开）

---

### P-030：收藏区布局诡异，单卡片被推到最底部（P0）

- 发现日期：2026-08-28
- 严重程度：**P0**
- 状态：✅ 已解决（2026-08-28 · UI v2.0：收藏区改横向滚动 160pt 卡片 + 空状态友好卡片）
- 来源：实际运行截图复核
- 现象：
  - 顶部"收藏"标签右下方有 400pt+ 的空白
  - 唯一一张收藏卡片 ".op 直流工作点" 被固定到窗口最底部 1/4 处
  - 中间巨大空白区域没有任何填充
- 根因：
  - HomeView 中 `favoritesScrollView` 用了 `bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)`
  - 收藏列表只有 1 项时，stackView 从上到下排，但因为是 NSScrollView，scrollView 自己撑满到 bottom
  - 视觉上 stackView 顶部紧贴 favoritesLabel，但 scrollView 内容只有 90pt 高，剩下全是空白
  - 卡片 90pt 高在 600pt 高的窗口中显得"漂浮"
- 建议方案：
  - 改用 NSScrollView + 横向 NSStackView（hasHorizontalScroller = true），卡片宽度固定 ~160pt
  - 或改用 NSCollectionView 网格（每行 2-3 个卡片）
  - 或在"暂无收藏"时显示一个更友好的空状态卡片（带插画/提示"去详情页点点 ⭐ 收藏常用指令吧~"）
  - 横向布局 + 网格布局都比"垂直列表"更适合"⭐ 收藏 (3)"这种少量快速访问的场景

---

### P-031：详情页代码块高度不一致，紧凑度差（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：✅ 已解决（2026-08-28 · UI v2.0：contentStackView.spacing 12→8，整体更紧凑）
- 来源：实际运行截图复核
- 现象：
  - 4 个语法代码块都按单行算高度，但有的实际内容更长
  - 代码块之间间距过大（contentStackView.spacing = 12pt）导致详情页整体偏松散
- 建议方案：
  - 代码块之间 spacing 改为 6pt
  - 代码块加 1pt 极淡分隔线（用 SeparatorView）
  - 顶部加一个"代码区"小标题，与下方"参数说明"统一

---

### P-032：分组标题与上方距离过远，视觉断层（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：✅ 已解决（2026-08-28 · UI v2.0：searchField 与 scrollView 间距 8→0 + 翻转堆栈顶部对齐）
- 来源：实际运行截图复核
- 现象：
  - 搜索框（高度 36pt）和第一个分组标题"仿真指令"之间有 ~80pt 空白
  - 看起来像"先输入了又来了一段不相干的内容"
- 建议方案：
  - searchField 与 scrollView 间距从 8pt 提到 0pt
  - 第一个分组标题上方加 padding 4pt
  - 或干脆在搜索框底部加 1pt 分隔线，视觉"画清边界"

---

### P-033：分类筛选只支持 2 类，其余 4 类永久禁用（设计/内容失衡）（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决（2026-08-28 · UI v2.0：4 个禁用分类加 🔒 徽章 + tooltip"第二阶段上线"）
- 来源：代码 + 内容现状核对
- 现象：
  - HomeView 把 6 个分类排成 2 行 3 列，但只有"仿真指令 / 常见错误" enabled，其余 4 个永远灰着
  - 但 ui-design 7.1 把这 6 个分类都画成了可点击的彩色胶囊
  - 原因：MVP 阶段其他 4 类（参数/公式/技巧/拓扑）还没有内容数据
- 建议方案（按推荐度）：
  1. **短期**：将"元器件参数 / 公式速算 / 操作技巧 / 电路拓扑"标为"敬请期待"，加一个小锁图标或紫色"Coming Soon"徽章
  2. **中期**：第二阶段补内容后立即启用
  3. **不建议**：直接隐藏，避免首屏"只有 2 个能用"的尴尬

---

### P-034：详情页右上角无"返回顶部"快捷入口（P3）

- 发现日期：2026-08-28
- 严重程度：P3
- 状态：✅ 已解决（2026-08-28 · UI v2.0：滚动超 200pt 右下角浮现 ↑ 按钮，0.3s 平滑回顶）
- 来源：实际运行截图复核
- 现象：
  - 详情页内容长时（多语法 + 多参数 + 多示例 + 注意事项 + 相关内容），需要滚到最底部
  - 想回顶部只能手动滚轮或 Home 键，没有快捷按钮
- 建议方案：
  - 详情页滚动超过 200pt 时，右下角浮现"↑"小按钮，点击回顶
  - 或允许 Cmd+↑ 快捷键直接滚到顶

---

### P-035：详情页类型 TagView 颜色偏淡（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：✅ 已解决（2026-08-28 · UI v2.0：TagView 加 4pt 类型色块 + 背景 alpha 0.20 + semibold）
- 来源：实际运行截图复核
- 现象：
  - 详情页的"仿真指令"标签：蓝色文字 + 蓝色 alpha 0.12 背景
  - 整体看是淡淡的蓝点，几乎"看不见"
  - 没有起到"分类标识"的视觉锚点作用
- 建议方案：
  - 背景 alpha 提到 0.18~0.20
  - 文字加粗到 .medium weight
  - 左侧加一个 4pt 宽的颜色块（类型色），更"识别"

---

## 三、交互 Bug 专项（2026-08-28 用户实测反馈，v0.6 全部修复）

> 用户真实操作后反馈的交互 bug，均为"截图验证发现不了、只有上手用才会暴露"的问题。
> 教训：UI 重构后必须做真实交互测试，不能只看静态截图。

### P-036：内容与标题栏红绿灯按钮重叠（P0）

- 发现日期：2026-08-28
- 严重程度：P0
- 状态：✅ 已解决（2026-08-28 · 三个页面视图顶部加 28pt 安全区）
- 来源：用户实测截图
- 现象：搜索框/返回按钮与窗口左上角"退出/最小化/放大"红绿灯重叠
- 根因：`.fullSizeContentView` 让内容延伸到透明标题栏之下，页面 topAnchor 直接贴 contentView 顶部
- 修复：[AppDelegate.swift](../Sources/App/AppDelegate.swift) 三个页面视图 `topAnchor constant: 28`

---

### P-037：输入第二个字母覆盖第一个字母（P0）

- 发现日期：2026-08-28
- 严重程度：P0
- 状态：✅ 已解决（2026-08-28 · 聚焦时光标移末尾 + 页面未切换不重复聚焦 + 不重复写搜索框文本）
- 来源：用户实测
- 现象：输入第一个字母后文本被全选，输入第二个字母时第一个被替换
- 根因（三重叠加）：
  1. 每次输入触发 `handleSearchTextChange → performSearch → showPage`，旧代码每次 showPage 都重新聚焦搜索框，NSTextField 聚焦默认全选文本
  2. `updateResults` 每次都 `searchField.text = query` 重写文本，重置选中态
  3. 中文输入法下全选+覆盖会直接吞掉拼音
- 修复：
  - [SearchFieldView.swift](../Sources/Views/SearchFieldView.swift) `focus()` 聚焦后把光标移到末尾（含下一轮 runloop 兜底）
  - [AppDelegate.swift](../Sources/App/AppDelegate.swift) `showPage(_:forceFocus:)` 仅在页面真正切换时聚焦
  - [SearchResultView.swift](../Sources/Views/SearchResultView.swift) `updateResults` 仅在文本不一致时写入

---

### P-038：悬停 a 卡片却点亮 b 卡片（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决（2026-08-28 · 悬停检测改用 stackView 坐标系）
- 来源：用户实测
- 现象：鼠标放在卡片 a 上，高亮的却是卡片 b
- 根因：`checkHoverState` 把鼠标坐标转换到 SearchResultView 坐标系，却与卡片在 **stackView（documentView）坐标系** 的 frame 比较，坐标系错位（差一个滚动偏移 + 顶部搜索框高度）
- 修复：[SearchResultView.swift](../Sources/Views/SearchResultView.swift) `stackView.convert(mouseLocation, from: nil)`

---

### P-039：详情页返回按钮显示不全且返回逻辑错误（P0）

- 发现日期：2026-08-28
- 严重程度：P0
- 状态：✅ 已解决（2026-08-28 · 去掉 32pt 宽度限制 + 返回历史栈）
- 来源：用户实测（图2）
- 现象：
  1. 左上角"‹ 返回"只显示半个"返"字（宽度被 32pt 限制截断）
  2. 从首页收藏进详情，点返回却回到搜索页而不是首页；用户期望"返回=回到进入前的页面"
- 根因：
  1. backButton 固定 `widthAnchor = 32` 装不下"‹ 返回"
  2. `goBack()` 硬编码 detail→searchResults，不记录来源页
- 修复：
  - [DetailView.swift](../Sources/Views/DetailView.swift) 去掉宽度约束，按钮自适应
  - [AppDelegate.swift](../Sources/App/AppDelegate.swift) 新增 `pageHistory` 历史栈：进入搜索页/详情页前 `pushHistory()`，`goBack()` 弹栈回到真实来源页

---

### P-040：搜索结果页无返回按钮（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决（2026-08-28 · 搜索框左侧加"‹ 返回"按钮）
- 来源：用户实测
- 现象：搜索结果页只能靠 Esc 键返回，没有可见的返回按钮
- 修复：[SearchResultView.swift](../Sources/Views/SearchResultView.swift) 搜索框同行左侧加"‹ 返回"，点击触发 `onBack → goBack`

---

### P-041："复制全部"按钮作用不明确、无反馈（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：✅ 已解决（2026-08-28 · 点击后短暂显示"已复制 ✓"绿色反馈）
- 来源：用户实测
- 现象：用户不理解"复制全部"是干什么的，点了也没有任何反馈，以为没生效
- 说明：该按钮作用是把该条目的全部语法/可复制指令复制到剪贴板（方便粘贴到 LTspice），是有用的，但缺乏反馈
- 修复：[DetailView.swift](../Sources/Views/DetailView.swift) `showCopyFeedback()` 点击后 1.2s 内显示"已复制 ✓"

---

## 四、UI 深度审计专项（2026-08-28 深度审计，v0.7 P0+P1 包）

> 对三页真实截图 + 全量代码逐元素审计：布局合理性、用户使用习惯、每个 UI 元素是否真实被用到、死元素、缺失功能。
> 经确认本轮落地 P0+P1 两包；明确不做：点击空白收起窗口、锁定分类降权，及其余 P2 审计项。

### P-042：收藏卡片复制按钮是死元素（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决（2026-08-28 · HomeView 增加 onFavoriteItemCopy，AppDelegate 接 copyItem）
- 来源：深度审计（元素可用性核查）
- 现象：收藏卡片悬停出现复制按钮，但 HomeView 只有 onClick 回调，onCopy 从未接线，点击无任何效果
- 影响：可见按钮点了没反应，用户怀疑应用坏了
- 修复：[HomeView.swift](../Sources/Views/HomeView.swift) `onFavoriteItemCopy` + [AppDelegate.swift](../Sources/App/AppDelegate.swift) 接线 `copyItem`

---

### P-043："查快捷键"按钮硬编码 KeyHub 路径（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决（2026-08-28 · 改用 NXURLScheme，未安装时隐藏按钮）
- 来源：深度审计（元素可用性核查）
- 现象：详情页按钮直接 `NSWorkspace.open("/Applications/KeyHub.app")`，KeyHub 不在该路径时点击报错；且未安装时也显示按钮
- 决策：产品确认"未装 KeyHub 就隐藏"
- 修复：[AppDelegate.swift](../Sources/App/AppDelegate.swift) `NXURLScheme.isAppInstalled(appId: "keyhub")` 判定 + `NXURLScheme.openApp(appId:)` 唤起；未安装时 `detailView.onKeyHub = nil`（DetailView 自动隐藏按钮）

---

### P-044：Esc 只在搜索结果页生效（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决（2026-08-28 · 首页 Esc 隐藏窗口，详情页 Esc 返回）
- 来源：深度审计（用户使用习惯：浮窗类工具 Esc 应可收起）
- 现象：首页按 Esc 无反应；详情页不是第一响应者，Esc 也无效
- 修复：
  - [HomeView.swift](../Sources/Views/HomeView.swift) `onEscape` → [AppDelegate.swift](../Sources/App/AppDelegate.swift) `window.orderOut(nil)`
  - [DetailView.swift](../Sources/Views/DetailView.swift) `acceptsFirstResponder` + `cancelOperation` 触发返回；`showPage(.detail)` 时 `makeFirstResponder(detailView)`

---

### P-045："tran" 误命中 ".dc" 的 transfer 标签（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决（2026-08-28 · ASCII 词边界匹配 + 反向断言回归用例）
- 来源：深度审计（搜索质量）
- 现象：搜索 "tran" 会把 ".dc"（tags 含 "transfer"）一并搜出，纯子串匹配的误报
- 修复：[SearchService.swift](../Sources/Services/SearchService.swift) 纯 ASCII 查询改词边界匹配（命中处前后不得紧邻 ASCII 字母/数字；中文/混合查询保持子串匹配）；"tran" 不再命中 "transfer"，".op" 不再命中 ".options"，完整单词与中文搜索不受影响
- 验证：`scripts/search_cases.txt` 新增 `!id` 反向断言语法与 4 条词边界用例

---

### P-046：死代码 renderGenericDetail / categoryTypes（P2）

- 发现日期：2026-08-28
- 严重程度：P2
- 状态：✅ 已解决（2026-08-28 · 直接删除）
- 来源：深度审计（未被使用的元素/代码）
- 现象：`DetailView.renderGenericDetail` 无任何调用方；`HomeView.categoryTypes` 只写不读
- 修复：两处删除

---

### P-047：深色模式下卡片/搜索框硬编码白色（P0）

- 发现日期：2026-08-28
- 严重程度：**P0**
- 状态：✅ 已解决（2026-08-28 · NXDynamicColor 动态色 + 外观切换刷新）
- 来源：深度审计（深色模式实测）
- 现象：ContentCardView / SearchFieldView 渐变背景写死 `NSColor(white: 1.0)` 系浅色，深色模式下呈刺眼白色块（P-024 的卡片部分）
- 修复：
  - [CommonViews.swift](../Sources/Views/CommonViews.swift) 新增 `NXDynamicColor(light:dark:)` 动态色工具
  - 卡片渐变浅白→深灰（#2C2C2E→#242426），高光线深色下降为 alpha 0.06；搜索框渐变同步动态化
  - `viewDidChangeEffectiveAppearance` 运行时切换外观即时刷新
- 验证：深色模式全页截图（首页/搜索/详情）目视通过

---

### P-048：粘贴报错无法反查，errorPattern 数据闲置（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决（2026-08-28 · errorPattern 进索引 + 双向通配匹配，权重 80）
- 来源：深度审计（缺失但用户需要的功能）
- 现象：common-errors.json 每条都有 `errorPattern`（如 "Node ... is floating"），但 index.json 无此字段、搜索从不使用；用户粘贴真实报错 "Node N005 is floating" 搜不到对应条目
- 修复：
  - [ContentItem.swift](../Sources/Models/ContentItem.swift) 增加 `errorPattern: String?`；index.json 10 条错误补齐
  - [SearchService.swift](../Sources/Services/SearchService.swift) 双向匹配："..." 通配展开正向命中粘贴文本；压平后反向命中简写输入
  - `validate_content.sh` 增加 error 类型必有 errorPattern + index/详情一致性校验

---

### P-049：首页收藏区下方约 138pt 空白，缺"最近查看"（P1）

- 发现日期：2026-08-28
- 严重程度：P1
- 状态：✅ 已解决（2026-08-28 · 最近查看胶囊行）
- 来源：深度审计（布局合理性 + 架构文档承诺未兑现）
- 现象：首页底部大片空白；架构文档承诺的"最近查看/搜索历史"从未实现
- 修复：
  - [AppDelegate.swift](../Sources/App/AppDelegate.swift) `SpiceNestRecents` UserDefaults 持久化，去重置顶，上限 8 条，`showDetail` 时记录
  - [HomeView.swift](../Sources/Views/HomeView.swift) 收藏区下方"最近查看"紧凑胶囊行（类型色圆点 + 标题，悬停加深，点击直达详情），无记录时整区隐藏

---

### 本轮明确不做（用户确认）

- 点击窗口外收起（涉及全局事件监听，体验收益有限）
- 锁定分类（参数/公式/技巧/拓扑）降权或后移（保持信息架构完整）
- 其余 P2 审计项（80ms 悬停定时器、空状态尺寸等）留待后续

---

## 五、UI 体验十项修复专项（2026-08-29 用户反馈，v1.1.1 全部修复）

> 用户基于 3 张标注截图反馈 10 项体验问题，v1.1.1 全部修复。
> 窗口宽度 560 → 520、高度锁定 640；详情页代码块与文字等宽；全部可点击元素统一小手光标。

### P-050：拉伸窗口导致页面移动、页面偏宽（P1）

- 发现日期：2026-08-29
- 严重程度：P1
- 状态：✅ 已解决（2026-08-29 · min=max=520×640 锁死，宽度 560→520）
- 来源：用户实测反馈
- 现象：拉伸窗口长度时页面内容跟着移动；且 560pt 宽度偏宽
- 根因：窗口 `.resizable` 允许任意拉伸，内容布局随窗口尺寸重排产生位移
- 修复：[AppDelegate.swift](../Sources/App/AppDelegate.swift) `minSize = maxSize = 520×640`（保留 `.resizable` 避免触发系统按内容自适应），窗口默认尺寸同步 520×640

---

### P-051：所有卡片底部有一根白线（P1）

- 发现日期：2026-08-29
- 严重程度：P1
- 状态：✅ 已解决（2026-08-29 · 高光线改为几何感知定位，置顶部）
- 来源：用户标注截图
- 现象：内容卡片、收藏卡片底部都有一条刺眼白线
- 根因：highlightLayer（1pt 高光线）固定 `y: 0`，macOS 非翻转 CALayer 坐标系原点在**左下**，y=0 即底边——本想放顶部的高光线画到了底部
- 修复：[ContentCardView.swift](../Sources/Views/ContentCardView.swift) / [CopyableCodeView.swift](../Sources/Views/CopyableCodeView.swift) `layout()` 按 `layer.isGeometryFlipped` 计算 highlightY；同步修正渐变层颜色顺序（startPoint (0,0) 为底部，colors[0] 应为底部色）
- 验证：搜索页像素级扫描，白线行数为 0

---

### P-052：可点击元素未显示小手光标（P2）

- 发现日期：2026-08-29
- 严重程度：P2
- 状态：✅ 已解决（2026-08-29 · HandCursorButton 统一覆盖）
- 来源：用户反馈
- 现象：详情页/搜索页多个按钮悬停仍是箭头光标，不像可点击
- 根因：NSButton 默认箭头光标，未重写 `resetCursorRects`
- 修复：[CommonViews.swift](../Sources/Views/CommonViews.swift) 新增 `HandCursorButton`（addCursorRect + .pointingHand）；详情页（返回/收藏/查快捷键/回顶/关联项）、搜索页返回、搜索框清除按钮全部替换；分类标签/最近查看/卡片此前已有小手，全量覆盖

---

### P-053：滚动后被悬停点亮的卡片一直亮着（P1）

- 发现日期：2026-08-29
- 严重程度：P1
- 状态：✅ 已解决（2026-08-29 · 滚动边界变化即时重算悬停 + 幂等保护）
- 来源：用户实测反馈
- 现象：鼠标悬停卡片后滚轮滚动，多个已离开鼠标的卡片保持点亮状态
- 根因：悬停检测只在 mouseMoved 触发，滚动时鼠标不动、视图移动，检测不重算；且 applyHoverState 无去重，状态反复叠加
- 修复：
  - [SearchResultView.swift](../Sources/Views/SearchResultView.swift) `scrollView.contentView.postsBoundsChangedNotifications = true` + 监听 `NSView.boundsDidChangeNotification` 立即 `checkHoverState()`
  - [ContentCardView.swift](../Sources/Views/ContentCardView.swift) `applyHoverState` 增加 `isHovering` 幂等守卫

---

### P-054：详情页两处无用复制按钮（P2）

- 发现日期：2026-08-29
- 严重程度：P2
- 状态：✅ 已解决（2026-08-29 · 右下角"复制全部"与代码块复制按钮均删除）
- 来源：用户反馈
- 现象：右下角"复制全部"按钮没人用；代码块后的复制按钮也多余（代码文字本身可选中复制）
- 修复：
  - [DetailView.swift](../Sources/Views/DetailView.swift) 删除 `copyAllButton` 属性/约束/回调及 AppDelegate 接线
  - [CopyableCodeView.swift](../Sources/Views/CopyableCodeView.swift) 重写：删除 `copyButton` 与 `onCopy`，代码文字保持可选中

---

### P-055："查快捷键"按钮朴素、位置不佳（P2）

- 发现日期：2026-08-29
- 严重程度：P2
- 状态：✅ 已解决（2026-08-29 · 琥珀胶囊样式 + 移至头部行右侧）
- 来源：用户反馈
- 现象：KeyHub 按钮样式普通，位置不显眼
- 修复：[DetailView.swift](../Sources/Views/DetailView.swift) 重做为琥珀色胶囊（背景 0.12 + 描边 0.4 + 圆角 14 + command 符号图标），从内容区移至头部行与返回按钮同行靠右（28pt 高）
- 验证：截图确认琥珀胶囊渲染于详情页右上角

---

### P-056：详情页代码块比段落文字宽太多（P1）

- 发现日期：2026-08-29
- 严重程度：P1
- 状态：✅ 已解决（2026-08-29 · 文字与代码块共用同一内容列宽）
- 来源：用户标注截图
- 现象：黑色代码块明显比正文段落宽，视觉不对齐
- 根因：正文 label 无宽度约束时按单行理想宽度撑开，与代码块宽度口径不一致
- 修复：[DetailView.swift](../Sources/Views/DetailView.swift) `addTextBlock` 恢复 `preferredMaxLayoutWidth = 488` 并约束 `widthAnchor == contentStackView.widthAnchor`，文字与代码块同宽
- 验证：像素测量代码块与文字均为 x=32..977（520pt 窗口内容列）

---

### P-057：搜索结果页一片白茫茫、卡片间距太近（P1）

- 发现日期：2026-08-29
- 严重程度：P1
- 状态：✅ 已解决（2026-08-29 · 组间距 16pt + 卡片间距 8pt + 底部留白）
- 来源：用户标注截图
- 现象：打开"仿真指令"分类后大面积留白观感差；卡片之间贴得太近
- 决策：不缩窄卡片宽度（内容会持续增长，宽度需保留）
- 修复：[SearchResultView.swift](../Sources/Views/SearchResultView.swift) `renderResults` 重排：分组之间 16pt 间隔、每张卡片后 8pt、列表底部 8pt 留白；配合 P-050 窗口高度锁定 640 消除拉伸产生的大片空白

---

### P-058：首页收藏区卡片悬停上浮被裁剪（P1）

- 发现日期：2026-08-29
- 严重程度：P1
- 状态：✅ 已解决（2026-08-29 · scrollView contentInsets 预留悬停空间）
- 来源：用户标注截图
- 现象：收藏卡片悬停上浮/发光超出滚动视图边界被裁掉，显示不全
- 修复：[HomeView.swift](../Sources/Views/HomeView.swift) `favoritesScrollView.contentInsets = (top 12, left 2, bottom 8, right 8)`，内部 stack 高度固定 110（12+110+8 = 130 恰好填满），悬停动效在框内有完整活动空间

---

### P-059：窗口首次布局被内容撑宽至 701/934pt（P0）

- 发现日期：2026-08-29
- 严重程度：**P0**
- 状态：✅ 已解决（2026-08-29 · containerView 定宽锚点 520 + 最近查看行等宽约束）
- 来源：v1.1.1 修复过程截图验证
- 现象：即便 `minSize = maxSize = 520×640`，窗口首次显示仍被撑到 701pt（详情页错误条目时甚至 934pt）
- 根因：NSWindow 首次显示时会按内容 `fittingSize` 自适应调整尺寸，**绕过** min/max 限制；8 个最近查看胶囊的理想宽度（660.5pt）与详情页长文本单行理想宽度分别撑宽窗口
- 修复：
  - [AppDelegate.swift](../Sources/App/AppDelegate.swift) `containerView.widthAnchor == 520`（required 优先级），把自适应目标锁定为 520
  - [HomeView.swift](../Sources/Views/HomeView.swift) 最近查看行尾锚点改等值约束 + `masksToBounds`
- 验证：全部 7 个导出步骤窗口稳定 520×640（@2x 1040×1280），0 条约束冲突日志

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
| P0 | 12 | 0 | 0 | 12 |
| P1 | 28 | 1 | 0 | 27 |
| P2 | 21 | 8 | 0 | 13 |
| P3 | 1 | 0 | 0 | 1 |
| **合计** | **62** | **9** | **0** | **53** |

> v0.8（2026-08-29）：UI 体验十项修复专项（P-050~P-059）全部 ✅：卡片白线/收藏悬停裁剪/搜索页留白与间距/代码块宽度与复制按钮/小手光标/窗口拉伸与撑宽/查快捷键按钮重做/滚动悬停卡死
> v0.7（2026-08-28）：UI 深度审计，落地 P0+P1 两包共 8 项（P-042~P-049）：死元素修复/KeyHub 唤起方式/全页 Esc/词边界搜索/死代码清理/深色模式动态色/粘贴报错直达/最近查看
> v0.6（2026-08-28）：用户实测反馈 6 项交互 bug（P-036~P-041）全部修复：红绿灯重叠/输入覆盖/悬停错位/返回按钮截断+逻辑/搜索页无返回/复制无反馈

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v0.8 | 2026-08-29 | UI 体验十项修复专项：新增 P-050~P-059（10 项）全部 ✅（卡片白线/悬停裁剪/搜索页间距/代码块宽度/小手光标/窗口尺寸锁定与撑宽修复/查快捷键重做/滚动悬停卡死） |
| v0.7 | 2026-08-28 | UI 深度审计专项：新增 P-042~P-049（8 项）全部 ✅，落地 P0+P1 两包（死元素/深色模式/搜索质量/最近查看） |
| v0.6 | 2026-08-28 | 交互 bug 专项：P-036~P-041 全部 ✅（红绿灯重叠/输入覆盖/悬停错位/返回截断+历史栈/搜索页返回按钮/复制反馈） |
| v0.5 | 2026-08-28 | UI v2.0 重构完成：P-025~P-035 全部 ✅（背景渐变/Logo/分类胶囊/收藏横向/搜索框/热键/锁徽章/TagView/间距/回顶按钮） |
| v0.4 | 2026-08-28 | 真实运行截图复核，新增 P-025~P-035（11 项 UI 视觉专项），4 项 P0（背景/Logo/分类/收藏区） |
| v0.3 | 2026-08-28 | 复读 UI 实现代码，新增 P-015~P-024（搜索框/卡片动效/详情页/分组标题/空状态/快速分类/收藏区/深色模式等），清理 P-014 重复项 |
| v0.2 | 2026-08-28 | UI 验证：新增 P-008~P-014（复制全部只复制第一条、Enter 不打开选中项等），通过项表补充 UI 类 8 项 |
| v0.1 | 2026-08-28 | 初始问题记录：ERROR_PREVENTION 落地验证发现 7 项问题（P1×4、P2×3） |

---

*SpiceNest 问题记录 · 记录到修复，不留死角*
