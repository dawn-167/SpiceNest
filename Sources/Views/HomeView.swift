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
                categoryTypes.append(type)

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
        favoritesScrollView.isHidden = true
        addSubview(favoritesScrollView)

        // 收藏列表堆栈视图（横向）
        favoritesStackView.translatesAutoresizingMaskIntoConstraints = false
        favoritesStackView.orientation = .horizontal
        favoritesStackView.spacing = 10
        favoritesStackView.alignment = .top
        favoritesScrollView.documentView = favoritesStackView

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
            favoritesStackView.heightAnchor.constraint(equalTo: favoritesScrollView.heightAnchor)
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
            favoritesStackView.addArrangedSubview(card)
            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: 160),
                card.heightAnchor.constraint(equalToConstant: 110)
            ])
            favoriteCardViews.append(card)
        }
    }

    // MARK: - 动作

    private func categoryClicked(type: ContentType) {
        onCategoryClick?(type)
    }
}
