# SpiceNest UI 视觉重构方案（v2.0）

> 版本：0.1 | 日期：2026-08-28
> 定位：基于实际运行 v1.0.0 截图复核，从"现代 macOS 原生感"出发，对 UI 视觉做一次系统性重构
> 触发：用户对当前 UI 不满意，要求"优化 UI"
> 范围：仅 UI 视觉层（不涉及交互逻辑、内容、后端）
> 关系：[PROBLEM_LOG.md](PROBLEM_LOG.md) P-025~P-035 是问题清单，本文件是解决方案 + 落地计划

---

## 一、问题总览（来自 PROBLEM_LOG v0.4）

| ID | 问题 | 严重 | 一句话描述 |
|----|------|------|----------|
| P-025 | 窗口背景浑浊棕黄 | **P0** | popover + 琥珀 tint 叠加出"米黄/卡其"色，整体脏 |
| P-026 | Logo 发糊字重不足 | **P0** | Impact 28pt 渲染模糊、视觉权重不够 |
| P-027 | 热键提示排版拥挤 | P1 | 键帽和"快速唤出"文字紧贴无间距 |
| P-028 | 搜索框占位被截断 | P1 | "…公式…" 看着像被卡住 |
| P-029 | 快速分类像纯文字 | **P0** | 6 个分类没有胶囊/图标，视觉上不像可点 |
| P-030 | 收藏区布局诡异 | **P0** | 唯一卡片被推到最底部，中间 400pt 空白 |
| P-031 | 详情页代码块间距松散 | P2 | 12pt 间距过大 |
| P-032 | 分组标题与上方断层 | P2 | 搜索框与第一组之间 80pt 空白 |
| P-033 | 4 类内容永久禁用 | P1 | 4 个分类标灰，UI 像"半成品" |
| P-034 | 详情页缺"回顶"入口 | P3 | 长内容回顶要手动滚 |
| P-035 | 详情页 TagView 颜色偏淡 | P2 | 蓝底 alpha 0.12 几乎看不见 |

**总结：4 项 P0（背景脏 / Logo 糊 / 分类像纯文字 / 收藏区布局）+ 4 项 P1 + 3 项 P2/P3**

---

## 二、重构总策略

### 2.1 三个核心原则

1. **背景要"轻"，要"透明"，不要"染色"**
   - 彻底放弃 popover material 的暖色调底色
   - 改用 `.hudWindow` 或 `.underWindowBackground` 极轻毛玻璃
   - 琥珀色只用作"点缀"（图标、按钮、强调），不要"染色"整个窗体
   - 推荐方案：用 `CAGradientLayer` 做一个从顶 4% 琥珀到底 0% 的极轻线性渐变

2. **Logo / 标题要"有存在感"，用现代字体**
   - 放弃 Impact（压缩字、模糊感）
   - 改用 SF Pro Rounded Bold / SF Pro Display Heavy
   - 字号提到 36pt，加 `NSPixelUtils.align` 像素对齐
   - 颜色用琥珀渐变 `#FFB340` → `#FF6A00`，加极轻投影

3. **分类 / 卡片要"像按钮"，不要"像文字"**
   - 所有可点击元素必须有：背景 / 描边 / 图标，三选一以上
   - 启用态用类型色描边 + 透明底
   - 悬停态用类型色填充 alpha 0.12 + 文字变类型色
   - 禁用态去掉所有装饰，仅留灰色文字 + 极轻灰底

### 2.2 视觉风格关键词

| 关键词 | 体现 |
|--------|------|
| **轻（Light）** | 背景透明 / 渐变 / 极浅底 |
| **净（Clean）** | 大留白 / 卡片悬浮 / 无多余线 |
| **精（Precise）** | 像素对齐 / 一致圆角 / 统一间距 |
| **品（Branded）** | 琥珀色仅作强调 / 类型色仅作分类标识 |
| **动（Motion）** | 悬停 0.2s / 点击 0.1s / 切换 0.2s 淡入淡出 |

---

## 三、详细重构方案（按页面）

### 3.1 全局：窗口背景（P-025）★ P0

**目标**：从"米黄/卡其"变回"通透/中性/有一点点琥珀呼吸感"

