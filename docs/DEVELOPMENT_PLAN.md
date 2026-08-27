# SpiceNest MVP 开发计划

> 版本：0.1 | 日期：2026-08-27
> 状态：待执行
> 本文档是 ROADMAP.md 第一阶段（MVP）的详细执行计划，分 8 步完成。
> 每完成一步截图/打印结果给用户确认，没问题再继续下一步。

---

## 整体目标

做出一个能跑的 App：全局热键唤出 → 搜索框 → 输入关键词出结果 → 点进去看详情 → 代码一键复制。

先放 10 个仿真指令 + 10 个常见错误的内容，验证搜索体验是否顺手。

---

## 第 1 步：搭项目框架（从 Nexus TEMPLATE 复制）

### 做什么

把 `/Users/dawnli/Documents/Nexus/TEMPLATE/` 里的文件复制到 SpiceNest 目录，修改配置文件，把模板的 "MyApp" 全部改成 "SpiceNest"。

具体修改：

| 文件 | 修改内容 |
|------|---------|
| `nexus.json` | 应用名 SpiceNest，id spicenest，bundle id `com.nexus.tool.spicenest`，URL Scheme `nexus-spicenest`，主题色 `#FF9500`，热键 `Ctrl+Option+S` |
| `Info.plist` | Bundle ID、URL Scheme、LSUIElement=true |
| `build.sh` | 应用名改成 SpiceNest |
| `AppDelegate.swift` | 热键 keyCode 改成 `kVK_ANSI_S`，菜单栏图标改成 `bolt`，菜单应用名改成 SpiceNest，Nexus 应用子菜单加上 KeyHub |
| `main.swift` | 应用名 |
| `CHANGELOG.md` | 新建，初始版本 v0.1.0 |

模板已经带了全部 6 个 CommonKit 组件，不用额外引入。

### 产出

一个能编译、能运行的空壳 App，菜单栏有闪电图标，按 `Ctrl+Option+S` 能唤出毛玻璃窗口。

### 验收

- `./build.sh` 编译通过，无警告
- 运行后菜单栏出现闪电图标（SF Symbol `bolt`，isTemplate）
- 按 `Ctrl+Option+S` 能唤出/隐藏毛玻璃浮动窗口
- `open "nexus-spicenest://"` 能唤起 App
- 截图给用户确认菜单栏图标和窗口效果

### 需要用户确认

- [ ] 全局热键 `Ctrl+Option+S` 不与其他软件冲突
- [ ] 菜单栏图标用 `bolt`（闪电）OK
- [ ] 主题色琥珀色 `#FF9500` OK

---

## 第 2 步：定义数据模型

### 做什么

在 `Sources/Models/` 下创建 Swift 结构体，对应 SPECIFICATION.md 第五章定义的数据模型。

| 文件 | 内容 |
|------|------|
| `ContentItem.swift` | 统一内容项（id/type/title/chineseTitle/summary/tags/related）+ `ContentType` 枚举（command/parameter/error/formula/tip/topology） |
| `CommandDetail.swift` | 仿真指令详情（syntax/parameters/examples/notes） |
| `ErrorDetail.swift` | 错误详情（errorPattern/category/cause/solutions/copyableCommands） |
| `ParameterDetail.swift` | 参数详情（componentType/description/typicalRange/defaultValue/effect/example） |
| `FormulaDetail.swift` | 公式详情（formula/variables/calculator/description） |
| `TipDetail.swift` | 技巧详情（scenario/steps/copyableCommands/notes） |
| `TopologyDetail.swift` | 拓扑详情（category/description/formulas/designTips/ascSnippet/applications/difficulty） |

MVP 阶段实际用到 CommandDetail 和 ErrorDetail，其他 4 个先定义好，后续加内容不用改代码。

所有结构体遵循 `Codable`。

### 产出

编译通过的模型文件，无警告。

### 验收

- 编译通过，无警告
- 无 UI 变化，这一步是纯代码

---

## 第 3 步：内容加载服务 + 第一批内容数据

### 3a. ContentLoader 服务

创建 `Services/ContentLoader.swift`：

- 启动时读取 `Resources/content/index.json` 到内存（同步读取，文件小 < 100KB）
- 按需加载详情（用户点击时才读文件，读了缓存到 NSCache，最近 30 条）
- 根据 content type 自动找对应的 JSON 文件
  - 指令：`content/commands/<id>.json`（单独文件）
  - 错误：`content/errors/common-errors.json`（数组文件，按 id 查找）
  - 其他类型：类似数组文件

