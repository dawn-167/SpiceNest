# SpiceNest 技术架构

> 本文档定义 SpiceNest 的技术实现细节，包括模块划分、关键类设计、数据流、性能优化和错误处理。
> 产品层面的规格见 [SPECIFICATION.md](../SPECIFICATION.md)。

---

## 一、技术选型

| 维度 | 选择 | 原因 |
|------|------|------|
| 平台 | macOS 13.0+ | 遵循 Nexus 最低版本要求 |
| 语言 | Swift 5 | 苹果生态首选，性能好 |
| UI 框架 | AppKit（纯代码布局） | 参考 KeyHub，对浮动窗口/毛玻璃/自定义视图控制更精细；SwiftUI 在 macOS 高级特性上不够灵活 |
| 构建工具 | swiftc + build.sh | 遵循 Nexus 标准构建脚本，无 Xcode 项目依赖 |
| 数据格式 | JSON（Codable 解析） | 结构化内容，类型安全，易于编辑和版本控制 |
| 搜索 | 内存过滤（自定义匹配算法） | 数据量小（200-300条），内存搜索足够，零依赖 |
| 第三方依赖 | 无 | 遵循 Nexus 零外部依赖原则 |
| 热键 | Carbon API（NXHotKeyManager） | CommonKit 封装 |
| 窗口 | NSWindow + NSVisualEffectView（NXWindowStyle） | CommonKit 封装 |
| 菜单栏 | NSStatusItem（NXStatusItem） | CommonKit 封装 |

---

## 二、整体架构

```
SpiceNest App
├── App 层
│   └── AppDelegate            # 应用主体：窗口管理、页面路由、菜单栏、热键、URL Scheme
├── Views 层（UI 展示）
│   ├── HomeView               # 首页（搜索框 + 快速分类 + 收藏 + 历史）
│   ├── SearchResultView       # 搜索结果列表（分组展示）
│   ├── DetailView             # 详情页容器（返回按钮 + 内容卡片 + 操作栏）
│   ├── ContentCardView        # 内容卡片（通用，适配所有类型）
│   ├── SearchFieldView        # 搜索框（自动聚焦、实时搜索）
│   ├── CalculatorView         # 公式计算器组件
│   ├── CopyableCodeView       # 可复制代码块
│   └── CommonViews            # 辅助视图（分隔线、标签、空状态等）
├── Services 层（业务逻辑）
│   ├── ContentLoader          # 内容加载（JSON 读取、索引构建、按需加载、缓存）
│   ├── SearchService          # 搜索服务（模糊匹配、标签匹配、分组、排序）
│   ├── FavoritesService       # 收藏与历史（UserDefaults 持久化）
│   └── CalculatorService      # 公式计算器求值
├── Models 层（数据模型）
│   ├── ContentItem            # 统一内容项（搜索索引用）
│   ├── ContentType            # 内容类型枚举
│   ├── CommandDetail          # 仿真指令详情
│   ├── ParameterDetail        # 元器件参数详情
│   ├── ErrorDetail            # 常见错误详情
│   ├── FormulaDetail          # 公式速算详情
│   ├── TipDetail              # 操作技巧详情
│   └── TopologyDetail         # 电路拓扑详情
└── Common 层（Nexus CommonKit）
    ├── NXCommon               # 元宇宙元信息、应用分类枚举
    ├── NXHotKeyManager        # 全局热键管理
    ├── NXURLScheme            # 跨应用 URL Scheme 通信
    ├── NXWindowStyle          # 毛玻璃浮动窗口
    ├── NXStatusItem           # 菜单栏项和菜单
    └── NXPixelUtils           # 像素对齐工具
```

---

## 三、模块详细说明

### 3.1 AppDelegate

应用主体，单例管理所有状态。参考 KeyHub 的设计，不引入 ViewModel/Coordinator 等额外抽象。

**职责：**
- 应用生命周期管理
- 窗口创建和管理（toggle/show/hide）
- 页面路由（首页 ↔ 详情页切换）
- 菜单栏图标和菜单（含 Nexus 应用子菜单）
- 全局热键注册和处理
- URL Scheme 接收和处理
- 搜索状态管理（当前关键词、搜索结果）
- 内容加载触发

