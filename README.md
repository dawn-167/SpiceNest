# SpiceNest · LTspice 参考助手

> 随时随地可查的 LTspice 参考助手——全局热键一按就出，输入关键词秒出结果，查完就走。
> 新功能开发从 [ROADMAP.md](ROADMAP.md) 开始。

---

## 📚 文档导航

| 文档 | 用途 | 适合谁 |
|------|------|--------|
| [SPECIFICATION.md](SPECIFICATION.md) | **产品规格**（定位/功能/数据模型/技术架构） | 需要深入了解产品的开发者 |
| [ROADMAP.md](ROADMAP.md) | **开发路线图**（分阶段计划/优先级） | 规划开发进度 |
| [CHECKLIST.md](CHECKLIST.md) | **发布检查清单** | 发布前自检 |
| [docs/architecture.md](docs/architecture.md) | **技术架构**（模块划分/数据流/技术选型） | 技术开发 |
| [docs/ui-design.md](docs/ui-design.md) | **UI 设计规范**（配色/布局/组件/交互） | UI 设计与开发 |
| [docs/content-guide.md](docs/content-guide.md) | **内容编写规范**（指令/参数/错误/公式/技巧/拓扑的编写标准） | 内容创作 |
| [docs/QUALITY_ASSURANCE.md](docs/QUALITY_ASSURANCE.md) | **质量保证规范**（计划执行保证/bug处理流程/回归测试机制） | 所有开发者 |
| [docs/CODE_STANDARDS.md](docs/CODE_STANDARDS.md) | **代码规范与协作指南**（分层架构/单向依赖/多人协作/代码风格） | 所有开发者 |
| [docs/BUG_LOG.md](docs/BUG_LOG.md) | **Bug 记录归档**（开发过程中所有 bug 的发现、根因、修复、回归记录） | 所有开发者 |

> **通用规范**：代码架构、质量保证流程、防错机制的核心规范遵循 Nexus 通用开发规范 [`Nexus/DEVELOPMENT_STANDARDS.md`](file:///Users/dawnli/Documents/Nexus/DEVELOPMENT_STANDARDS.md)，SpiceNest 文档为项目特定补充。
| [content/](content/) | **内容资源**（仿真指令/参数词典/错误库/公式/技巧/拓扑） | 内容管理 |

---

## 🚀 快速了解（30秒）

SpiceNest 是一个 macOS 原生应用，帮你随时查 LTspice 的任何东西。

**与 KeyHub 的区别：**
- **KeyHub**：多软件快捷键速查（"快捷键是什么"）
- **SpiceNest**：LTspice 专属参考助手（"这个怎么用、什么意思、怎么办"）

**六大内容库：**
1. 📋 **仿真指令** — `.tran` `.ac` `.step` 等语法和示例，一键复制
2. 📖 **参数词典** — BJT/MOSFET/二极管/运放等元器件参数含义和典型值
3. ⚠️ **常见错误** — 报错了查一下就知道原因和解决方案
4. 🧮 **公式速算** — RC截止频率、运放增益等，内置计算器直接算
5. 💡 **操作技巧** — 怎么加第三方模型、怎么导出波形等，3-5步说清楚
6. 🔌 **电路拓扑** — 反相放大器、Buck降压等，公式+取值建议+最小片段

**核心体验：**
- 全局热键 `Ctrl+Option+S` 唤出，查完自动隐藏
- 打开就是搜索框，输入关键词实时出结果
- 所有指令、代码、公式一键复制
- 全部本地存储，不联网，不收集数据

---

## 🏗️ 项目结构

> **注意**：以下为规划中的完整结构。当前处于纯文档阶段，`Sources/`、`Resources/`、`build.sh`、`nexus.json`、`Info.plist`、`CHANGELOG.md` 尚未创建，将在 MVP 开发第 1 步从 Nexus 模板补齐。

```
SpiceNest/
├── README.md              # 本文件（总览导航）
├── SPECIFICATION.md       # 产品规格说明
├── ROADMAP.md             # 开发路线图
├── CHECKLIST.md           # 发布检查清单
├── docs/                  # 开发文档
│   ├── architecture.md    # 技术架构
│   ├── ui-design.md       # UI 设计规范
│   ├── content-guide.md   # 内容编写规范
│   └── DEVELOPMENT_PLAN.md # MVP 开发计划
├── content/               # 内容资源（开发期源文件）
│   ├── commands/          # 仿真指令
│   ├── parameters/        # 参数词典
│   ├── errors/            # 错误库
│   ├── formulas/          # 公式速算
│   ├── tips/              # 操作技巧
│   ├── topologies/        # 电路拓扑
│   └── images/            # 预留：拓扑预览图（可选，MVP 阶段不用）
├── Resources/             # 应用资源（编译时打包）【规划中】
│   └── content/           # 内容 JSON 文件
├── Sources/               # 源代码【规划中】
│   ├── main.swift
│   ├── App/
│   ├── Models/
│   ├── Views/
│   ├── Services/
│   └── Common/            # Nexus CommonKit 共享组件
├── build.sh               # 构建脚本【规划中】
├── nexus.json             # Nexus 元宇宙配置【规划中】
├── Info.plist             # 应用配置【规划中】
└── CHANGELOG.md           # 更新日志【规划中】
```

---

## 🔗 与 Nexus 元宇宙的关系

SpiceNest 是 Nexus 元宇宙生态中**工具类**软件的一员，与 KeyHub 并列。

| 应用 | 标识 | 分类 | URL Scheme |
|------|------|------|------------|
| KeyHub | keyhub | tool | `nexus-keyhub://` |
| SpiceNest | spicenest | tool | `nexus-spicenest://` |

遵循 Nexus 规范：
- 统一的设计语言和交互规范
- 支持软件间互相打开（从 KeyHub 可以打开 SpiceNest，反之亦然）
- 统一的元数据和配置格式（`nexus.json`）
- 隐私保护（不收集用户数据）

详细规范见 [Nexus 开发中心](file:///Users/dawnli/Documents/Nexus/README.md)。

---

## 📝 版本信息

- 当前版本：0.3（规划阶段，PLAN_REVIEW 修订后）
- 创建日期：2026-08-27
- 维护：SpiceNest 项目

---

*SpiceNest · 随时随地，一搜即得*
