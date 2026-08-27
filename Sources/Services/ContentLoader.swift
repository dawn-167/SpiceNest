import Foundation

// MARK: - ContentLoader 协议

/// 内容加载服务协议
/// 负责读取 JSON 内容文件，构建搜索索引，按需加载详情
protocol ContentLoaderProtocol {
    /// 所有内容的索引列表（启动时加载）
    var allItems: [ContentItem] { get }

    /// 按类型筛选内容
    /// - Parameter type: 内容类型
    /// - Returns: 该类型的所有内容项
    func items(ofType type: ContentType) -> [ContentItem]

    /// 根据 id 查找内容项
    /// - Parameter id: 内容唯一标识
    /// - Returns: 对应的内容项，未找到返回 nil
    func item(withId id: String) -> ContentItem?

    /// 加载指令详情
    /// - Parameter id: 指令 id，如 "command-tran"
    /// - Returns: 指令详情，加载失败返回 nil
    func loadCommandDetail(id: String) -> CommandDetail?

    /// 加载错误详情
    /// - Parameter id: 错误 id，如 "error-time-step-too-small"
    /// - Returns: 错误详情，加载失败返回 nil
    func loadErrorDetail(id: String) -> ErrorDetail?

    /// 加载参数详情
    /// - Parameter id: 参数 id
    /// - Returns: 参数详情，加载失败返回 nil
    func loadParameterDetail(id: String) -> ParameterDetail?

    /// 加载公式详情
    /// - Parameter id: 公式 id
    /// - Returns: 公式详情，加载失败返回 nil
    func loadFormulaDetail(id: String) -> FormulaDetail?

    /// 加载技巧详情
    /// - Parameter id: 技巧 id
    /// - Returns: 技巧详情，加载失败返回 nil
    func loadTipDetail(id: String) -> TipDetail?

    /// 加载拓扑详情
    /// - Parameter id: 拓扑 id
    /// - Returns: 拓扑详情，加载失败返回 nil
    func loadTopologyDetail(id: String) -> TopologyDetail?
}

// MARK: - ContentLoader 实现

/// 内容加载服务实现
/// 启动时读取 index.json 到内存，详情按需加载并缓存
final class ContentLoader: ContentLoaderProtocol {

    // MARK: - 属性

    /// 所有内容的索引列表
    private(set) var allItems: [ContentItem] = []

    /// 内容索引缓存，key 为 id
    private var itemIndex: [String: ContentItem] = [:]

    /// 详情缓存，最近 30 条
    private let detailCache = NSCache<NSString, AnyObject>()

    /// 内容目录路径
    private let contentDirectory: URL

    /// JSON 解码器
    private let decoder = JSONDecoder()

    // MARK: - 初始化

    /// 初始化内容加载器
    /// - Parameter contentDirectory: 内容目录路径，默认从 app bundle 的 Resources/content 读取
    init(contentDirectory: URL? = nil) {
        if let dir = contentDirectory {
            self.contentDirectory = dir
        } else {
            // 默认从 app bundle 的 Resources/content 读取
            let bundlePath = Bundle.main.bundlePath
            self.contentDirectory = URL(fileURLWithPath: bundlePath)
                .appendingPathComponent("Contents/Resources/content")
        }
        loadIndex()
    }

    // MARK: - 索引加载

    /// 加载 index.json 到内存
    private func loadIndex() {
        let indexURL = contentDirectory.appendingPathComponent("index.json")
        guard let data = try? Data(contentsOf: indexURL) else {
            print("[ContentLoader] 警告: 无法读取 index.json")
            return
        }

        // index.json 格式: { "version": "...", "items": [...] }
        struct IndexWrapper: Codable {
            let items: [ContentItem]
        }

        guard let wrapper = try? decoder.decode(IndexWrapper.self, from: data) else {
            print("[ContentLoader] 警告: index.json 解析失败")
            return
        }

        allItems = wrapper.items
        itemIndex = Dictionary(uniqueKeysWithValues: allItems.map { ($0.id, $0) })
        print("[ContentLoader] 已加载 \(allItems.count) 条内容索引")
    }

    // MARK: - 索引查询

    func items(ofType type: ContentType) -> [ContentItem] {
        return allItems.filter { $0.type == type }
    }

