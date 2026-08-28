# Changelog

All notable changes to SpiceNest will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