### 3b. 第一批内容数据（JSON）

| 文件 | 内容 |
|------|------|
| `Resources/content/index.json` | 20 条内容的索引（10 指令 + 10 错误） |
| `Resources/content/commands/command-op.json` | .op 直流工作点 |
| `Resources/content/commands/command-tran.json` | .tran 瞬态仿真 |
| `Resources/content/commands/command-ac.json` | .ac 交流扫描 |
| `Resources/content/commands/command-dc.json` | .dc 直流扫描 |
| `Resources/content/commands/command-step.json` | .step 参数扫描 |
| `Resources/content/commands/command-meas.json` | .meas 测量参数 |
| `Resources/content/commands/command-temp.json` | .temp 温度扫描 |
| `Resources/content/commands/command-ic.json` | .ic 初始条件 |
| `Resources/content/commands/command-options.json` | .options 仿真选项 |
| `Resources/content/commands/command-model.json` | .model 模型定义 |
| `Resources/content/errors/common-errors.json` | 10 个错误的数组 |

10 个常见错误：
1. Time step too small
2. Singular matrix
3. Node ... is floating
4. Unknown parameter
5. Unknown device
6. Gmin step failed
7. Source stepping failed
8. Iteration limit reached
9. Duplicate device name
10. Syntax error

### 产出

- ContentLoader 能正确读取和解析 index.json 和详情文件
- 20 条内容数据全部写好，格式符合 docs/content-guide.md 规范

### 验收

- 在 AppDelegate 里写临时测试代码（或单元测试），验证：
  - index 加载了 20 条内容
  - 随机抽 2 条指令详情能正确解析（语法、参数、示例、注意事项都有）
  - 随机抽 2 条错误详情能正确解析（原因、解决方案、可复制指令都有）
- 把解析结果 print 出来给用户看
- 内容准确性需要用户逐条核对

### 注意

内容质量是关键。每个指令的语法、参数、示例都要准确，参考 LTspice 官方文档和 KeyHub 里已有的 LTspice 指令数据。写完逐条给用户过目。

---

## 第 4 步：写搜索服务

### 做什么

创建 `Services/SearchService.swift`：

- 实时搜索（输入即搜，100ms 节流 debounce）
- 多字段匹配，按权重排序：
  1. 标题精确匹配（权重最高）
  2. 标题包含匹配
  3. 中文标题匹配
  4. 标签匹配
  5. 摘要包含匹配（权重最低）
- 大小写不敏感
- 结果按 type 分组（command/parameter/error/formula/tip/topology）
- 每组内按匹配权重降序排列
- 返回 `[ContentType: [ContentItem]]`

### 产出

搜索服务能正确返回分组排序结果。

### 验收

用测试代码验证以下搜索词，把结果 print 出来：

| 搜索词 | 预期结果 |
|--------|---------|
| `tran` | .tran 指令 + Time step too small 错误 |
| `收敛` | 多个收敛相关的错误（Gmin step failed, Source stepping failed 等） |
| `未知` | Unknown parameter + Unknown device |
| `仿真` | .tran + .ac + .op 等多个指令 |
| `xyz不存在` | 空结果 |

---

## 第 5 步：写 UI 基础组件

### 做什么

在 `Sources/Views/` 下创建 UI 组件：

| 文件 | 内容 |
|------|------|
| `SearchFieldView.swift` | 搜索框（NSSearchField，自动聚焦，实时搜索回调，清除按钮） |
| `CopyableCodeView.swift` | 可复制代码块（深色背景，SF Mono 字体，右上角复制按钮，复制成功变对勾，2秒后恢复） |
| `ContentCardView.swift` | 搜索结果卡片（类型图标 + 标题 + 中文标题 + 摘要 + 关键信息预览 + 复制按钮，悬停上浮3pt + 琥珀色边框 + 手型光标） |
| `CommonViews.swift` | 辅助视图（分组标题 SectionHeaderView、分隔线、空状态 EmptyStateView、标签 TagView） |

### 关键设计参考

- 卡片用**不透明背景**（避免毛玻璃上的半透明卡片导致非 Retina 屏字体模糊）——参考 KeyHub 踩坑记录
- 悬停效果：上浮 3pt + 阴影加深 + 1pt 琥珀色边框
- 像素对齐：所有 frame 取整，用 NXPixelUtils
- 卡片悬停 Bug：参考 KeyHub 踩坑记录，滚轮快速滚动时 NSTrackingArea 会丢失 mouseExited，需要全局 mouseMoved 监听 + Timer 定期更新悬停状态（MVP 阶段如果用 NSCollectionView 可以先不处理，后续打磨）

