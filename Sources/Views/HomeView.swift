import Cocoa

// MARK: - 首页视图

/// 首页：SpiceNest Logo + 副标题 + 热键提示 + 搜索框 + 快速分类标签 + 收藏区
final class HomeView: NSView {
    // MARK: - 回调

    /// 搜索框输入变化回调
    var onSearchTextChange: ((String) -> Void)?

    /// 按下回车键回调
    var onSearchEnter: ((String) -> Void)?

    /// 点击快速分类回调
    var onCategoryClick: ((ContentType) -> Void)?

    /// 点击收藏卡片回调
    var onFavoriteItemClick: ((ContentItem) -> Void)?

    // MARK: - 属性

    private let logoLabel = NSTextField(labelWithString: "")
    private let subtitleLabel = NSTextField(labelWithString: "")
    private let hotkeyLabel = NSTextField(labelWithString: "")
    private let searchField = SearchFieldView()
    private let categoriesStackView = NSStackView()
    private let favoritesLabel = NSTextField(labelWithString: "")
    private let favoritesEmptyLabel = NSTextField(labelWithString: "")
    private let favoritesScrollView = NSScrollView()
    private let favoritesStackView = NSStackView()
    private var favoriteCardViews: [ContentCardView] = []
    private var categoryTypes: [ContentType] = []

    // MARK: - 初始化

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI 设置

