import Foundation

// MARK: - 内容类型枚举

/// 内容类型，对应六大内容库
enum ContentType: String, Codable, CaseIterable {
    case command     // 仿真指令
    case parameter   // 元器件参数
    case error       // 常见错误
    case formula     // 公式速算
    case tip         // 操作技巧
    case topology    // 电路拓扑

    /// 中文显示名
    var displayName: String {
        switch self {
        case .command: return "仿真指令"
        case .parameter: return "元器件参数"
        case .error: return "常见错误"
        case .formula: return "公式速算"
        case .tip: return "操作技巧"
        case .topology: return "电路拓扑"
        }
    }

    /// SF Symbol 图标名
    var iconName: String {
        switch self {
        case .command: return "chevron.left.forwardslash.chevron.right"
        case .parameter: return "slider.horizontal.3"
        case .error: return "exclamationmark.triangle"
        case .formula: return "function"
        case .tip: return "lightbulb"
        case .topology: return "circle.grid.2x2"
        }
    }
}

// MARK: - 统一内容项

/// 所有内容类型共享的基础字段，搜索时统一检索
struct ContentItem: Codable, Identifiable {
    let id: String              // 唯一标识，如 "command-tran", "param-bjt-is"
    let type: ContentType       // 内容类型
    let title: String           // 标题（英文原名）
    let chineseTitle: String    // 中文译名
    let summary: String         // 一句话摘要，搜索结果展示
    let tags: [String]          // 搜索标签（中英文同义词、缩写）
    let related: [String]       // 关联内容的 id 列表
}