### 产出

4 个基础 UI 组件文件。

### 验收

在一个临时窗口里把这些组件摆出来（模拟搜索结果列表），截图给用户看效果，确认视觉风格 OK 再继续。

重点确认：
- 卡片样式（圆角、阴影、间距、字体层级）
- 悬停效果（上浮、边框、手型光标）
- 代码块样式（深色背景、字体、复制按钮）
- 搜索框样式（聚焦状态、清除按钮）

---

## 第 6 步：写页面视图

### 做什么

| 文件 | 内容 |
|------|------|
| `HomeView.swift` | 首页：SpiceNest Logo（Impact 28pt）+ 副标题 + 热键提示（键帽样式）+ 搜索框 + 快速分类标签（6个类型，MVP 阶段指令和错误可点，其他灰色）+ 收藏区（MVP 可先空着或放占位） |
| `SearchResultView.swift` | 搜索结果页：顶部搜索框（保留关键词）+ 按类型分组的结果列表（每组有分组标题+数量）+ 每个结果是 ContentCardView + 空状态提示 + 支持键盘 ↑↓ 选择、Enter 打开 |
| `DetailView.swift` | 详情页：左上角返回按钮 + 完整详情卡片（根据 type 渲染不同字段）+ 底部操作栏（收藏、复制全部、查快捷键跳 KeyHub——MVP 可先不做跳转）+ 可纵向滚动 |

### 详情页渲染逻辑

根据 ContentItem.type 渲染不同字段：

- **command 类型**：标题 + 摘要 → 语法列表 → 参数说明表格 → 示例（每个示例带 CopyableCodeView）→ 注意事项 → 关联内容
- **error 类型**：标题 + 错误类别标签 → 原因分析 → 解决方案（编号列表）→ 可复制指令（CopyableCodeView）→ 关联内容
- 其他类型（parameter/formula/tip/topology）：MVP 阶段可以先显示通用布局（标题 + 摘要 + 关联内容），第二阶段再完善

### 产出

3 个页面视图文件。

### 验收

把三个页面分别截图给用户看，重点确认：

**首页：**
- Logo 字体和大小
- 搜索框位置和大小
- 快速分类标签样式
- 整体留白和间距

**搜索结果页：**
- 分组标题样式
- 卡片间距
- 空状态提示
- 键盘选中状态（如果能演示）

**详情页：**
- 返回按钮位置
- 详情卡片布局
- 代码块样式
- 底部操作栏
- 滚动流畅度

---

## 第 7 步：AppDelegate 整合

### 做什么

重写 `AppDelegate.swift`，把前面所有模块整合起来。

| 功能 | 实现 |
|------|------|
| 窗口管理 | 创建 560pt 固定宽度、400~3000pt 高度的毛玻璃浮动窗口（NXWindowStyle），琥珀色叠加层 alpha 0.12 |
| 页面路由 | 容器视图切换 HomeView / SearchResultView / DetailView，用一个 `currentPage` 状态控制 |
| 搜索绑定 | 搜索框输入 → 100ms 节流 → SearchService.search() → 切换到 SearchResultView 并传入结果 |
| 点击结果 | ContentLoader.loadDetail(id) → 切换到 DetailView 并传入详情数据 |
| 返回 | 返回按钮 / Esc 键 → 回到上一页（详情→搜索结果→首页） |
| 键盘操作 | ↑↓ 选择搜索结果、Enter 打开选中结果、Esc 返回/关闭窗口 |
| 菜单栏 | 显示/隐藏、Nexus 应用子菜单（KeyHub + SpiceNest，动态检测是否安装）、退出 |
| 全局热键 | Ctrl+Option+S 切换窗口显示/隐藏（NXHotKeyManager） |
| URL Scheme | application(_:open:) 接收 nexus-spicenest:// 和 nexus-spicenest://search?q=xxx，显示窗口并执行搜索 |
| 收藏功能 | FavoritesService（UserDefaults 持久化），详情页收藏按钮，首页显示收藏列表 |
| 搜索历史 | FavoritesService 记录最近 10 条搜索，首页显示（MVP 可选，第二阶段必做） |

### 产出