**关键属性：**
```swift
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?
    private var statusItem: NSStatusItem?
    private var contentLoader = ContentLoader()
    private var searchService = SearchService()
    private var favoritesService = FavoritesService()
    // 应用状态集中在 AppState 单例（见 CODE_STANDARDS 5.1），
    // AppDelegate 只做生命周期/窗口/路由协调，不直接持有业务状态
}
```

**AppState（全局状态单例）：**
```swift
final class AppState {
    static let shared = AppState()
    enum Page { case home, searchResults, detail }
    var currentPage: Page = .home
    var currentQuery: String = ""
    var selectedContent: ContentItem?
    private init() {}
}
```

### 3.2 ContentLoader

内容加载服务，管理所有内容数据。

> **协议驱动**：遵循 [CODE_STANDARDS](CODE_STANDARDS.md) 第四章约定，实际开发时定义 `ContentLoaderProtocol`，本类为具体实现。

**职责：**
- 应用启动时读取 `index.json` 到内存（搜索索引）
- 按需加载详情文件（用户点击结果时）
- 详情缓存（LRU，最近 30 条）
- 内容版本检查

**关键方法：**
```swift
final class ContentLoader {
    private(set) var index: [ContentItem] = []
    private var detailCache: NSCache<NSString, AnyObject> = .init()

    func loadIndex() throws               // 启动时调用，读取 index.json
    func loadDetail<T: Codable>(id: String) -> T?  // 按需加载，查缓存
    func loadCommandDetail(id: String) -> CommandDetail?
    func loadParameterDetail(id: String) -> ParameterDetail?
    // ... 其他类型
}
```

**文件路径规则：**
- index: `Bundle.main.url(forResource: "content/index", withExtension: "json")`
- 指令详情: `content/commands/<id>.json`（单独文件）
- 参数详情: `content/parameters/<componentType>.json`（数组文件，按 id 查找）
- 错误详情: `content/errors/common-errors.json`（数组文件）
- 公式详情: `content/formulas/formulas.json`（数组文件）
- 技巧详情: `content/tips/tips.json`（数组文件）
- 拓扑详情: `content/topologies/topologies.json`（数组文件）

### 3.3 SearchService

搜索服务，在内存索引中执行搜索。

> **协议驱动**：遵循 [CODE_STANDARDS](CODE_STANDARDS.md) 第四章约定，实际开发时定义 `SearchServiceProtocol`，本类为具体实现。

**职责：**
- 实时搜索（输入即搜）
- 多字段匹配（标题、中文标题、摘要、标签）
- 模糊匹配（大小写不敏感、包含匹配、拼音匹配可选）
- 结果按类型分组
- 相关度排序

**匹配算法：**
1. 标题精确匹配（权重最高）
2. 标题包含匹配
3. 中文标题匹配
4. 标签匹配
5. 摘要包含匹配
6. 按匹配权重排序

**关键方法：**
```swift
final class SearchService {
    func search(_ keyword: String, in items: [ContentItem]) -> [ContentType: [ContentItem]]
    private func match(_ item: ContentItem, keyword: String) -> Int  // 返回匹配权重，0 表示不匹配
}
```

### 3.4 FavoritesService

收藏和历史记录服务。

**职责：**
- 收藏内容（添加/移除/查询）
- 最近查看记录（自动记录，最多 20 条）
- 搜索历史（自动记录，最多 10 条）
- UserDefaults 持久化

**存储格式：**
```swift
final class FavoritesService {
    private let defaults = UserDefaults.standard
    private(set) var favorites: [String] = []      // 收藏的内容 id 列表
    private(set) var recentItems: [String] = []     // 最近查看的内容 id
    private(set) var searchHistory: [String] = []   // 搜索历史

    func toggleFavorite(id: String)
    func isFavorite(id: String) -> Bool
    func addRecentItem(id: String)
    func addSearchHistory(_ keyword: String)
}
```

### 3.5 CalculatorService

公式计算器求值服务。

**职责：**
- 根据公式配置计算结果
- 单位换算
- 输入验证

**设计决策：** 不做通用表达式解析器，常用公式硬编码为 Swift 函数，通过公式 id 映射。这样更安全、更准确，避免引入第三方表达式解析库。

```swift
final class CalculatorService {
    func calculate(formulaId: String, inputs: [String: Double]) -> Double?
    // 内部用 switch 匹配 formulaId，调用对应的计算函数
    private func rcLowpassCutoff(r: Double, c: Double) -> Double { 1 / (2 * .pi * r * c) }
    private func invertingGain(rf: Double, rin: Double) -> Double { -rf / rin }
    // ...
}
```

