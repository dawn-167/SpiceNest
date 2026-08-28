import Cocoa

// MARK: - 首页视图

/// 首页：SpiceNest Logo + 副标题 + 热键提示 + 搜索框 + 快速分类标签 + 收藏区
final class HomeView: NSView {
    // MARK: - 回调

    /// 搜索框输入变化回调
    var onSearchTextChange: ((String) -> Void)?

    /// 按下回车键回调
    var onSearchEnter: ((String) -> Void)?

    /// 按下 Esc 键回调
    var onEscape: (() -> Void)?

    /// 点击快速分类回调
    var onCategoryClick: ((ContentType) -> Void)?

    /// 点击收藏卡片回调
    var onFavoriteItemClick: ((ContentItem) -> Void)?

    /// 收藏卡片复制按钮回调
    var onFavoriteItemCopy: ((ContentItem) -> Void)?

    /// 点击最近查看条目回调
    var onRecentItemClick: ((ContentItem) -> Void)?

    // MARK: - 属性

    private let logoLabel = NSTextField(labelWithString: "")
    private let subtitleLabel = NSTextField(labelWithString: "")
    private let hotkeyLabel = NSTextField(labelWithString: "")
    private let hotkeyStackView = NSStackView()
    private let searchField = SearchFieldView()
    private let categoriesStackView = NSStackView()
    private let favoritesLabel = NSTextField(labelWithString: "")
    private let favoritesEmptyCard = NSView()
    private let favoritesEmptyIcon = NSImageView()
    private let favoritesEmptyText = NSTextField(labelWithString: "")
    private let favoritesScrollView = NSScrollView()
    private let favoritesStackView = NSStackView()
    private var favoriteCardViews: [ContentCardView] = []
    private let recentsLabel = NSTextField(labelWithString: "")
    private let recentsStackView = NSStackView()

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

        // Logo（SF Pro Rounded Heavy + 琥珀渐变，清晰有品牌感，P-026）
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        logoLabel.attributedStringValue = makeLogoAttributedString()
        logoLabel.alignment = .center
        addSubview(logoLabel)

        // 副标题（15pt Medium）
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.stringValue = "LTspice 参考助手"
        subtitleLabel.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = .secondaryLabelColor
        subtitleLabel.alignment = .center
        addSubview(subtitleLabel)

        // 热键提示文字（12pt Medium，P-027）
        hotkeyLabel.translatesAutoresizingMaskIntoConstraints = false
        hotkeyLabel.stringValue = "快速唤出"
        hotkeyLabel.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        hotkeyLabel.textColor = .secondaryLabelColor
        hotkeyLabel.alignment = .center
        addSubview(hotkeyLabel)

        // 键帽容器
        hotkeyStackView.translatesAutoresizingMaskIntoConstraints = false
        hotkeyStackView.orientation = .horizontal
        hotkeyStackView.spacing = 4
        hotkeyStackView.alignment = .centerY
        addSubview(hotkeyStackView)

        let amber = NSColor(calibratedRed: 1.0, green: 0.584, blue: 0.0, alpha: 1.0)
        let keycaps = ["⌃", "⌥", "S"]
        for key in keycaps {
            let keyView = NSTextField(labelWithString: key)
            keyView.translatesAutoresizingMaskIntoConstraints = false
            keyView.font = NSFont.systemFont(ofSize: 11, weight: .semibold)
            keyView.textColor = amber
            keyView.alignment = .center
            keyView.wantsLayer = true
            keyView.layer?.backgroundColor = amber.withAlphaComponent(0.12).cgColor
            keyView.layer?.cornerRadius = 5
            keyView.layer?.borderWidth = 1
            keyView.layer?.borderColor = amber.withAlphaComponent(0.4).cgColor
            hotkeyStackView.addArrangedSubview(keyView)
            NSLayoutConstraint.activate([
                keyView.widthAnchor.constraint(equalToConstant: 22),
                keyView.heightAnchor.constraint(equalToConstant: 20)
            ])
        }

        // 搜索框
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.onTextChange = { [weak self] text in
            self?.onSearchTextChange?(text)
        }
        searchField.onEnter = { [weak self] text in
            self?.onSearchEnter?(text)
        }
        searchField.onEscape = { [weak self] in
            self?.onEscape?()
        }
        addSubview(searchField)