**改造点**：
- `NXWindowStyle.makeFloatingWindow` 不直接修改（Common 只读），在 AppDelegate 调用时改造
- 在 `setupWindow` 中：
  - 把 `tintColor` 改为 `NSColor.clear`（即不叠纯色）
  - 在毛玻璃 + 主题色叠加层之间，**插入一个 CAGradientLayer**：
    - 起点 (0, 0) 终点 (0, 1)
    - 颜色：顶部 `NSColor(red: 1.0, green: 0.584, blue: 0.0, alpha: 0.06)` → 底部 `NSColor(red: 1.0, green: 0.584, blue: 0.0, alpha: 0)`
  - 渐变层放最底层（毛玻璃底色之下），不挡内容

**对比图**（文字版）：

```
现在：popover(米白偏暖) + 纯色琥珀 alpha 0.12 = 浊黄
      ┌─────────────────────────┐
      │  ░░░░ 浊黄 ░░░░░░░░░░░░░ │ ← 整体发黄
      └─────────────────────────┘

目标：popover(中性) + 顶部 0.06 琥珀渐变 = 通透带一丝暖
      ┌─────────────────────────┐
      │ ▒ 顶浅暖底中性 ▒▒▒▒▒▒▒▒▒ │ ← 顶部微微琥珀呼吸，底部干净
      └─────────────────────────┘
```

**验收**：截图后背景近似"非常浅的暖灰"或"几乎透明"，肉眼几乎无"染色"感

---

### 3.2 首页：Logo（P-026）★ P0

**目标**：从"发糊"到"清晰、有品牌感"

**改造点**（`Sources/Views/HomeView.swift` 第 53-62 行）：
- 字号 28pt → **36pt**
- 字体 `Impact` → **`SF Pro Rounded Bold`**（NSFont.systemFont(ofSize: 36, weight: .heavy) 配 tracking 调整）
- 颜色：单色琥珀 → **渐变琥珀**（用 `NSGradient` 或富文本多色拼接）
  - 首字母"S"：#FFB340（亮琥珀）
  - 末字母"t"：#FF6A00（深琥珀）
- 阴影：去掉（阴影让字体边缘糊）
- 副标题 13pt → **15pt Medium**，次文字色不变

**视觉示意**（ASCII 模拟）：

```
   现在：                  目标：
    SpiceNest              S p i c e N e s t
    (糊、小)              (清晰、有渐变、更大)
   LTspice 参考助手        LTspice 参考助手
```

---

### 3.3 首页：热键提示（P-027）P1

**改造点**（`HomeView.swift` 第 73-104 行）：
- 三个键帽样式升级：
  - 背景：controlBackgroundColor → **琥珀 alpha 0.12**
  - 文字：labelColor → **琥珀色**
  - 描边：1pt 灰 → **1pt 琥珀 alpha 0.4**
  - 圆角 4pt → **5pt**（更"键帽"）
- "快速唤出"文字：
  - 字号 11pt → **12pt Medium**
  - 颜色 tertiaryLabelColor → **secondaryLabelColor**
  - 与最后一个键帽的间距：紧贴 → **6pt**
- 整体与上方副标题间距：6pt → **10pt**

---

### 3.4 首页 + 搜索页：搜索框（P-028）P1

**改造点**（`Sources/Views/SearchFieldView.swift`）：
- 内边距调整：
  - 左侧 icon 与 textField 间距：8pt → **6pt**
  - 右侧 clearButton 与 textField 间距：-8pt → **-6pt**
  - 左侧 icon 距背景：12pt → **10pt**
- placeholder 精简：`"搜索指令、参数、报错、公式…"` → `"搜索 6 类内容…"` 或保留原版（看实际宽度决定）
- 字号 14pt → **13pt**（更现代）

**兜底**：如果还截断，把 `textField.cell?.lineBreakMode = .byTruncatingTail` 改为 `.byClipping` + `usesSingleLineMode = true`

---

### 3.5 首页：快速分类（P-029）★ P0 + P-033

**这是首页最大的改造**，需要重写 `CategoryTagView`

**改造方案**（彻底重做）：