一个完整可运行的 App。

### 验收

全流程演示，截图或录屏：

1. 启动 App → 菜单栏出现闪电图标
2. 按 Ctrl+Option+S → 窗口弹出，显示首页，搜索框自动聚焦
3. 输入 "tran" → 实时出搜索结果（.tran 指令 + Time step too small 错误）
4. 用 ↑↓ 键选择结果，Enter 打开 → 显示 .tran 详情页
5. 在详情页点复制按钮 → 提示已复制（按钮变对勾）
6. 按 Esc → 回到搜索结果页 → 再按 Esc → 回到首页 → 再按 Esc → 关闭窗口
7. 测试 URL Scheme：终端执行 `open "nexus-spicenest://search?q=error"` → 窗口弹出并自动搜索 "error"
8. 测试收藏：详情页点收藏 → 首页收藏区出现该卡片
9. 菜单栏操作：点闪电图标 → 菜单显示"显示/隐藏 SpiceNest"、"Nexus 应用"子菜单、"退出"

---

## 第 8 步：MVP 打磨和验证

### 做什么

| 类别 | 具体工作 |
|------|---------|
| 视觉打磨 | 检查间距、字体层级、颜色、悬停效果、过渡动画，确保和设计规范一致 |
| 非 Retina 屏适配 | 所有 view frame 取整（NXPixelUtils.alignSubviewsToPixels），自定义 layer 的 contentsScale 同步（viewDidChangeBackingProperties），卡片用不透明背景 |
| 卡片悬停 Bug | 参考 KeyHub 踩坑记录：全局 NSEvent.addLocalMonitorForEvents 监听 mouseMoved/scrollWheel，80ms Timer 定期更新悬停状态（必须添加到 .common runloop mode），卡片提供 applyHoverState(_:) 公开方法 |
| 性能检查 | 发布下限：启动时间 < 2秒，搜索响应 < 100ms，内存占用 < 100MB（空闲时），空闲 CPU < 1%。开发目标（更严）：启动 < 1s，搜索 < 10ms，内存 < 50MB，见 architecture.md 第六章 |
| 编译警告 | 确保零警告，无强制解包（除非有注释说明安全），无死代码 |
| 内容准确性 | 逐条核对 10 个指令和 10 个错误的语法、参数、解决方案，与 LTspice 实际行为一致 |
| CHECKLIST 自检 | 对照 CHECKLIST.md 逐项检查 MVP 相关项（功能检查、内容检查、UI/UX 检查、技术检查、Nexus 合规） |
| 版本信息 | 更新 nexus.json 版本号 v0.1.0，更新 CHANGELOG.md |

### 产出

MVP v0.1.0 正式版本，SpiceNest.app 可直接运行。

### 验收

- 全流程无 Bug
- 编译零警告
- CHECKLIST MVP 相关项全部通过
- 最终交付 SpiceNest.app + 使用说明

---

## 时间预估

| 步骤 | 预估 | 说明 |
|------|------|------|
| 1. 搭框架 | 快 | 复制+改配置，主要是验证编译 |
| 2. 数据模型 | 快 | 纯代码，按规格写结构体 |
| 3. 内容加载+数据 | 中等 | 20 条内容需要仔细写，准确性要求高 |
| 4. 搜索服务 | 快 | 算法不复杂 |
| 5. UI 基础组件 | 中等 | 视觉效果需要反复调 |
| 6. 页面视图 | 中等 | 三个页面，布局需要调 |
| 7. AppDelegate 整合 | 中等 | 串起来容易出各种小问题 |
| 8. 打磨验证 | 中等 | 细节打磨耗时 |

顺利的话几轮对话能做完 MVP，主要耗时在内容准确性和 UI 细节打磨上。

---

## 执行原则

1. **一步一确认**：每步完成截图/打印结果给用户，用户说 OK 再继续下一步
2. **内容用户核对**：第 3 步的 20 条内容数据写完给用户过目
3. **UI 用户把关**：第 5、6 步截图给用户看，觉得丑就改，改到满意
4. **遇到规则冲突可上诉**：开发中如果发现 Nexus 规则限制了产品体验，按 SPECIFICATION 1.4 节提出上诉
5. **不阻塞开发**：上诉评估期间可以临时不遵守冲突规则继续开发

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| 0.1 | 2026-08-27 | 初始 MVP 开发计划，8 步执行 |

---

*SpiceNest MVP 开发计划 · 一步一确认，质量第一*