        // 快速分类标签（3 行 2 列胶囊，P-029）
        categoriesStackView.translatesAutoresizingMaskIntoConstraints = false
        categoriesStackView.orientation = .vertical
        categoriesStackView.spacing = 8
        categoriesStackView.alignment = .centerX
        addSubview(categoriesStackView)

        let categories: [(type: ContentType, enabled: Bool)] = [
            (.command, true),
            (.error, true),
            (.parameter, false),
            (.formula, false),
            (.tip, false),
            (.topology, false)
        ]

        // 每行 2 个，共 3 行
        for rowStart in stride(from: 0, to: categories.count, by: 2) {
            let row = NSStackView()
            row.orientation = .horizontal
            row.spacing = 10
            row.alignment = .centerY

            for index in rowStart..<min(rowStart + 2, categories.count) {
                let (type, enabled) = categories[index]
                let tag = CategoryTagView()
                tag.text = type.displayName
                tag.contentType = type
                tag.isEnabled = enabled
                tag.translatesAutoresizingMaskIntoConstraints = false

                tag.onClick = { [weak self] in
                    self?.categoryClicked(type: type)
                }
                row.addArrangedSubview(tag)
            }
            categoriesStackView.addArrangedSubview(row)
        }

        // 收藏区标题
        favoritesLabel.translatesAutoresizingMaskIntoConstraints = false
        favoritesLabel.stringValue = "收藏"
        favoritesLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        favoritesLabel.textColor = .secondaryLabelColor
        addSubview(favoritesLabel)

        // 收藏区空状态卡片（横向居中，P-030）
        favoritesEmptyCard.translatesAutoresizingMaskIntoConstraints = false
        favoritesEmptyCard.wantsLayer = true
        favoritesEmptyCard.layer?.backgroundColor = NSColor(calibratedRed: 1.0, green: 0.584, blue: 0.0, alpha: 0.04).cgColor
        favoritesEmptyCard.layer?.cornerRadius = 12
        favoritesEmptyCard.isHidden = true
        addSubview(favoritesEmptyCard)

        favoritesEmptyIcon.translatesAutoresizingMaskIntoConstraints = false
        let starConfig = NSImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        favoritesEmptyIcon.image = NSImage(systemSymbolName: "star", accessibilityDescription: nil)?.withSymbolConfiguration(starConfig)
        favoritesEmptyIcon.contentTintColor = .tertiaryLabelColor
        favoritesEmptyCard.addSubview(favoritesEmptyIcon)

        favoritesEmptyText.translatesAutoresizingMaskIntoConstraints = false
        favoritesEmptyText.stringValue = "暂无收藏 · 打开任意指令点 ⭐ 收藏起来吧"
        favoritesEmptyText.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        favoritesEmptyText.textColor = .tertiaryLabelColor
        favoritesEmptyText.alignment = .center
        favoritesEmptyCard.addSubview(favoritesEmptyText)

        NSLayoutConstraint.activate([
            favoritesEmptyIcon.centerXAnchor.constraint(equalTo: favoritesEmptyCard.centerXAnchor),
            favoritesEmptyIcon.topAnchor.constraint(equalTo: favoritesEmptyCard.topAnchor, constant: 24),
            favoritesEmptyIcon.widthAnchor.constraint(equalToConstant: 26),
            favoritesEmptyIcon.heightAnchor.constraint(equalToConstant: 26),

            favoritesEmptyText.topAnchor.constraint(equalTo: favoritesEmptyIcon.bottomAnchor, constant: 8),
            favoritesEmptyText.centerXAnchor.constraint(equalTo: favoritesEmptyCard.centerXAnchor),
            favoritesEmptyText.bottomAnchor.constraint(equalTo: favoritesEmptyCard.bottomAnchor, constant: -20)
        ])

