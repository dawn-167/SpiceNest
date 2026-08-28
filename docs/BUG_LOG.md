# SpiceNest Bug 修复归档

> 用途：记录已按 QA 五步流程（复现→定位→修复→验证→预防）处理完的 bug 修复归档
> 与 [PROBLEM_LOG.md](PROBLEM_LOG.md) 的区别：PROBLEM_LOG 记录待处理问题，本文件记录已修复归档的 bug
> 依据：ERROR_PREVENTION.md 第四章"Bug 修复五步流程"

---

## BUG-001：详情页"复制全部"只复制第一条内容

- **对应问题**：P-008
- **修复日期**：2026-08-28
- **严重程度**：P1

### 1. 复现
- 打开任意多语法指令的详情页（如 .tran，有 4 条语法）
- 点击底部"复制全部"按钮
- 粘贴到文本编辑器，发现只有第一条语法

### 2. 定位
- 文件：`Sources/App/AppDelegate.swift`
- 方法：`copyItem(_:)`
- 根因：command 类型只取 `detail.syntax.first`，error 类型只取 `detail.copyableCommands.first`，按钮文案是"复制全部"但实现只取第一条

### 3. 修复
- command 类型：`detail.syntax.joined(separator: "\n")`
- error 类型：`detail.copyableCommands.joined(separator: "\n")`
- 无内容时退回 title

### 4. 验证
- 编译零警告
- .tran 详情页点击"复制全部"，粘贴后包含全部 4 条语法
- 错误详情页点击"复制全部"，粘贴后包含全部可复制指令

### 5. 预防
- 按钮文案与实现必须一致，"全部"意味着拼接所有
- 后续新增内容类型时，copyItem 必须覆盖所有类型的"全部"语义

---

## BUG-002：搜索结果页按 Enter 不打开选中项，而是重新搜索

- **对应问题**：P-009
- **修复日期**：2026-08-28
- **严重程度**：P1

### 1. 复现
- 搜索任意关键词（如 "tran"）
- 用 ↓ 键选中某条结果
- 按 Enter 键
- 预期：打开选中项的详情页
- 实际：触发重新搜索，停留在搜索结果页

### 2. 定位
- 文件：`Sources/Views/SearchResultView.swift`
- 方法：`searchField.onEnter` 回调
- 根因：Enter 直接调用 `onSearchEnter?(text)`（重新搜索），没有检查是否有选中项；`selectedItem` 属性存在但无人调用

### 3. 修复
- 修改 `searchField.onEnter` 回调：
  - 若有选中项（`selectedItem != nil`），调用 `onItemClick?(selected)`
  - 否则回退到 `onSearchEnter?(text)`

### 4. 验证
- 编译零警告
- 搜索后用 ↓ 选中，按 Enter 正确打开详情页
- 无选中项时按 Enter 仍可重新搜索
- Esc 分级返回正常

### 5. 预防
- 键盘交互必须完整闭环：↑↓ 选择 → Enter 打开 → Esc 返回
- 新增键盘操作时，必须验证与现有操作的协同

---

## BUG-003：CopyableCodeView 代码块文字不显示

- **对应问题**：无（开发中发现）
- **修复日期**：2026-08-28
- **严重程度**：P1

### 1. 复现
- 打开任意指令详情页（如 .tran）
- 语法部分的代码块显示为纯黑色背景，无文字

### 2. 定位
- 文件：`Sources/Views/CopyableCodeView.swift`
- 根因：NSTextView 包装在 NSScrollView 中，NSScrollView 的 documentView 使用 Auto Layout 约束导致 frame 为 0，文字无法渲染

### 3. 修复
- 去掉 NSScrollView 包装，直接使用 NSTextView
- NSTextView 设置约束填满 CopyableCodeView

### 4. 验证
- 编译零警告
- .tran 详情页 4 个代码块均正确显示语法文字
- 错误详情页可复制指令代码块正确显示
- 复制按钮功能正常

### 5. 预防
- NSScrollView 的 documentView 不适合用 Auto Layout，应使用 frame 或 autoresizingMask
- 简单文本展示优先用 NSTextView 直接布局，避免不必要的 ScrollView 嵌套

---

## BUG-004：内容详情 JSON 缺 related 字段导致关联内容无法渲染

- **对应问题**：P-004
- **修复日期**：2026-08-28
- **严重程度**：P1

### 1. 复现
- 查看任意指令或错误的详情 JSON
- 发现没有 related 字段，但 index.json 中有 related

### 2. 定位
- 文件：`Resources/content/commands/*.json`、`Resources/content/errors/common-errors.json`
- 根因：创建详情 JSON 时遗漏了 related 字段；CommandDetail 和 ErrorDetail 模型也没有 related 属性

### 3. 修复
- 为 10 个指令、10 个错误的详情 JSON 补充 related 字段（与 index.json 一致）
- CommandDetail 和 ErrorDetail 模型添加 `let related: [String]` 属性
- 清理 6 条 related 死链（param-bjt-is、param-mosfet-vto、command-include 等尚未创建的内容）

### 4. 验证
- `scripts/validate_content.sh` 全部通过（20 个唯一 id，无 related 死链）
- 详情页"相关内容"区正确渲染，可点击跳转

### 5. 预防
- 新增内容时，index.json 和详情 JSON 的 related 必须同步
- `validate_content.sh` 自动检查 related 死链，每次内容改动后必须运行

---

## BUG-005：滚轮快速滚动时多个卡片同时高亮

- **对应问题**：S-14（UI_IMPROVEMENTS）
- **修复日期**：2026-08-28
- **严重程度**：P1

### 1. 复现
- 搜索关键词返回多条结果
- 快速滚动滚轮
- 预期：只有鼠标下方的卡片高亮
- 实际：多个卡片同时高亮（NSTrackingArea 丢失 mouseExited 事件）

### 2. 定位
- 文件：`Sources/Views/SearchResultView.swift`
- 根因：仅依赖 NSTrackingArea + mouseEntered/Exited，滚轮快速滚动时 NSTrackingArea 可能丢失 mouseExited 事件，导致多个卡片保持高亮状态

### 3. 修复
- 添加全局 mouseMoved 监听兜底方案：
  - 启动 80ms Timer（.common runloop mode）
  - Timer 回调中获取当前鼠标位置，检查哪个卡片在鼠标下方
  - 更新所有卡片的悬停状态（`applyHoverState(_:)`）
  - 键盘选中的卡片保持高亮，不被悬停逻辑覆盖
- 视图不在窗口中或隐藏时自动停止 Timer

### 4. 验证
- 编译零警告
- 快速滚动滚轮，只有鼠标下方的卡片高亮
- 键盘 ↑↓ 选择的卡片保持高亮
- 离开搜索结果页后 Timer 自动停止

### 5. 预防
- NSTrackingArea 在滚动场景下不可靠，必须配合全局监听兜底
- 此方案参考 KeyHub 踩坑记录，已写入 DEVELOPMENT_PLAN 第 5/8 步

---

## 统计

| 严重程度 | 已归档 |
|---------|--------|
| P1 | 5 |
| P2 | 0 |
| **合计** | **5** |

---

*SpiceNest Bug 修复归档 · 复现→定位→修复→验证→预防，五步闭环*
