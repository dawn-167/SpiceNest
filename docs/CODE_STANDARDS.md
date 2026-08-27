# SpiceNest 代码规范与协作指南

> 版本：0.4 | 日期：2026-08-27
> 目的：保证代码高度内聚、结构清晰、便于阅读和修改，支持多人协作开发。
> 核心原则：**严格分层、单向依赖、职责单一、接口先行。**
>
> **规范来源**：核心代码规范遵循 Nexus 通用开发规范 [`Nexus/DEVELOPMENT_STANDARDS.md`](file:///Users/dawnli/Documents/Nexus/DEVELOPMENT_STANDARDS.md)（第一部分：代码规范）。本文档为 SpiceNest 项目特定补充，包含项目特定的目录结构、数据模型和 UI 组件约定。

---

## 一、五层架构

所有代码严格分为 5 层，每层只做一件事。

```
Sources/
├── App/          ← 应用层：生命周期、窗口管理、页面路由（只协调，不写业务逻辑）
├── Models/       ← 数据层：纯数据结构，零逻辑
├── Services/     ← 业务层：核心业务逻辑，无 UI 依赖
├── Views/        ← 展示层：UI 渲染 + 用户输入转发，不做业务判断
└── Common/       ← Nexus 共享组件，只读不改
```

### 1.1 App 层（应用层）

**职责：**
- 应用生命周期管理（`AppDelegate`）
- 窗口创建与管理
- 页面路由（首页 ↔ 搜索结果 ↔ 详情页）
- 全局热键注册
- 菜单栏管理
- URL Scheme 接收与分发
- 各 Service 的初始化与持有

**禁止：**
- ❌ 不写业务逻辑（搜索算法、内容加载、计算器计算都不在这里）
- ❌ 不直接操作 UI 控件的具体内容（只做容器和切换）
- ❌ 不直接读写 JSON 文件

**文件：**
- `AppDelegate.swift` — 应用主体
- `AppState.swift` — 全局应用状态（当前页面、搜索关键词等）
- `WindowManager.swift` — 窗口管理（可选，逻辑多了就拆）

### 1.2 Models 层（数据层）

**职责：**
- 定义所有数据结构（`ContentItem`、`CommandDetail`、`SearchResult` 等）
- 纯 `struct` / `enum`，遵循 `Codable`
- 只存数据，不写方法（除了简单的计算属性，如格式化显示）

**禁止：**
- ❌ 不 import 任何业务层或 UI 层类型
- ❌ 不写涉及文件操作、网络、UI 的逻辑
- ❌ 不持有引用类型的属性（尽量用值类型）

**文件：** 每个主要类型一个文件，文件名 = 类型名。

### 1.3 Services 层（业务层）

**职责：**
- 核心业务逻辑：内容加载、搜索匹配、收藏管理、计算器求值、历史记录
- 所有 Service 定义 `protocol` 接口，具体实现遵循
- 无 UI 依赖，可独立测试（可以在命令行里跑测试）

**禁止：**
- ❌ 不 import 任何 View 类型（`NSView`、`NSViewController` 等都不行）
- ❌ 不直接操作 UI
- ❌ 不持有 App 层的引用（通过 delegate/closure 回调）

**文件：**
- `ContentLoader.swift` — 内容加载（JSON 读取、索引构建）
- `SearchService.swift` — 搜索服务（模糊匹配、分组、排序）
- `FavoritesService.swift` — 收藏与历史管理
- `CalculatorService.swift` — 公式计算器求值
- 每个 Service 对应一个 `protocol` 定义（可以放在同文件顶部，或单独 `Protocols/` 目录）

### 1.4 Views 层（展示层）

**职责：**
- UI 渲染：根据传入的数据绘制界面
- 用户输入转发：用户操作通过 delegate/closure 上报给 App 层（统一走 App 层路由，不直接调 Service）
- 纯展示逻辑：格式化显示、动画、布局

**禁止：**
- ❌ 不做业务判断（「这个搜索结果该怎么排序」不在 View 里决定）
- ❌ 不直接读写文件或 UserDefaults（通过 Service）
- ❌ 不持有业务状态（搜索关键词、当前选中项都在 AppState 里）
- ❌ 不跨页面直接操作其他 View（通过 App 层路由）

**文件：**
- `HomeView.swift` — 首页（搜索框 + 收藏 + 历史 + 分类）
- `SearchResultView.swift` — 搜索结果列表
- `ContentCardView.swift` — 内容卡片（通用，适配所有类型）
- `DetailView.swift` — 详情页容器
- `SearchFieldView.swift` — 搜索框
- `CalculatorView.swift` — 公式计算器组件
- `CopyableCodeView.swift` — 可复制代码块
- `CommonViews.swift` — 辅助视图（分隔线、标签等）

### 1.5 Common 层（Nexus 共享组件）

**职责：**
- Nexus CommonKit 共享组件：热键管理、URL Scheme、窗口样式、菜单栏等
- 从 Nexus 模板引入，按需使用

**强制规则：**
- ✅ 只读，不修改原始文件
- ✅ 需要扩展时，在自己的代码里写 wrapper，不改 Common 源码
- ✅ 引入前确认 Nexus 规范允许

---

## 二、单向依赖规则（强制）

### 2.1 允许的依赖方向

```
App ──→ Views ──→ Services ──→ Models
 │         │           │
 └─────────┴───────────┘
 （App 可以引用所有层，但只做协调）

Common ← 所有层都可以引用（工具类）
```

### 2.2 绝对禁止的依赖

| 禁止 | 原因 |
|------|------|
| Services import Views | 业务层不能依赖 UI，否则无法独立测试 |
| Models import Services/Views | 数据层最底层，谁都不依赖 |
| Views 直接读写文件/UserDefaults | 数据操作必须走 Service |
| Views 持有业务状态 | 状态集中管理，避免状态不一致 |
| 跨层直接修改其他层的内部状态 | 必须通过公开接口/方法 |
| 修改 Common 目录下的文件 | Nexus 共享组件只读 |

### 2.3 依赖检查

每次提交代码前自查：
- [ ] 新增的 import 是否符合依赖方向
- [ ] 是否有 Service 里出现了 NSView/NSWindow 等 UI 类型
- [ ] 是否有 View 里直接读写了文件或 UserDefaults
- [ ] 是否有 Model 里出现了业务逻辑方法

---

## 三、文件与类型规范

### 3.1 一个文件 = 一个主要类型

- 文件名 = 主要类型名（`SearchService.swift` 里主要类型就是 `SearchService`）
- 允许在同文件里定义相关的小类型（如 `SearchResult` 可以和 `SearchService` 同文件）
- 但小类型不超过 2 个，超过就拆文件

### 3.2 文件长度限制

- 单个文件不超过 **300 行**
- 超过必须拆分：
  - 用 `extension` 拆到同文件的不同 MARK 区（如果逻辑相关）
  - 拆成子类型或辅助类型（如果职责不同）
  - 拆成多个文件（如果完全独立）

### 3.3 MARK 分区强制

每个文件必须用 `// MARK: -` 分区，标准分区顺序：

```swift
// MARK: - 类型定义 / Protocol
// MARK: - 属性
// MARK: - 初始化
// MARK: - 公开方法
// MARK: - 私有方法
// MARK: - 代理 / 回调
// MARK: - 计算属性
// MARK: - 扩展 / 辅助类型
```

不允许一个方法上面没有 MARK 分区（除非文件很短，不超过 50 行）。

### 3.4 类型长度限制

- 单个类型（class/struct）不超过 **200 行**
- 超过说明职责太多，需要拆分

---

## 四、协议驱动接口设计

### 4.1 为什么用 Protocol

- **多人协作**：A 写 Service 实现，B 写 View，只需要约定 protocol 就能并行开发
- **可测试**：测试时用 mock 实现，不依赖真实数据/文件
- **可替换**：将来换实现（如从本地搜索换成 SQLite）只改实现类，调用方零改动
- **接口清晰**：protocol 强制定义公开接口，避免实现细节泄露

### 4.2 哪些必须用 Protocol

- 所有 Service 层类型必须定义 protocol
- 跨层调用的接口必须用 protocol
- 可能有多种实现的类型必须用 protocol

### 4.3 Protocol 定义规范

```swift
// 文件名：SearchServiceProtocol.swift（或放在 SearchService.swift 顶部）

protocol SearchServiceProtocol {
    /// 执行搜索，返回按类型分组的结果
    /// - Parameter query: 搜索关键词
    /// - Returns: 分组后的搜索结果列表
    func search(query: String) -> [SearchResultGroup]

    /// 获取最近搜索记录
    /// - Returns: 最近搜索关键词列表（最新的在前）
    func recentQueries() -> [String]

    /// 清除搜索历史
    func clearRecentQueries()
}
```

规则：
- protocol 名 = 类型名 + `Protocol`（如 `SearchServiceProtocol`）
- 每个方法必须有注释（说明做什么、参数、返回值）
- 不暴露实现细节（如「从 JSON 文件加载」不写在接口里，只写「加载内容」）
- 方法尽量小而专，不做多个不相关的事

### 4.4 实现类规范

```swift
class SearchService: SearchServiceProtocol {
    // 实现...
}
```

- 实现类名和 protocol 去掉 `Protocol` 后缀一致
- 必须实现 protocol 的所有方法（编译器会强制）
- 可以有额外的私有方法和属性，但不暴露给调用方

---

## 五、状态集中管理

### 5.1 全局状态在 AppState

所有应用级状态集中在 `AppState`（或 `AppDelegate`）里：

```swift
class AppState {
    // 当前页面
    enum Page { case home, searchResults, detail }
    var currentPage: Page = .home

    // 当前搜索关键词
    var currentQuery: String = ""

    // 当前选中的内容（详情页用）
    var selectedContent: ContentItem?

    // 单例
    static let shared = AppState()
}
```

### 5.2 View 不持有业务状态

- View 只接收数据渲染，不自己存「搜索关键词」「当前选中项」等业务状态
- 用户操作（输入文字、点击结果）通过 delegate/closure 上报给 App 层
- App 层更新 AppState，然后通知 View 重新渲染

### 5.3 状态变更通知

- 状态变更后，通过以下方式通知 View：
  - delegate 方法（如 `appStateDidChange(_:)`）
  - closure 回调
  - Combine / NotificationCenter（项目复杂时再引入，MVP 阶段不用）
- 不允许 View 轮询状态

---

## 六、多人协作规则

### 6.1 接口先行

新增模块的开发顺序：
1. 先写 protocol 接口定义
2. 团队评审接口（方法名、参数、返回值是否合理）
3. 接口确认后，实现方和调用方并行开发
4. 联调时只对接接口，不关心对方内部实现

### 6.2 不跨层修改

- 写 UI 的人不改 Service 层代码
- 写 Service 的人不改 Model 层定义
- 写业务逻辑的人不改 View 布局
- 需要其他层配合时，通过接口变更申请，由对应负责人修改

### 6.3 公共接口变更必须通知

- 修改了任何 protocol 的方法签名（增删参数、改返回值、改方法名）
- 必须通知所有调用方，同步修改
- 不允许「偷偷改接口，让别人编译报错才发现」

### 6.4 文件归属

- 每个文件有明确的模块归属（从目录结构就能看出来）
- 修改不属于自己模块的文件时，必须先和该模块负责人沟通
- 多人协作时，文件头部注释写明作者/负责人（单人开发时可不写）

### 6.5 Git 提交规范（如果用 Git）

- 一次提交只做一件事（修 bug / 加功能 / 重构，不混在一起）
- 提交信息格式：`[模块] 简短描述`，如 `[Search] 修复搜索结果排序错误`
- 提交前必须编译通过、无警告
- 提交前跑一遍当前阶段的回归测试（MVP 阶段以手动验证代替自动化测试）

---

## 七、代码风格统一

### 7.1 命名规范

| 类型 | 规则 | 示例 |
|------|------|------|
| 类型名（class/struct/enum/protocol） | 大驼峰 | `SearchService`、`ContentItem` |
| 协议名 | 类型名 + Protocol | `SearchServiceProtocol` |
| 方法名 | 小驼峰，动词开头 | `search(query:)`、`loadContent()` |
| 变量/常量/属性 | 小驼峰 | `currentQuery`、`searchResults` |
| 全局常量 | k 前缀 + 大驼峰（项目内统一） | `kMaxSearchResults` |
| 枚举值 | 小驼峰 | `case home`、`case searchResults` |
| 文件名 | 和主要类型名一致 | `SearchService.swift` |

**禁止：**
- ❌ 拼音命名（用英文）
- ❌ 单字母变量名（除了循环变量 i/j/k、数学公式里的 R/C/L）
- ❌ 缩写不明确（`btn` 可以，`svc` 不行，写全称 `viewController`）

### 7.2 注释规范

**必须有注释的：**
- 所有 public 方法（说明做什么、参数、返回值）
- 所有 protocol 方法
- 非显而易见的业务逻辑（为什么这样写，而不是那样写）
- 魔法数字（为什么是 0.12，而不是 0.15）
- 临时 workaround（为什么需要这个 hack，什么时候可以去掉）

**不需要注释的：**
- 显而易见的代码（`let count = items.count` 不需要注释）
- 标准 UI 搭建代码

**注释格式：**
```swift
/// 执行搜索，返回按类型分组的结果
/// - Parameter query: 搜索关键词（空字符串返回空结果）
/// - Returns: 分组后的搜索结果列表，按相关度排序
func search(query: String) -> [SearchResultGroup]
```

### 7.3 格式规范

- 缩进：4 空格，不用 tab
- 行宽：不超过 120 字符（超过就换行）
- 空行：方法之间空 1 行，逻辑块之间空 1 行，不连续空 2 行以上
- 闭包：尾随闭包语法，参数名有意义
- 闭包嵌套：不超过 3 层，超过就拆函数

### 7.4 可选值处理

- 优先用 `if let` / `guard let` 安全解包
- 禁止滥用 `!` 强制解包（除非能 100% 确定不为 nil，且有注释说明）
- `guard let` 用于提前退出（失败就 return）
- `if let` 用于有值才继续的逻辑

---

## 八、错误处理规范

### 8.1 内容加载错误

- JSON 文件不存在 → 显示友好错误提示，不崩溃
- JSON 解析失败 → 跳过该条内容，记录日志，不影响其他内容
- 索引构建失败 → 显示「内容加载失败」，提供重试按钮

### 8.2 搜索错误

- 空关键词 → 显示首页（收藏 + 历史），不报错
- 无搜索结果 → 显示空状态提示，建议检查拼写
- 搜索过程中不崩溃（任何输入都要能处理）

### 8.3 计算器错误

- 输入非数字 → 忽略输入，保持上次结果
- 除零 → 显示「输入无效」，不崩溃
- 公式 id 未找到 → 显示「计算器配置错误」，记录日志

### 8.4 通用原则

- 不允许应用崩溃（所有可能失败的地方都要有错误处理）
- 错误提示用户能看懂（不显示技术术语，如「NSCocoaErrorDomain 256」）
- 错误日志记录详细信息（便于调试），但不展示给用户

---

## 九、代码审查清单（提交前自查）

每次提交代码前，逐条自查：

### 架构与分层
- [ ] 新增的 import 符合单向依赖规则
- [ ] Service 里没有 UI 类型（NSView/NSWindow/NSViewController）
- [ ] View 里没有直接读写文件或 UserDefaults
- [ ] View 没有持有业务状态
- [ ] 没有修改 Common 目录下的文件

### 代码质量
- [ ] 单个文件不超过 300 行
- [ ] 单个类型不超过 200 行
- [ ] 有 MARK 分区
- [ ] public 方法有注释
- [ ] 没有强制解包 `!`（除非有注释说明）
- [ ] 闭包嵌套不超过 3 层
- [ ] 命名清晰，无拼音，无无意义缩写

### 功能与安全
- [ ] 编译通过，无警告
- [ ] 实际运行过，应用能正常启动
- [ ] 修改涉及的功能路径手动测试过
- [ ] 边界条件测试过（空输入、极值）
- [ ] 没有硬编码的敏感信息（路径、密钥等）
- [ ] 没有内存泄漏（闭包用 weak self）

### 协作
- [ ] 一次提交只做一件事
- [ ] 如果改了 protocol，已通知所有调用方
- [ ] 如果改了不属于自己模块的文件，已和负责人沟通

---

## 十、版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v0.4 | 2026-08-27 | DOC_REVIEW 修订：版本号统一 v0.x，View 上报统一走 App 层，全局常量命名指定 k 前缀，Git 提交注明 MVP 阶段手动验证 |
| v0.3 | 2026-08-27 | 初始代码规范与协作指南 |

---

*SpiceNest 代码规范 · 分层清晰、职责单一、接口先行、便于协作*