        // 收藏列表滚动视图（横向滚动，P-030）
        favoritesScrollView.translatesAutoresizingMaskIntoConstraints = false
        favoritesScrollView.hasVerticalScroller = false
        favoritesScrollView.hasHorizontalScroller = true
        favoritesScrollView.scrollerStyle = .overlay
        favoritesScrollView.borderType = .noBorder
        favoritesScrollView.drawsBackground = false
        favoritesScrollView.automaticallyAdjustsContentInsets = false
        // 内边距：给悬停上浮(3pt)和琥珀发光(12pt)留出空间，避免被容器直角边缘裁剪（P-058）
        favoritesScrollView.contentInsets = NSEdgeInsets(top: 12, left: 2, bottom: 8, right: 8)
        favoritesScrollView.isHidden = true
        addSubview(favoritesScrollView)

        // 收藏列表堆栈视图（横向）
        favoritesStackView.translatesAutoresizingMaskIntoConstraints = false
        favoritesStackView.orientation = .horizontal
        favoritesStackView.spacing = 10
        favoritesStackView.alignment = .top
        favoritesScrollView.documentView = favoritesStackView

        // 最近查看区（紧凑胶囊行，填充收藏区下方空白，P-049）
        recentsLabel.translatesAutoresizingMaskIntoConstraints = false
        recentsLabel.stringValue = "最近查看"
        recentsLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        recentsLabel.textColor = .secondaryLabelColor
        recentsLabel.isHidden = true
        addSubview(recentsLabel)

        recentsStackView.translatesAutoresizingMaskIntoConstraints = false
        recentsStackView.orientation = .horizontal
        recentsStackView.spacing = 8
        recentsStackView.alignment = .centerY
        recentsStackView.isHidden = true
        recentsStackView.wantsLayer = true
        recentsStackView.layer?.masksToBounds = true
        addSubview(recentsStackView)

        setupConstraints()
    }

    /// Logo 渐变文字（首段亮琥珀 → 末段深琥珀，P-026）
    private func makeLogoAttributedString() -> NSAttributedString {
        let lightAmber = NSColor(calibratedRed: 1.0, green: 0.702, blue: 0.251, alpha: 1.0)   // #FFB340
        let deepAmber = NSColor(calibratedRed: 1.0, green: 0.416, blue: 0.0, alpha: 1.0)      // #FF6A00
        let font = NSFont(name: "SF Pro Rounded", size: 36)
            ?? NSFont.systemFont(ofSize: 36, weight: .heavy)

        let attributed = NSMutableAttributedString()
        attributed.append(NSAttributedString(string: "Spice", attributes: [
            .font: font,
            .foregroundColor: lightAmber
        ]))
        attributed.append(NSAttributedString(string: "Nest", attributes: [
            .font: font,
            .foregroundColor: deepAmber
        ]))
        return attributed
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoLabel.topAnchor.constraint(equalTo: topAnchor, constant: 36),
            logoLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            hotkeyStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            hotkeyStackView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -34),

            hotkeyLabel.centerYAnchor.constraint(equalTo: hotkeyStackView.centerYAnchor),
            hotkeyLabel.leadingAnchor.constraint(equalTo: hotkeyStackView.trailingAnchor, constant: 6),

            searchField.topAnchor.constraint(equalTo: hotkeyStackView.bottomAnchor, constant: 20),
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36),

            categoriesStackView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 16),
            categoriesStackView.centerXAnchor.constraint(equalTo: centerXAnchor),

            favoritesLabel.topAnchor.constraint(equalTo: categoriesStackView.bottomAnchor, constant: 20),
            favoritesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            favoritesEmptyCard.topAnchor.constraint(equalTo: favoritesLabel.bottomAnchor, constant: 12),
            favoritesEmptyCard.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            favoritesEmptyCard.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            favoritesEmptyCard.heightAnchor.constraint(equalToConstant: 110),

            favoritesScrollView.topAnchor.constraint(equalTo: favoritesLabel.bottomAnchor, constant: 12),
            favoritesScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            favoritesScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            favoritesScrollView.heightAnchor.constraint(equalToConstant: 130),

            favoritesStackView.leadingAnchor.constraint(equalTo: favoritesScrollView.leadingAnchor),
            favoritesStackView.trailingAnchor.constraint(equalTo: favoritesScrollView.trailingAnchor),
            favoritesStackView.topAnchor.constraint(equalTo: favoritesScrollView.topAnchor),
            favoritesStackView.bottomAnchor.constraint(equalTo: favoritesScrollView.bottomAnchor),
            // 高度 = 卡片高度；12(上内边距) + 110 + 8(下内边距) 恰好填满 130 的滚动视图（P-058）
            favoritesStackView.heightAnchor.constraint(equalToConstant: 110),

            recentsLabel.topAnchor.constraint(equalTo: favoritesScrollView.bottomAnchor, constant: 16),
            recentsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            recentsStackView.topAnchor.constraint(equalTo: recentsLabel.bottomAnchor, constant: 8),
            recentsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            // 等号约束锁死宽度，避免胶囊理想宽度撑开窗口（P-059）；超出的胶囊压缩/裁剪
            recentsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
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

    /// 更新收藏列表（横向卡片，P-030）
    func updateFavorites(_ items: [ContentItem]) {
        // 清空现有卡片
        for view in favoritesStackView.arrangedSubviews {
            favoritesStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        favoriteCardViews = []

        if items.isEmpty {
            favoritesEmptyCard.isHidden = false
            favoritesScrollView.isHidden = true
            favoritesLabel.stringValue = "收藏"
            return
        }

        favoritesEmptyCard.isHidden = true
        favoritesScrollView.isHidden = false
        favoritesLabel.stringValue = "收藏 (\(items.count))"

        for item in items {
            let card = ContentCardView()
            card.configure(with: item)
            card.translatesAutoresizingMaskIntoConstraints = false
            card.onClick = { [weak self] item in
                self?.onFavoriteItemClick?(item)
            }
            card.onCopy = { [weak self] item in
                self?.onFavoriteItemCopy?(item)
            }
            favoritesStackView.addArrangedSubview(card)
            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: 160),
                card.heightAnchor.constraint(equalToConstant: 110)
            ])
            favoriteCardViews.append(card)
        }
    }

    /// 更新最近查看列表（紧凑胶囊行，P-049）
    func updateRecents(_ items: [ContentItem]) {
        for view in recentsStackView.arrangedSubviews {
            recentsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let isEmpty = items.isEmpty
        recentsLabel.isHidden = isEmpty
        recentsStackView.isHidden = isEmpty
        guard !isEmpty else { return }

        for item in items {
            let chip = RecentChipView(item: item)
            chip.onClick = { [weak self] in
                self?.onRecentItemClick?(item)
            }
            recentsStackView.addArrangedSubview(chip)
        }
    }

    // MARK: - 动作

    private func categoryClicked(type: ContentType) {
        onCategoryClick?(type)
    }
}