```swift
// 默认态：1pt 琥珀描边 + 透明底 + 类型图标 + 文字次文字色
// 悬停态：琥珀填充 alpha 0.12 + 描边加粗到 1.5pt + 文字变琥珀
// 选中态：琥珀填充 alpha 0.20 + 1.5pt 琥珀描边 + 文字变琥珀 + 极轻外发光
// 禁用态：无描边、无填充、文字 placeholder 色 + 右侧带 🔒 小图标（待定）
```

**布局**：从 2 行 3 列 → **3 行 2 列**（每行 2 个胶囊，卡片更宽，文字不截断）

**视觉示意**（用 Unicode 框模拟）：

```
现在（2行3列纯文字）：           目标（3行2列胶囊）：
 仿真指令  常见错误  元器件参数    ┌──────────┐  ┌──────────┐
 公式速算  操作技巧  电路拓扑    │ ⌘ 仿真指令 │  │ ⚠ 常见错误 │
                                  └──────────┘  └──────────┘
                                 ┌──────────┐  ┌──────────┐
                                 │ ⌗ 元器件参数🔒│ │ 🧮 公式速算🔒│
                                 └──────────┘  └──────────┘
                                 ┌──────────┐  ┌──────────┐
                                 │ 💡 操作技巧🔒│ │ ⏚ 电路拓扑🔒│
                                 └──────────┘  └──────────┘
```

**P-033 解决**：未启用分类右下角加 🔒 小图标（10pt 系统 placeholder 色），鼠标悬停 tooltip 提示"第二阶段上线"

---

### 3.6 首页：收藏区（P-030）★ P0

**改造方案**：从"垂直列表 + 撑满底部"改为"**横向滚动 + 卡片宽 160pt**"

**改造点**（`HomeView.swift` 第 180-237 行）：
- `favoritesScrollView`：
  - `hasVerticalScroller = false` → `hasHorizontalScroller = true`
  - frame 不再撑满到 bottom，改为 heightAnchor = 130pt
- `favoritesStackView`：
  - `orientation = .vertical` → `orientation = .horizontal`
  - `spacing = 8` → `spacing = 10`
- 卡片：
  - 复用现有 `ContentCardView`，但加宽度约束 `widthAnchor = 160pt`
  - 高度 `greaterThanOrEqualToConstant: 80` → `equalToConstant: 110pt`（统一）
- 整块收藏区：高度限制 + 距底部间距 12pt
- 无收藏时：横向居中显示一个"空状态小卡"（宽 520pt × 110pt）
  - 图标：SF Symbol `star`（24pt，tertiaryLabelColor）
  - 文案："暂无收藏 · 打开任意指令点 ⭐ 收藏起来吧"
  - 整卡背景：琥珀 alpha 0.04 圆角 12pt

**视觉示意**：

```
现在：                          目标：
⭐ 收藏                          ⭐ 收藏 (1)
                          (400pt 空白)            [ .op 直流工作点 ]
                                                   [ 单卡宽 160pt ]
                                                   [ 距底部 12pt   ]
```

---

### 3.7 详情页：TagView（P-035）P2

**改造点**（`Sources/Views/CommonViews.swift` TagView 段落）：
- 背景 alpha 0.12 → **alpha 0.20**
- 字体 .medium → **.semibold**
- 字号 10pt → **11pt**
- 内边距 6pt → **7pt**（水平）/ 2pt → **3pt**（垂直）
- **新增**：左侧加 4pt 宽 × 16pt 高的类型色色块（layer，cornerRadius 2pt），更"标识"

**视觉示意**：

```
现在：                          目标：
┌──────────┐                   ┃┌──────────┐
│ 仿真指令  │                   ┃│ 仿真指令  │ ← 4pt 蓝块 + 文字
└──────────┘                   ┃└──────────┘
```

---

### 3.8 详情页：代码块间距（P-031）P2

**改造点**（`Sources/Views/DetailView.swift` 第 79 行）：
- `contentStackView.spacing = 12` → **8**
- 代码块之间不加分隔线（保持干净）
- 顶部加 1 个 "语法" 小节标题（H2 16pt Semibold 琥珀色），与下方"参数说明"统一

