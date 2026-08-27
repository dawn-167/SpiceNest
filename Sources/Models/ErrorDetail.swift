import Foundation

// MARK: - 错误详情

/// LTspice 常见错误详情
struct ErrorDetail: Codable {
    let id: String
    let errorPattern: String    // 匹配模式（支持模糊匹配）
    let category: String        // 错误类别（收敛/结构/参数/语法/文件）
    let cause: String           // 原因分析
    let solutions: [String]     // 解决方案（编号列表）
    let copyableCommands: [String] // 可复制的修复指令
}