// MARK: - 最近查看胶囊

/// 最近查看条目的紧凑胶囊：类型色圆点 + 标题，点击直达详情
private final class RecentChipView: NSView {
    var onClick: (() -> Void)?

    private let item: ContentItem
    private var trackingArea: NSTrackingArea?

    init(item: ContentItem) {
        self.item = item
        super.init(frame: .zero)
        setupUI()
        setupTrackingArea()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        wantsLayer = true
        layer?.cornerRadius = 12
        layer?.borderWidth = 1
        applyColors(hovering: false)

        let dot = NSView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.wantsLayer = true
        dot.layer?.cornerRadius = 3
        dot.layer?.backgroundColor = item.type.color.cgColor
        addSubview(dot)

        let label = NSTextField(labelWithString: item.title)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = .labelColor
        label.lineBreakMode = .byTruncatingTail
        addSubview(label)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 24),

            dot.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            dot.centerYAnchor.constraint(equalTo: centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 6),
            dot.heightAnchor.constraint(equalToConstant: 6),

            label.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 120)
        ])
    }

    private func applyColors(hovering: Bool) {
        let alpha: CGFloat = hovering ? 0.2 : 0.1
        layer?.backgroundColor = item.type.color.withAlphaComponent(alpha).cgColor
        layer?.borderColor = item.type.color.withAlphaComponent(hovering ? 0.5 : 0.25).cgColor
    }

    private func setupTrackingArea() {
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let area = trackingArea {
            removeTrackingArea(area)
        }
        setupTrackingArea()
    }

    override func mouseEntered(with event: NSEvent) {
        applyColors(hovering: true)
    }

    override func mouseExited(with event: NSEvent) {
        applyColors(hovering: false)
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        onClick?()
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
}