    private func setupUI() {
        wantsLayer = true

        // Logo
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        logoLabel.stringValue = "SpiceNest"
        logoLabel.font = NSFont(name: "Impact", size: 28) ?? NSFont.systemFont(ofSize: 28, weight: .bold)
        logoLabel.textColor = NSColor(calibratedRed: 1.0, green: 0.584, blue: 0.0, alpha: 1.0)
        logoLabel.alignment = .center
        addSubview(logoLabel)

        // 副标题
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.stringValue = "LTspice 仿真参考助手"
        subtitleLabel.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .secondaryLabelColor
        subtitleLabel.alignment = .center
        addSubview(subtitleLabel)

        // 热键提示
        hotkeyLabel.translatesAutoresizingMaskIntoConstraints = false
        hotkeyLabel.stringValue = "按 ⌃⌥S 快速唤出"
        hotkeyLabel.font = NSFont.systemFont(ofSize: 11, weight: .regular)
        hotkeyLabel.textColor = .tertiaryLabelColor
        hotkeyLabel.alignment = .center
        addSubview(hotkeyLabel)

        // 搜索框
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.onTextChange = { [weak self] text in
            self?.onSearchTextChange?(text)
        }
        searchField.onEnter = { [weak self] text in
            self?.onSearchEnter?(text)
        }
        addSubview(searchField)

        // 快速分类标签
        categoriesStackView.translatesAutoresizingMaskIntoConstraints = false
        categoriesStackView.orientation = .horizontal
        categoriesStackView.spacing = 8
        categoriesStackView.alignment = .centerY
        addSubview(categoriesStackView)

        let categories: [(type: ContentType, enabled: Bool)] = [
            (.command, true),
            (.error, true),
            (.parameter, false),
            (.formula, false),
            (.tip, false),
            (.topology, false)
        ]

        for (index, (type, enabled)) in categories.enumerated() {
            let button = NSButton(title: type.displayName, target: self, action: #selector(categoryClicked(_:)))
            button.bezelStyle = .rounded
            button.isBordered = false
            button.font = NSFont.systemFont(ofSize: 11, weight: .medium)
            button.tag = index
            categoryTypes.append(type)
            if enabled {
                button.contentTintColor = NSColor(calibratedRed: 1.0, green: 0.584, blue: 0.0, alpha: 1.0)
            } else {
                button.contentTintColor = .tertiaryLabelColor
                button.isEnabled = false
            }
            categoriesStackView.addArrangedSubview(button)
        }

        // 收藏区标题
        favoritesLabel.translatesAutoresizingMaskIntoConstraints = false
        favoritesLabel.stringValue = "收藏"
        favoritesLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        favoritesLabel.textColor = .secondaryLabelColor
        addSubview(favoritesLabel)

        // 收藏区空状态
        favoritesEmptyLabel.translatesAutoresizingMaskIntoConstraints = false
        favoritesEmptyLabel.stringValue = "暂无收藏，在详情页点击 ⭐ 收藏"
        favoritesEmptyLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        favoritesEmptyLabel.textColor = .tertiaryLabelColor
        favoritesEmptyLabel.alignment = .center
        addSubview(favoritesEmptyLabel)

        // 收藏列表滚动视图
        favoritesScrollView.translatesAutoresizingMaskIntoConstraints = false
        favoritesScrollView.hasVerticalScroller = true
        favoritesScrollView.hasHorizontalScroller = false
        favoritesScrollView.borderType = .noBorder
        favoritesScrollView.drawsBackground = false
        favoritesScrollView.automaticallyAdjustsContentInsets = false
        favoritesScrollView.isHidden = true
        addSubview(favoritesScrollView)

        // 收藏列表堆栈视图
        favoritesStackView.translatesAutoresizingMaskIntoConstraints = false
        favoritesStackView.orientation = .vertical
        favoritesStackView.spacing = 8
        favoritesStackView.alignment = .leading
        favoritesScrollView.documentView = favoritesStackView

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            logoLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            hotkeyLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
            hotkeyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            searchField.topAnchor.constraint(equalTo: hotkeyLabel.bottomAnchor, constant: 20),
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchField.heightAnchor.constraint(equalToConstant: 36),

            categoriesStackView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 12),
            categoriesStackView.centerXAnchor.constraint(equalTo: centerXAnchor),

            favoritesLabel.topAnchor.constraint(equalTo: categoriesStackView.bottomAnchor, constant: 20),
            favoritesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            favoritesEmptyLabel.topAnchor.constraint(equalTo: favoritesLabel.bottomAnchor, constant: 16),
            favoritesEmptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            favoritesScrollView.topAnchor.constraint(equalTo: favoritesLabel.bottomAnchor, constant: 8),
            favoritesScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            favoritesScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            favoritesScrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            favoritesStackView.leadingAnchor.constraint(equalTo: favoritesScrollView.leadingAnchor),
            favoritesStackView.trailingAnchor.constraint(equalTo: favoritesScrollView.trailingAnchor),
            favoritesStackView.topAnchor.constraint(equalTo: favoritesScrollView.topAnchor),
            favoritesStackView.widthAnchor.constraint(equalTo: favoritesScrollView.widthAnchor)
        ])
    }

    // MARK: - 公开方法

    /// 聚焦搜索框
    func focusSearchField() {
        searchField.focus()
    }

    /// 获取搜索框文本
    var searchText: String {
        return searchField.text
    }

    /// 更新收藏列表
    func updateFavorites(_ items: [ContentItem]) {
        // 清空现有卡片
        for view in favoritesStackView.arrangedSubviews {
            favoritesStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        favoriteCardViews = []

        if items.isEmpty {
            favoritesEmptyLabel.isHidden = false
            favoritesScrollView.isHidden = true
            return
        }

        favoritesEmptyLabel.isHidden = true
        favoritesScrollView.isHidden = false

        for item in items {
            let card = ContentCardView()
            card.configure(with: item)
            card.translatesAutoresizingMaskIntoConstraints = false
            card.onClick = { [weak self] item in
                self?.onFavoriteItemClick?(item)
            }
            favoritesStackView.addArrangedSubview(card)
            NSLayoutConstraint.activate([
                card.leadingAnchor.constraint(equalTo: favoritesStackView.leadingAnchor),
                card.trailingAnchor.constraint(equalTo: favoritesStackView.trailingAnchor),
                card.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
            ])
            favoriteCardViews.append(card)
        }
    }

    // MARK: - 动作

    @objc private func categoryClicked(_ sender: NSButton) {
        guard sender.tag >= 0 && sender.tag < categoryTypes.count else { return }
        let type = categoryTypes[sender.tag]
        onCategoryClick?(type)
    }
}