---

### 3.9 搜索结果页：分组标题间距（P-032）P2

**改造点**（`Sources/Views/SearchResultView.swift` 第 108 行）：
- `searchField.bottomAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8)` → **`constant: 0`**
- 第一个分组标题上方加 padding 4pt（在 `renderResults` 第一个 header 加 heightAnchor = 32pt）
- 搜索框底部加 1pt 极淡分隔线（用 SeparatorView，仅宽度 = 容器宽 - 32pt，水平居中）

---

### 3.10 详情页：回顶按钮（P-034）P3

**改造点**（`Sources/Views/DetailView.swift`）：
- 新增 `scrollToTopButton`（NSButton，圆角 20pt，琥珀 alpha 0.12 背景，↑ 图标）
- 监听 `scrollView.contentView.boundsDidChange`，当 `contentView.bounds.minY > 200` 时显示按钮
- 按钮位置：右下角，距右 16pt / 距下 60pt（在操作栏上方）
- 点击：NSScrollView scrollPoint: CGPoint(x: 0, y: 0)，0.3s 动画
- 0.2s 淡入淡出

---

## 四、重构优先级与排期

### 4.1 P0 必做（影响"能不能看"）

| 序号 | 任务 | 文件 | 工作量 |
|------|------|------|--------|
| 1 | 窗口背景渐变改造 | `AppDelegate.swift` | 0.5h |
| 2 | Logo 字体/字号/颜色改造 | `HomeView.swift` | 0.5h |
| 3 | 快速分类完全重写 | `CategoryTagView.swift` | 1.5h |
| 4 | 收藏区改横向布局 | `HomeView.swift` | 1.0h |
| **小计** | | | **3.5h** |

### 4.2 P1 应做（影响"好不好用"）

| 序号 | 任务 | 文件 | 工作量 |
|------|------|------|--------|
| 5 | 热键提示键帽升级 | `HomeView.swift` | 0.5h |
| 6 | 搜索框内边距调整 | `SearchFieldView.swift` | 0.5h |
| 7 | 4 个禁用分类加 🔒 图标 | `CategoryTagView.swift` | 0.3h |
| **小计** | | | **1.3h** |

### 4.3 P2 看时间（影响"精不精致"）

| 序号 | 任务 | 文件 | 工作量 |
|------|------|------|--------|
| 8 | TagView 加色块 + 加深背景 | `CommonViews.swift` | 0.5h |
| 9 | 详情页代码块间距 | `DetailView.swift` | 0.2h |
| 10 | 分组标题间距调整 | `SearchResultView.swift` | 0.3h |
| **小计** | | | **1.0h** |

### 4.4 P3 锦上添花

| 序号 | 任务 | 文件 | 工作量 |
|------|------|------|--------|
| 11 | 详情页回顶按钮 | `DetailView.swift` | 0.5h |
| **总计** | | | **6.3 小时** |

---

## 五、落地步骤建议

### 5.1 推荐顺序（按"先解决最碍眼的"原则）

```
第 1 步：窗口背景（P-025）       30 min  ★★★ 立刻改善整体观感
   ↓
第 2 步：Logo 改造（P-026）       30 min  ★★★ 立刻提升品牌感
   ↓
第 3 步：快速分类重写（P-029）    90 min  ★★★ 首页"可点击"感质变
   ↓
第 4 步：收藏区横向布局（P-030）  60 min  ★★★ 首页布局"对齐"
   ↓
第 5 步：搜索框 + 热键 + 锁图标  共 80 min  P1 顺带做
   ↓
第 6 步：TagView + 间距细节       共 100 min  P2 顺带做
   ↓
第 7 步：回顶按钮                  30 min  P3 最后做
```

### 5.2 每步的标准动作

1. **改前截图**（用 `nexus-spicenest://snapshot` 截当前页）
2. **改代码**（单步单改，便于 review）
3. **build.sh 编译**（确保 0 警告）
4. **改后截图**（同一页对比）
5. **视觉对比 + 自查**（是否解决 P-XXX 描述的问题）
6. **更新 PROBLEM_LOG 状态**（⬜ → 🔧 → ✅）

