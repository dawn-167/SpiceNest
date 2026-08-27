import Foundation

// MARK: - 参数详情

/// 元器件参数详情，如 BJT 的 IS、BF，MOSFET 的 VTO 等
struct ParameterDetail: Codable, Identifiable {
    let id: String
    let componentType: String   // 元器件类型（bjt/mosfet/jfet/diode/opamp/resistor...）
    let description: String     // 含义说明
    let typicalRange: String    // 典型值范围
    let defaultValue: String    // 默认值
    let effect: String          // 影响说明（调大调小会怎样）
    let example: String         // 设置示例
}
