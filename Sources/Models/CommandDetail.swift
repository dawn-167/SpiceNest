import Foundation

// MARK: - 指令详情

/// 仿真指令详情，如 .tran、.ac、.op 等
struct CommandDetail: Codable, Identifiable {
    let id: String
    let syntax: [String]        // 语法形式（支持多种）
    let parameters: [ParamDef]  // 参数说明
    let examples: [Example]     // 示例
    let notes: [String]         // 注意事项
    let related: [String]       // 关联内容的 id 列表
}

// MARK: - 参数定义

/// 指令参数定义
struct ParamDef: Codable {
    let name: String            // 参数名
    let description: String     // 说明
    let required: Bool          // 是否必填
    let defaultValue: String?   // 默认值
}

// MARK: - 示例

/// 指令使用示例
struct Example: Codable {
    let code: String            // 示例代码
    let description: String     // 说明
}
