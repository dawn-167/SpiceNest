import Foundation

// MARK: - SearchService 协议

/// 搜索服务协议
/// 负责对内容索引进行多字段匹配、按权重排序、按类型分组
protocol SearchServiceProtocol {
    /// 执行搜索
    /// - Parameter query: 搜索关键词
    /// - Returns: 按类型分组的搜索结果，每组内按匹配权重降序排列
    func search(query: String) -> [ContentType: [ContentItem]]

    /// 执行搜索，返回扁平列表（不分组）
    /// - Parameter query: 搜索关键词
    /// - Returns: 按匹配权重降序排列的搜索结果
    func searchFlat(query: String) -> [ContentItem]
}

// MARK: - 搜索结果

/// 单个搜索结果，包含内容项和匹配分数
struct SearchResult {
    let item: ContentItem
    let score: Int
}

// MARK: - SearchService 实现

/// 搜索服务实现
/// 多字段匹配，按权重排序，按类型分组
final class SearchService: SearchServiceProtocol {

    // MARK: - 匹配权重

    private enum Weight {
        static let titleExact = 100      // 标题精确匹配
        static let titleContains = 50     // 标题包含匹配
        static let chineseTitle = 40      // 中文标题包含匹配
        static let tag = 30                // 标签包含匹配
        static let summary = 10            // 摘要包含匹配
    }

    // MARK: - 属性

    /// 内容索引
    private let items: [ContentItem]

    // MARK: - 初始化

    /// 初始化搜索服务
    /// - Parameter items: 内容索引列表
    init(items: [ContentItem]) {
        self.items = items
    }

    // MARK: - 公开方法

    func search(query: String) -> [ContentType: [ContentItem]] {
        let results = searchFlat(query: query)
        var grouped: [ContentType: [ContentItem]] = [:]
        for item in results {
            grouped[item.type, default: []].append(item)
        }
        return grouped
    }

    func searchFlat(query: String) -> [ContentItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let lowercasedQuery = trimmed.lowercased()
        var results: [SearchResult] = []

        for item in items {
            let score = calculateScore(item: item, query: lowercasedQuery)
            if score > 0 {
                results.append(SearchResult(item: item, score: score))
            }
        }

        // 按分数降序排列，分数相同按标题排序
        results.sort { lhs, rhs in
            if lhs.score != rhs.score {
                return lhs.score > rhs.score
            }
            return lhs.item.title < rhs.item.title
        }

        return results.map { $0.item }
    }

    // MARK: - 私有方法

    /// 计算内容项与搜索词的匹配分数
    /// - Parameters:
    ///   - item: 内容项
    ///   - query: 小写的搜索词
    /// - Returns: 匹配分数，0 表示不匹配
    private func calculateScore(item: ContentItem, query: String) -> Int {
        var score = 0

        // 1. 标题精确匹配（权重最高）
        if item.title.lowercased() == query {
            score += Weight.titleExact
        }

        // 2. 标题包含匹配
        if item.title.lowercased().contains(query) {
            score += Weight.titleContains
        }

        // 3. 中文标题包含匹配
        if item.chineseTitle.lowercased().contains(query) {
            score += Weight.chineseTitle
        }

        // 4. 标签匹配（每个匹配的标签都加分）
        for tag in item.tags {
            if tag.lowercased().contains(query) {
                score += Weight.tag
            }
        }

        // 5. 摘要包含匹配（权重最低）
        if item.summary.lowercased().contains(query) {
            score += Weight.summary
        }

        return score
    }
}
