import Foundation

// MARK: - 公式详情

/// 公式速算详情，如 RC 截止频率、分压公式等
struct FormulaDetail: Codable, Identifiable {
    let id: String
    let formula: String         // 公式表达式（纯文本）
    let description: String     // 公式说明（算什么、什么意思）
    let variables: [Variable]   // 变量说明
    let calculator: Calculator? // 计算器配置（null 表示无计算器）
}

// MARK: - 变量

/// 公式变量说明
struct Variable: Codable {
    let name: String            // 变量名
    let description: String     // 说明
    let unit: String            // 单位
}

// MARK: - 计算器配置

/// 公式计算器配置
/// 注意：计算逻辑在 CalculatorService 中按 formulaId 硬编码，不支持自定义表达式
struct Calculator: Codable {
    let inputs: [CalcInput]     // 输入变量
    let outputName: String      // 输出变量名
    let outputUnit: String      // 输出单位
}

// MARK: - 计算器输入

/// 计算器输入变量
struct CalcInput: Codable {
    let name: String            // 变量名
    let defaultValue: Double    // 默认值
    let unit: String            // 单位
    let unitOptions: [String]   // 可选单位（如 Ω/kΩ/MΩ）
}
