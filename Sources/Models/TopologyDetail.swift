import Foundation

// MARK: - 拓扑详情

/// 电路拓扑详情，如分压电路、共射放大器等
struct TopologyDetail: Codable {
    let id: String
    let category: String        // 分类（basic/op-amp/power/signal/interface）
    let difficulty: String      // 难度（入门/基础/进阶/高级）
    let description: String     // 电路说明
    let formulas: [String]      // 关键公式
    let designTips: [String]    // 取值建议/设计要点
    let ascSnippet: String      // 最小 .asc 片段（可复制）
    let applications: [String]  // 应用场景
}