    func item(withId id: String) -> ContentItem? {
        return itemIndex[id]
    }

    // MARK: - 详情加载（通用方法）

    /// 从单独文件加载详情（指令类型使用）
    /// - Parameters:
    ///   - fileName: 文件名，如 "command-tran.json"
    ///   - subdirectory: 子目录，如 "commands"
    ///   - type: 详情类型
    /// - Returns: 解析后的详情对象
    private func loadDetailFromFile<T: Codable>(fileName: String, subdirectory: String, type: T.Type) -> T? {
        let cacheKey = fileName as NSString
        if let cached = detailCache.object(forKey: cacheKey) as? T {
            return cached
        }

        let fileURL = contentDirectory
            .appendingPathComponent(subdirectory)
            .appendingPathComponent(fileName)

        guard let data = try? Data(contentsOf: fileURL) else {
            print("[ContentLoader] 警告: 无法读取 \(fileURL.path)")
            return nil
        }

        guard let detail = try? decoder.decode(T.self, from: data) else {
            print("[ContentLoader] 警告: \(fileName) 解析失败")
            return nil
        }

        detailCache.setObject(detail as AnyObject, forKey: cacheKey)
        return detail
    }

    /// 从数组文件中按 id 查找详情（错误/参数/公式/技巧/拓扑类型使用）
    /// - Parameters:
    ///   - fileName: 数组文件名，如 "common-errors.json"
    ///   - subdirectory: 子目录，如 "errors"
    ///   - id: 要查找的详情 id
    ///   - type: 详情类型
    /// - Returns: 匹配的详情对象
    private func loadDetailFromArray<T: Codable & Identifiable>(fileName: String, subdirectory: String, id: String, type: T.Type) -> T? where T.ID == String {
        let cacheKey = "\(subdirectory)/\(fileName)/\(id)" as NSString
        if let cached = detailCache.object(forKey: cacheKey) as? T {
            return cached
        }

        let fileURL = contentDirectory
            .appendingPathComponent(subdirectory)
            .appendingPathComponent(fileName)

        guard let data = try? Data(contentsOf: fileURL) else {
            print("[ContentLoader] 警告: 无法读取 \(fileURL.path)")
            return nil
        }

        guard let array = try? decoder.decode([T].self, from: data) else {
            print("[ContentLoader] 警告: \(fileName) 解析失败")
            return nil
        }

        guard let detail = array.first(where: { $0.id == id }) else {
            print("[ContentLoader] 警告: 在 \(fileName) 中未找到 id=\(id)")
            return nil
        }

        detailCache.setObject(detail as AnyObject, forKey: cacheKey)
        return detail
    }

    // MARK: - 各类型详情加载

    func loadCommandDetail(id: String) -> CommandDetail? {
        return loadDetailFromFile(fileName: "\(id).json", subdirectory: "commands", type: CommandDetail.self)
    }

    func loadErrorDetail(id: String) -> ErrorDetail? {
        return loadDetailFromArray(fileName: "common-errors.json", subdirectory: "errors", id: id, type: ErrorDetail.self)
    }

    func loadParameterDetail(id: String) -> ParameterDetail? {
        // 参数按元器件类型分文件，如 bjt.json、mosfet.json
        // 从 id 中提取元器件类型，如 "param-bjt-is" → "bjt"
        let components = id.split(separator: "-")
        guard components.count >= 2 else { return nil }
        let componentType = String(components[1])
        return loadDetailFromArray(fileName: "\(componentType).json", subdirectory: "parameters", id: id, type: ParameterDetail.self)
    }

    func loadFormulaDetail(id: String) -> FormulaDetail? {
        return loadDetailFromArray(fileName: "formulas.json", subdirectory: "formulas", id: id, type: FormulaDetail.self)
    }

    func loadTipDetail(id: String) -> TipDetail? {
        return loadDetailFromArray(fileName: "tips.json", subdirectory: "tips", id: id, type: TipDetail.self)
    }

    func loadTopologyDetail(id: String) -> TopologyDetail? {
        return loadDetailFromArray(fileName: "topologies.json", subdirectory: "topologies", id: id, type: TopologyDetail.self)
    }
}
