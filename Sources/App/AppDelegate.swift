import Cocoa
import Carbon.HIToolbox

// MARK: - 页面状态

enum Page {
    case home
    case searchResults
    case detail
}

// MARK: - SpiceNest 应用主体

final class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - 属性

    private var window: NSWindow?
    private var statusItem: NSStatusItem?

    // 服务
    private let contentLoader = ContentLoader()
    private lazy var searchService = SearchService(items: contentLoader.allItems)

    // 页面视图
    private let homeView = HomeView()
    private let searchResultView = SearchResultView()
    private let detailView = DetailView()

    // 状态
    private var currentPage: Page = .home
    private var currentItem: ContentItem?
    private var pageHistory: [Page] = []

    // 收藏
    private var favorites: [String] = []
    private let favoritesKey = "SpiceNestFavorites"

    // MARK: - 应用生命周期

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        loadFavorites()
        setupWindow()
        setupStatusItem()
        setupHotKey()
        setupPageCallbacks()
        refreshFavoritesUI()
        showPage(.home)
        showWindow()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showWindow()
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        NXHotKeyManager.unregister()
    }

    // MARK: - URL Scheme

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            guard let result = NXURLScheme.parse(url) else { continue }
            showWindow()
            switch result.action {
            case "search":
                if let q = result.params["q"] {
                    performSearch(q)
                }
            case "open":
                if let id = result.params["id"], let item = contentLoader.allItems.first(where: { $0.id == id }) {
                    showDetail(item)
                }
            default:
                break
            }
        }
    }

    // MARK: - 窗口设置

    private func setupWindow() {
        let win = NXWindowStyle.makeFloatingWindow(
            size: NSSize(width: 560, height: 640),
            title: "SpiceNest",
            tintColor: NSColor(red: 1.0, green: 0.584, blue: 0.0, alpha: 0.12),
            fixedWidth: true
        )
        win.center()
        window = win

        guard let contentView = win.contentView else { return }

        // 创建内容容器视图（添加在毛玻璃和主题色叠加层之上）
        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.wantsLayer = true
        contentView.addSubview(containerView)
        contentView.addConstraints([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // 添加三个页面视图到容器
        for view in [homeView, searchResultView, detailView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(view)
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                view.topAnchor.constraint(equalTo: containerView.topAnchor),
                view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            view.isHidden = true
        }
    }

    // MARK: - 页面回调

    private func setupPageCallbacks() {
        // 首页
        homeView.onSearchTextChange = { [weak self] text in
            self?.handleSearchTextChange(text)
        }
        homeView.onSearchEnter = { [weak self] text in
            self?.performSearch(text)
        }
        homeView.onCategoryClick = { [weak self] type in
            self?.handleCategoryClick(type)
        }
        homeView.onFavoriteItemClick = { [weak self] item in
            self?.showDetail(item)
        }

        // 搜索结果页
        searchResultView.onSearchTextChange = { [weak self] text in
            self?.handleSearchTextChange(text)
        }
        searchResultView.onSearchEnter = { [weak self] text in
            self?.performSearch(text)
        }
        searchResultView.onEscape = { [weak self] in
            self?.goBack()
        }
        searchResultView.onItemClick = { [weak self] item in
            self?.showDetail(item)
        }
        searchResultView.onItemCopy = { [weak self] item in
            self?.copyItem(item)
        }

        // 详情页
        detailView.onBack = { [weak self] in
            self?.goBack()
        }
        detailView.onFavorite = { [weak self] item in
            self?.toggleFavorite(item)
        }
        detailView.onCopyAll = { [weak self] item in
            self?.copyItem(item)
        }
        detailView.onRelatedItemClick = { [weak self] item in
            self?.showDetail(item)
        }
    }

    // MARK: - 页面切换

    private func showPage(_ page: Page) {
        currentPage = page
        homeView.isHidden = (page != .home)
        searchResultView.isHidden = (page != .searchResults)
        detailView.isHidden = (page != .detail)

        if page == .home {
            homeView.focusSearchField()
        } else if page == .searchResults {
            searchResultView.focusSearchField()
        }
    }

    private func goBack() {
        switch currentPage {
        case .detail:
            showPage(.searchResults)
        case .searchResults:
            showPage(.home)
        case .home:
            toggleWindow()
        }
    }

    // MARK: - 搜索逻辑

    private func handleSearchTextChange(_ text: String) {
        if text.isEmpty {
            showPage(.home)
        } else {
            performSearch(text)
        }
    }

    private func performSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showPage(.home)
            return
        }

        let results = searchService.search(query: trimmed)
        searchResultView.updateResults(results, query: trimmed)
        showPage(.searchResults)
    }

    private func handleCategoryClick(_ type: ContentType) {
        // 按类型筛选：搜索该类型的所有内容
        let items = contentLoader.items(ofType: type)
        var grouped: [ContentType: [ContentItem]] = [:]
        grouped[type] = items
        searchResultView.updateResults(grouped, query: type.displayName)
        showPage(.searchResults)
    }

    // MARK: - 详情逻辑

    private func showDetail(_ item: ContentItem) {
        currentItem = item

        // 根据类型加载详情
        var commandDetail: CommandDetail?
        var errorDetail: ErrorDetail?

        switch item.type {
        case .command:
            commandDetail = contentLoader.loadCommandDetail(id: item.id)
        case .error:
            errorDetail = contentLoader.loadErrorDetail(id: item.id)
        default:
            break
        }

        // 加载关联内容
        let relatedItems = item.related.compactMap { relatedId in
            contentLoader.allItems.first { $0.id == relatedId }
        }

        detailView.configure(with: item, commandDetail: commandDetail, errorDetail: errorDetail, relatedItems: relatedItems)
        detailView.setFavorite(favorites.contains(item.id))
        detailView.onKeyHub = {
            NSWorkspace.shared.open(URL(fileURLWithPath: "/Applications/KeyHub.app"))
        }
        showPage(.detail)
    }

    // MARK: - 复制逻辑

    private func copyItem(_ item: ContentItem) {
        var textToCopy = ""

        switch item.type {
        case .command:
            if let detail = contentLoader.loadCommandDetail(id: item.id) {
                textToCopy = detail.syntax.joined(separator: "\n")
            }
        case .error:
            if let detail = contentLoader.loadErrorDetail(id: item.id) {
                textToCopy = detail.copyableCommands.joined(separator: "\n")
            }
        default:
            textToCopy = item.title
        }

        if textToCopy.isEmpty {
            textToCopy = item.title
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(textToCopy, forType: .string)
    }

    // MARK: - 收藏逻辑

    private func loadFavorites() {
        favorites = UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
    }

    private func saveFavorites() {
        UserDefaults.standard.set(favorites, forKey: favoritesKey)
    }

    private func toggleFavorite(_ item: ContentItem) {
        if let index = favorites.firstIndex(of: item.id) {
            favorites.remove(at: index)
        } else {
            favorites.append(item.id)
        }
        saveFavorites()
        refreshFavoritesUI()
    }

    /// 刷新首页收藏列表
    private func refreshFavoritesUI() {
        let items = favorites.compactMap { id in
            contentLoader.allItems.first { $0.id == id }
        }
        homeView.updateFavorites(items)
    }

    // MARK: - 全局热键

    private func setupHotKey() {
        NXHotKeyManager.register(
            keyCode: UInt32(kVK_ANSI_S),
            modifiers: UInt32(controlKey) | UInt32(optionKey),
            signature: OSType(0x534E),
            onHotKey: { [weak self] in self?.toggleWindow() }
        )
    }

    // MARK: - 菜单栏

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            let img = NSImage(systemSymbolName: "bolt", accessibilityDescription: "SpiceNest")?.withSymbolConfiguration(config)
            img?.isTemplate = true
            button.image = img
            button.imagePosition = .imageOnly
        }

        let menu = NSMenu()

        let toggle = NSMenuItem(title: "显示 / 隐藏 SpiceNest", action: #selector(toggleWindow), keyEquivalent: "")
        toggle.target = self
        menu.addItem(toggle)
        menu.addItem(.separator())

        let nexusMenu = makeNexusAppsMenu()
        let nexusItem = NSMenuItem(title: "Nexus 应用", action: nil, keyEquivalent: "")
        nexusItem.submenu = nexusMenu
        menu.addItem(nexusItem)
        menu.addItem(.separator())

        let quit = NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        item.menu = menu
        statusItem = item
    }

    private func makeNexusAppsMenu() -> NSMenu {
        let menu = NSMenu(title: "Nexus 应用")

        let hubItem = NSMenuItem(title: "Nexus Hub", action: #selector(openNexusApp(_:)), keyEquivalent: "")
        hubItem.target = self
        hubItem.representedObject = "hub"
        hubItem.isEnabled = NXURLScheme.isAppInstalled(appId: "hub")
        if !hubItem.isEnabled { hubItem.title = "Nexus Hub（未安装）" }
        menu.addItem(hubItem)
        menu.addItem(.separator())

        let knownApps: [(id: String, name: String)] = [
            ("keyhub", "KeyHub"),
            ("spicenest", "SpiceNest"),
        ]
        for app in knownApps {
            let item = NSMenuItem(title: app.name, action: #selector(openNexusApp(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = app.id
            item.isEnabled = NXURLScheme.isAppInstalled(appId: app.id)
            if !item.isEnabled { item.title = "\(app.name)（未安装）" }
            menu.addItem(item)
        }

        if menu.items.filter({ $0.action != nil }).count <= 1 {
            let hint = NSMenuItem(title: "暂无其他已安装应用", action: nil, keyEquivalent: "")
            hint.isEnabled = false
            menu.addItem(hint)
        }
        return menu
    }

    @objc private func openNexusApp(_ sender: NSMenuItem) {
        guard let appId = sender.representedObject as? String else { return }
        NXURLScheme.openApp(appId: appId)
    }

    // MARK: - 窗口切换

    @objc func toggleWindow() {
        if let win = window, win.isVisible {
            win.orderOut(nil)
        } else {
            showWindow()
        }
    }

    private func showWindow() {
        guard let win = window else { return }
        win.makeKeyAndOrderFront(nil)
        win.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() { NSApp.terminate(nil) }
}