---

## 四、数据流

### 4.1 应用启动流程

```
1. applicationDidFinishLaunching
   ↓
2. NSApp.setActivationPolicy(.accessory)  // 无 Dock 图标
   ↓
3. setupWindow()                           // 创建毛玻璃浮动窗口
   ↓
4. setupStatusItem()                       // 创建菜单栏图标和菜单
   ↓
5. setupHotKey()                           // 注册全局热键 Ctrl+Option+S
   ↓
6. ContentLoader.loadIndex()               // 读取 index.json 到内存
   ↓
7. showHomeView()                          // 显示首页
   ↓
8. showWindow()                            // 显示窗口（首次启动显示）
```

### 4.2 搜索流程

```
用户在搜索框输入字符
   ↓
AppDelegate.searchTextDidChange(text)
   ↓
SearchService.search(text, in: contentLoader.index)
   ↓
返回 [ContentType: [ContentItem]]（分组结果）
   ↓
SearchResultView 展示结果（分组标题 + 卡片列表）
   ↓
用户点击某个结果卡片
   ↓
AppDelegate.openDetail(item)
   ↓
ContentLoader.loadDetail(id: item.id)（查缓存，没有则读文件）
   ↓
DetailView 展示详情
   ↓
FavoritesService.addRecentItem(id: item.id)（记录最近查看）
```

### 4.3 收藏流程

```
用户在详情页点击收藏按钮
   ↓
FavoritesService.toggleFavorite(id: item.id)
   ↓
更新按钮状态（已收藏/未收藏）
   ↓
首页收藏列表更新（下次显示首页时刷新）
```

### 4.4 公式计算器流程

```
用户打开公式详情
   ↓
CalculatorView 显示输入框（根据 FormulaDetail.calculator 配置）
   ↓
用户输入数值，选择单位
   ↓
CalculatorView 转换为标准单位值
   ↓
CalculatorService.calculate(formulaId: id, inputs: values)
   ↓
返回计算结果
   ↓
CalculatorView 显示结果（带单位）
```

### 4.5 URL Scheme 唤起流程

```
其他应用调用 nexus-spicenest://search?q=.tran
   ↓
application(_:open:) 收到 URL
   ↓
NXURLScheme.parse(url) → (action: "search", params: ["q": ".tran"])
   ↓
showWindow()  // 先显示窗口
   ↓
switch action:
  case "search": performSearch(q)  // 设置搜索框文本并执行搜索
  case "open": openDetail(id)      // 打开指定内容详情
  default: break                    // 仅显示窗口
```

### 4.6 跨应用跳转流程（跳 KeyHub）

```
用户在详情页点击"查快捷键"按钮
   ↓
NXURLScheme.openApp(appId: "keyhub", action: "search", params: ["q": "ltspice"])
   ↓
系统检测 KeyHub 是否安装
   ↓
已安装 → 唤起 KeyHub 并搜索
未安装 → 提示用户安装 KeyHub
```

---

## 五、内容加载策略

### 5.1 索引预加载

- 应用启动时同步读取 `index.json`
- 索引文件预计 < 100KB（200-300 条内容的元数据）
- 读取时间 < 50ms，不影响启动体验
- 索引常驻内存，搜索时直接使用

### 5.2 详情按需加载

- 详情只在用户点击搜索结果时加载
- 加载后存入 NSCache 缓存
- 缓存策略：最近 30 条，内存警告时自动清理
- 指令详情单独文件（内容较长），其他类型用数组文件

### 5.3 无图片资源

- 查询助手不使用截图（不像教程），所有内容是文本和代码
- 因此不需要图片懒加载和压缩
- 拓扑卡片可以考虑后续添加预览图（可选）

---

## 六、性能优化

### 6.1 启动优化

- 索引文件小，同步读取即可，不需要后台线程
- 详情按需加载，启动时不加载
- 无图片资源，无需解压
- 目标启动时间 < 1 秒（菜单栏应用）

### 6.2 搜索性能

- 内存搜索，200-300 条数据，单次搜索 < 10ms
- 实时搜索使用 100ms 节流（debounce），避免输入过程中频繁搜索
- 搜索结果缓存（相同关键词不重复搜索）

### 6.3 内存优化