### 5.3 验收标准

每一步完成后，对照以下 4 条：

- [ ] 截图与 PROBLEM_LOG 描述的"现象"不再一致（问题被修复）
- [ ] 截图与本文档"目标"描述的视觉示意一致（达到预期）
- [ ] 编译 0 警告 + 0 错误
- [ ] 深色模式下（系统切换）无新增的对比度 / 可读性问题

### 5.4 风险与回滚

- 所有改动都集中在 `Sources/Views/` 目录和 `AppDelegate.setupWindow`
- 不动 `Common/`、不动 Models / Services
- 不改任何 content JSON
- 改坏了可直接 `git checkout -- Sources/Views/` 回滚

---

## 六、推荐的设计语言参考

| 方向 | 参考应用 | 借鉴点 |
|------|---------|--------|
| 浮动窗口毛玻璃质感 | Raycast / Alfred | 极轻底色 + 卡片悬浮 + 紧凑留白 |
| 分类胶囊设计 | Linear / Notion | 描边 + 图标 + 悬停填充 |
| 横向卡片流 | Spotify / Apple Music | 固定宽 + 横向滚动 + 圆角 |
| 极简搜索框 | Spotlight / Cmd+Space | 图标 + 极轻边 + 聚焦呼吸 |
| 配色克制 | Things 3 / Bear | 强调色仅在交互元素，不染背景 |

---

## 七、版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v0.1 | 2026-08-28 | 初版：11 项问题对应 11 个改造点 + 优先级 + 落地步骤；总工作量 ~6.3h |
| v0.2 | 2026-08-28 | 全部 7 步落地完成，11 项问题（P-025~P-035）全部 ✅，见下方"八、落地结果" |

---

## 八、落地结果（2026-08-28 完成）

按 1→7 顺序全部执行完毕，构建 0 警告，三页截图复核通过。

| 步骤 | 改造点 | 问题 | 结果 | 改动文件 |
|------|--------|------|------|---------|
| 1 | 窗口背景渐变 | P-025 | ✅ 去纯色 tint，顶部 0.06 琥珀渐变，背景中性通透 | AppDelegate.swift |
| 2 | Logo 重做 | P-026 | ✅ SF Pro Rounded Heavy 36pt，Spice 亮琥珀 + Nest 深琥珀，去阴影 | HomeView.swift |
| 3 | 快速分类重做 | P-029/P-033 | ✅ 类型图标 + 类型色描边胶囊，3 行 2 列；4 个禁用项加 🔒 + tooltip | CategoryTagView.swift / HomeView.swift |
| 4 | 收藏区横向 | P-030 | ✅ 横向滚动 160pt 卡片；空状态友好卡片；标题带计数 | HomeView.swift |
| 5 | 搜索框 + 热键 | P-027/P-028 | ✅ 键帽琥珀底描边；搜索框内边距收窄、13pt，占位完整 | HomeView.swift / SearchFieldView.swift |
| 6 | TagView + 间距 | P-031/P-032/P-035 | ✅ TagView 加 4pt 色块 + alpha 0.20 + semibold；详情页 spacing 8；搜索页顶部对齐 | CommonViews.swift / DetailView.swift / SearchResultView.swift |
| 7 | 回顶按钮 | P-034 | ✅ 滚动超 200pt 右下角浮现 ↑，0.3s 平滑回顶 | DetailView.swift |

### 额外发现并修复

- **搜索结果页顶部空白（新发现）**：NSScrollView 的 documentView 默认非翻转坐标系，纵向堆栈从底部排布导致顶部 ~400pt 空白。新增 `FlippedStackView`（isFlipped = true）修复，内容从顶部排布。

### 验证截图

- 首页：`/tmp/v2_home.png`（Logo 清晰渐变、分类胶囊带图标/锁、收藏横向卡片）
- 搜索页：`/tmp/v2_search.png`（分组标题紧贴搜索框、卡片从顶部排布）
- 详情页：`/tmp/v2_detail.png`（TagView 带色块、代码块紧凑）

---

*SpiceNest UI v2.0 · 轻、净、精、品、动，让查 LTspice 成为一种享受*
