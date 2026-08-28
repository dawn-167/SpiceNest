# Changelog

All notable changes to SpiceNest will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2026-08-29

### Fixed
- P-050：拉伸窗口导致页面移动 → 窗口锁定 520×640（min=max），宽度 560→520
- P-051：卡片底部白线 → 高光线按图层几何方向定位到顶部；同步修正渐变层颜色顺序
- P-053：滚动后悬停卡片一直亮 → 监听滚动边界变化即时重算悬停 + applyHoverState 幂等守卫
- P-056：详情页代码块比正文宽 → 文字与代码块共用同一内容列宽
- P-057：搜索结果页白茫茫、卡片贴太近 → 组间距 16pt、卡片间距 8pt、底部留白
- P-058：收藏卡片悬停上浮被裁剪 → 收藏区滚动视图增加内边距预留动效空间
- P-059：窗口首次布局被内容撑宽（701/934pt）→ 容器定宽锚点 520 + 最近查看行等宽约束

### Changed
- P-052：所有可点击元素统一小手光标（新增 HandCursorButton，覆盖详情页/搜索页/搜索框全部按钮）
- P-054：删除详情页右下角"复制全部"与代码块复制按钮（代码文字保持可选中复制）
- P-055："查快捷键"按钮重做为琥珀色胶囊，移至详情页头部行右侧

## [1.1.0] - 2026-08-28

### Added
- 最近查看：首页收藏区下方紧凑胶囊行，记录最近 8 条查看（UserDefaults 持久化、去重置顶），点击直达详情
- 粘贴报错直达搜索：内容索引新增 `errorPattern` 字段（10 条错误补齐），粘贴 "Node N005 is floating" 可命中 "Node ... is floating"
- 搜索回归用例支持 `!id` 反向断言（结果不应包含该条），新增 8 条用例（共 41 条）
- 内容校验新增：error 类型必须带 errorPattern、index.json 与详情文件 errorPattern 一致性检查
- `NXDynamicColor(light:dark:)` 动态色工具（CommonViews）

### Fixed
- P-042：收藏卡片复制按钮点了没反应（回调未接线）
- P-043："查快捷键"硬编码 `/Applications/KeyHub.app` → 改 `NXURLScheme` 检测与唤起，未安装 KeyHub 时隐藏按钮
- P-044：Esc 只在搜索页生效 → 首页 Esc 隐藏窗口，详情页 Esc 返回
- P-045："tran" 误命中 ".dc" 的 transfer 标签 → ASCII 词边界匹配（".op" 也不再误命中 ".options"）
- P-047：深色模式下卡片/搜索框硬编码白色刺眼 → 动态色适配，运行时切换外观即时刷新
- P-048：errorPattern 数据闲置、粘贴报错搜不到 → 双向通配匹配（权重 80）

### Changed
- P-046：删除死代码 `renderGenericDetail`（DetailView）与 `categoryTypes`（HomeView）
- 搜索权重表新增 errorPattern = 80（介于标题精确 100 与标题包含 50 之间）
- 搜索/详情堆栈统一使用 CommonViews 共享的 `FlippedStackView`

## [1.0.0] - 2026-08-28

### Added
- MVP 完整功能：首页 / 搜索结果页 / 详情页三页流转
- 20 条内容数据（10 条仿真指令 + 10 条常见错误）
- 智能搜索（多字段权重匹配，标题/中文标题/tags/摘要）
- 全局热键 Ctrl+Option+S 唤出/隐藏窗口
- URL Scheme：`nexus-spicenest://`、`search?q=xxx`、`open?id=xxx`
- 菜单栏状态项（bolt 图标 + Nexus 应用子菜单）
- 毛玻璃浮动窗口（560pt 固定宽度，琥珀色叠加层）
- 收藏功能（UserDefaults 持久化，首页真实收藏列表）
- 详情页关联内容可点击跳转
- 代码块一键复制（复制成功变对勾，2 秒恢复）
- 键盘交互：↑↓ 选择搜索结果，Enter 打开选中项，Esc 分级返回

### Fixed
- P-004：内容详情 JSON 补充 related 字段（10 指令 + 10 错误）
- P-008：详情页"复制全部"只复制第一条 → 拼接全部语法/指令
- P-009：搜索结果页 Enter 不打开选中项 → 有选中项则打开
- P-011：搜索框高度 44pt → 36pt（对齐 ui-design 6.1）
- P-012：窗口默认高度 600pt → 640pt（对齐 ui-design 2.1）
- P-013：卡片图标按类型着色（指令蓝/参数青/错误橙/公式紫/技巧黄/拓扑绿）
- S-08：首页收藏区从占位文本改为真实收藏卡片列表
- S-10：详情页添加"相关内容"区，关联项可点击跳转
- S-14：滚轮滚动悬停状态 Bug 修复（全局 mouseMoved + 80ms Timer 兜底）
- S-15：删除 ContentCardView 死代码 hoverView
- CopyableCodeView：去掉 NSScrollView 包装，修复代码块文字不显示问题
- CommandDetail / ErrorDetail 模型补充 related 字段

### Changed
- 版本号 0.1.0 → 1.0.0（MVP 正式发布）