- 详情使用 NSCache，自动清理
- 无大图资源
- 目标内存占用 < 50MB（空闲时）

### 6.4 UI 流畅度

- 卡片视图复用（类似 UITableView 的复用机制，或用 NSTableView/NSCollectionView）
- 搜索结果列表使用 NSCollectionView 或自定义复用视图
- 避免在主线程做文件 IO（详情加载可以放后台线程，完成后回主线程更新 UI）

---

## 七、错误处理

### 7.1 内容加载失败

- index.json 加载失败：显示错误提示"内容加载失败，请重新安装应用"，提供退出按钮
- 详情文件加载失败：详情页显示"内容加载失败"，提供重试按钮
- JSON 解析失败：记录错误日志，跳过该条内容，不影响其他内容

### 7.2 搜索异常

- 空关键词：显示首页（收藏 + 历史 + 快速分类）
- 无搜索结果：显示空状态提示"没有找到相关内容"，建议检查拼写或尝试其他关键词

### 7.3 计算器异常

- 输入非数字：忽略输入，保持上次结果
- 输入为 0 导致除零：显示"输入无效"提示
- 公式 id 未找到：显示"计算器配置错误"

### 7.4 URL Scheme 异常

- URL 格式错误：忽略，仅显示窗口
- action 未识别：仅显示窗口
- 参数缺失：使用默认行为（如 search 无 q 参数则显示搜索框）

### 7.5 跨应用跳转失败

- 目标应用未安装：提示"未检测到 KeyHub，是否前往下载？"，提供下载链接
- 跳转失败：提示"无法打开 KeyHub，请检查是否已正确安装"

---

## 八、关键设计决策

### 8.1 AppKit 而非 SwiftUI

**原因：**
- 参考 KeyHub 的成功实践，团队已有 AppKit 经验
- 浮动窗口、毛玻璃、自定义卡片视图在 AppKit 中控制更精细
- SwiftUI 在 macOS 上对某些高级特性（如自定义窗口样式、精确的视图动画）支持不够完善
- 无 Xcode 项目，纯代码 + swiftc 编译，AppKit 更直接

### 8.2 AppState 单例集中管理状态，AppDelegate 只做协调

**原因：**
- 应用规模小（一个窗口，首页+搜索结果+详情页三级），但状态和生命周期应该分离
- AppState 单例集中管理业务状态（当前页面、搜索关键词、选中内容），便于状态追踪和调试
- AppDelegate 只做生命周期管理、窗口管理、页面路由协调，不持有业务状态，符合单一职责
- 不引入 ViewModel/Coordinator 等额外抽象，保持简单
- 参考 CODE_STANDARDS 第五章"状态集中管理"约定
- 应用规模扩大后再考虑更复杂的状态管理方案

### 8.3 内存搜索而非 SQLite/全文搜索引擎

**原因：**
- 内容总量 200-300 条，全部加载到内存也只有几百 KB
- 简单的字符串匹配 + 标签匹配足够
- 零依赖，符合 Nexus 规范
- 搜索速度 < 10ms，用户无感知

### 8.4 公式计算器硬编码而非通用表达式解析

**原因：**
- 常用公式数量有限（25-30个），硬编码可维护
- 通用表达式解析器需要引入第三方库或自己写，增加复杂度和安全风险
- 硬编码的计算结果更准确、更可控
- 新增公式只需添加一个函数 + 在 JSON 中配置

### 8.5 JSON 而非 Markdown 存储内容

**原因：**
- SpiceNest 的内容是结构化的（参数有典型值/影响/示例，错误有原因/解决方案），JSON 更适合
- KeyHub 用 Markdown 是因为快捷键数据是简单的键值对表格
- JSON 配合 Swift Codable，类型安全，解析简单
- 内容创作者可以用任何 JSON 编辑器编辑，或后续做一个可视化编辑器

---

## 九、版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v0.1 | 2026-08-27 | 初始技术架构（教程导向，SwiftUI，侧边栏导航） |
| v0.2 | 2026-08-27 | 重写为查询助手架构（AppKit，搜索驱动，JSON内容，六大内容库） |
| v0.4 | 2026-08-27 | DOC_REVIEW 修订：8.2 决策从"单例 AppDelegate 管状态"改为"AppState 单例管状态，AppDelegate 只做协调"；3.2/3.3 Service 补充协议驱动约定 |

---

*SpiceNest 技术架构 · 简单、高效、可维护*
