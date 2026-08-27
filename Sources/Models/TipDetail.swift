import Foundation

// MARK: - 技巧详情

/// 操作技巧详情，如"如何快速测量相位裕度"等
struct TipDetail: Codable {
    let id: String
    let scenario: String        // 适用场景
    let steps: [TipStep]        // 操作步骤
    let copyableCommands: [String] // 可复制指令
    let notes: [String]         // 注意事项
}

// MARK: - 技巧步骤

/// 操作技巧的单个步骤
struct TipStep: Codable {
    let step: Int               // 步骤号
    let description: String     // 说明
    let command: String?        // 该步骤涉及的指令（可选）
}
