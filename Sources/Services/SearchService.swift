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
        static let titleExact = 100        // 标题精确匹配
        static let errorPattern = 80       // 错误消息模式匹配（粘贴报错直达）
        static let titleContains = 50      // 标题包含匹配
        static let chineseTitle = 40       // 中文标题包含匹配
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
        let asciiQuery = isASCIIOnly(query)

        // 1. 标题精确匹配（权重最高）
        if item.title.lowercased() == query {
            score += Weight.titleExact
        }

        // 2. 标题包含匹配（ASCII 查询要求词边界，避免 "tran" 误命中 "transfer"）
        if containsWithBoundary(item.title.lowercased(), query: query, asciiQuery: asciiQuery) {
            score += Weight.titleContains
        }

        // 3. 中文标题包含匹配
        if item.chineseTitle.lowercased().contains(query) {
            score += Weight.chineseTitle
        }

        // 4. 标签匹配（每个匹配的标签都加分）
        for tag in item.tags {
            if containsWithBoundary(tag.lowercased(), query: query, asciiQuery: asciiQuery) {
                score += Weight.tag
            }
        }

        // 5. 摘要包含匹配（权重最低）
        if containsWithBoundary(item.summary.lowercased(), query: query, asciiQuery: asciiQuery) {
            score += Weight.summary
        }

        // 6. 错误消息模式匹配（支持粘贴完整报错文本反查）
        if let pattern = item.errorPattern?.lowercased(), matchesErrorPattern(pattern, query: query) {
            score += Weight.errorPattern
        }

        return score
    }

    /// 是否为纯 ASCII 查询
    private func isASCIIOnly(_ string: String) -> Bool {
        return string.allSatisfy { $0.isASCII }
    }

    /// 包含匹配：纯 ASCII 查询要求命中位置前后不能紧邻字母/数字（词边界），
    /// 避免 "tran" 误命中 "transfer"；中文/混合查询保持子串匹配
    private func containsWithBoundary(_ haystack: String, query: String, asciiQuery: Bool) -> Bool {
        guard !asciiQuery else {
            return matchesWithWordBoundary(haystack, needle: query)
        }
        return haystack.contains(query)
    }

    /// 词边界子串查找：命中处前后字符若不是 ASCII 字母/数字即视为边界
    /// （中文、标点、空格都算边界；"." 也作为边界，故 ".op" 不会命中 ".options"）
    private func matchesWithWordBoundary(_ haystack: String, needle: String) -> Bool {
        guard !needle.isEmpty else { return false }
        var searchStart = haystack.startIndex
        while let range = haystack.range(of: needle, range: searchStart..<haystack.endIndex) {
            let beforeIsWordChar: Bool = {
                guard range.lowerBound > haystack.startIndex else { return false }
                return isWordChar(haystack[haystack.index(before: range.lowerBound)])
            }()
            let afterIsWordChar: Bool = {
                guard range.upperBound < haystack.endIndex else { return false }
                return isWordChar(haystack[range.upperBound])
            }()
            if !beforeIsWordChar && !afterIsWordChar {
                return true
            }
            searchStart = haystack.index(after: range.lowerBound)
        }
        return false
    }

    private func isWordChar(_ character: Character) -> Bool {
        return character.isASCII && (character.isLetter || character.isNumber)
    }

    /// 错误消息模式匹配，"..." 视为通配符
    /// 双向：模式片段按序出现在查询中（粘贴 "Node N005 is floating" 命中 "Node ... is floating"）；
    /// 或查询是模式去通配后的子串（输入 "node is floating" 也能命中）
    private func matchesErrorPattern(_ pattern: String, query: String) -> Bool {
        let parts = pattern.components(separatedBy: "...").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !parts.isEmpty else { return false }

        // 正向：片段按序出现在查询文本中
        var searchStart = query.startIndex
        var allFound = true
        for part in parts {
            if let range = query.range(of: part, range: searchStart..<query.endIndex) {
                searchStart = range.upperBound
            } else {
                allFound = false
                break
            }
        }
        if allFound { return true }

        // 反向：查询是模式压平（去通配、归一空白）后的子串
        let flattened = normalizeWhitespace(parts.joined(separator: " "))
        let normalizedQuery = normalizeWhitespace(query)
        if !normalizedQuery.isEmpty && flattened.contains(normalizedQuery) {
            return true
        }
        return false
    }

    /// 归一化空白：连续空白压成单个空格
    private func normalizeWhitespace(_ string: String) -> String {
        return string.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
