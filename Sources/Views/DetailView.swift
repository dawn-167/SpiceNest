import Cocoa

// MARK: - 详情页视图

/// 详情页：返回按钮 + 完整详情卡片 + 底部操作栏 + 可纵向滚动
final class DetailView: NSView {
    // MARK: - 回调

    /// 点击返回按钮回调
    var onBack: (() -> Void)?

    /// 点击收藏按钮回调
    var onFavorite: ((ContentItem) -> Void)?

    /// 点击复制全部回调
    var onCopyAll: ((ContentItem) -> Void)?

    /// 点击关联内容回调
    var onRelatedItemClick: ((ContentItem) -> Void)?

    /// 点击查快捷键回调
    var onKeyHub: (() -> Void)?

    // MARK: - 属性

    private let backButton = NSButton()
    private let scrollView = NSScrollView()
    private let contentStackView = NSStackView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let chineseTitleLabel = NSTextField(labelWithString: "")
    private let typeTag = TagView()
    private let summaryLabel = NSTextField(labelWithString: "")
    private let favoriteButton = NSButton()
    private let copyAllButton = NSButton()
    private let keyhubButton = NSButton()

    private var item: ContentItem?
    private var isFavorite: Bool = false
    private var currentRelatedItems: [ContentItem] = []

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

        // 返回按钮（文字"‹ 返回"）
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.bezelStyle = .rounded
        backButton.isBordered = false
        backButton.title = "‹ 返回"
        backButton.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        backButton.target = self
        backButton.action = #selector(backClicked)
        backButton.contentTintColor = .labelColor
        addSubview(backButton)

        // 滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        addSubview(scrollView)

        // 内容堆栈视图
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.orientation = .vertical
        contentStackView.spacing = 12
        contentStackView.alignment = .leading
        scrollView.documentView = contentStackView

        // 标题（带阴影效果，增强质感）
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = NSFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .labelColor
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.maximumNumberOfLines = 0
        titleLabel.shadow = NSShadow()
        titleLabel.shadow?.shadowColor = NSColor.black.withAlphaComponent(0.1)
        titleLabel.shadow?.shadowOffset = NSSize(width: 0, height: -1)
        titleLabel.shadow?.shadowBlurRadius = 1
        contentStackView.addArrangedSubview(titleLabel)

        // 中文标题（13pt Body）
        chineseTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        chineseTitleLabel.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        chineseTitleLabel.textColor = .secondaryLabelColor
        contentStackView.addArrangedSubview(chineseTitleLabel)

        // 类型标签
        typeTag.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(typeTag)

        // 摘要
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        summaryLabel.textColor = .labelColor
        summaryLabel.lineBreakMode = .byWordWrapping
        summaryLabel.maximumNumberOfLines = 0
        contentStackView.addArrangedSubview(summaryLabel)

        // 分隔线
        let separator = SeparatorView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(separator)
        separator.widthAnchor.constraint(equalTo: contentStackView.widthAnchor).isActive = true

        // 底部操作栏按钮
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.bezelStyle = .rounded
        favoriteButton.isBordered = false
        favoriteButton.title = "收藏"
        favoriteButton.target = self
        favoriteButton.action = #selector(favoriteClicked)
        let favConfig = NSImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let favIcon = NSImage(systemSymbolName: "star", accessibilityDescription: "收藏")?.withSymbolConfiguration(favConfig)
        favoriteButton.image = favIcon
        favoriteButton.imagePosition = .imageLeft
        favoriteButton.contentTintColor = .secondaryLabelColor
        addSubview(favoriteButton)

        copyAllButton.translatesAutoresizingMaskIntoConstraints = false
        copyAllButton.bezelStyle = .rounded
        copyAllButton.isBordered = false
        copyAllButton.title = "复制全部"
        copyAllButton.target = self
        copyAllButton.action = #selector(copyAllClicked)
        let copyConfig = NSImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let copyIcon = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "复制")?.withSymbolConfiguration(copyConfig)
        copyAllButton.image = copyIcon
        copyAllButton.imagePosition = .imageLeft
        copyAllButton.contentTintColor = .secondaryLabelColor
        addSubview(copyAllButton)

        // KeyHub 按钮
        keyhubButton.translatesAutoresizingMaskIntoConstraints = false
        keyhubButton.bezelStyle = .rounded
        keyhubButton.isBordered = false
        keyhubButton.title = "查快捷键"
        keyhubButton.target = self
        keyhubButton.action = #selector(keyhubClicked)
        let keyhubConfig = NSImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let keyhubIcon = NSImage(systemSymbolName: "arrow.up.right.square", accessibilityDescription: "查快捷键")?.withSymbolConfiguration(keyhubConfig)
        keyhubButton.image = keyhubIcon
        keyhubButton.imagePosition = .imageLeft
        keyhubButton.contentTintColor = .secondaryLabelColor
        addSubview(keyhubButton)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 28),

            scrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: favoriteButton.topAnchor, constant: -12),

            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            favoriteButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            favoriteButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            favoriteButton.heightAnchor.constraint(equalToConstant: 28),

            keyhubButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            keyhubButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            keyhubButton.heightAnchor.constraint(equalToConstant: 28),

            copyAllButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            copyAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            copyAllButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    // MARK: - 公开方法

    /// 配置详情页内容
    func configure(with item: ContentItem, commandDetail: CommandDetail? = nil, errorDetail: ErrorDetail? = nil, relatedItems: [ContentItem] = []) {
        self.item = item

        titleLabel.stringValue = item.title
        chineseTitleLabel.stringValue = item.chineseTitle
        typeTag.text = item.type.displayName
        typeTag.textColor = item.type.color
        typeTag.backgroundColor = item.type.color.withAlphaComponent(0.12)
        summaryLabel.stringValue = item.summary

        // 清空之前的详情内容（保留前 5 个：标题、中文标题、类型标签、摘要、分隔线）
        while contentStackView.arrangedSubviews.count > 5 {
            if let view = contentStackView.arrangedSubviews.last {
                contentStackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }

        // 根据类型渲染详情
        if let commandDetail = commandDetail {
            renderCommandDetail(commandDetail)
        } else if let errorDetail = errorDetail {
            renderErrorDetail(errorDetail)
        }

        // 所有类型末尾统一渲染关联内容
        currentRelatedItems = relatedItems
        if !relatedItems.isEmpty {
            renderRelatedItems(relatedItems)
        }
    }

    /// 设置收藏状态
    func setFavorite(_ favorite: Bool) {
        isFavorite = favorite
        let config = NSImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let iconName = favorite ? "star.fill" : "star"
        let icon = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)?.withSymbolConfiguration(config)
        favoriteButton.image = icon
        favoriteButton.contentTintColor = favorite ? NSColor.systemYellow : .secondaryLabelColor
    }

    // MARK: - 渲染详情

    private func renderCommandDetail(_ detail: CommandDetail) {
        // 语法
        addSectionTitle("语法")
        for syntax in detail.syntax {
            addCodeBlock(syntax)
        }

        // 参数
        if !detail.parameters.isEmpty {
            addSectionTitle("参数说明")
            for param in detail.parameters {
                let text = "\(param.name)\(param.required ? "（必填）" : "（可选）")：\(param.description)\(param.defaultValue != nil ? "，默认：\(param.defaultValue!)" : "")"
                addTextBlock(text)
            }
        }

        // 示例
        if !detail.examples.isEmpty {
            addSectionTitle("示例")
            for example in detail.examples {
                addTextBlock(example.description)
                addCodeBlock(example.code)
            }
        }

        // 注意事项
        if !detail.notes.isEmpty {
            addSectionTitle("注意事项")
            for (index, note) in detail.notes.enumerated() {
                addTextBlock("\(index + 1). \(note)")
            }
        }
    }

    private func renderErrorDetail(_ detail: ErrorDetail) {
        // 错误类别
        addSectionTitle("错误类别")
        addTextBlock(detail.category)

        // 原因分析
        addSectionTitle("原因分析")
        addTextBlock(detail.cause)

        // 解决方案
        if !detail.solutions.isEmpty {
            addSectionTitle("解决方案")
            for (index, solution) in detail.solutions.enumerated() {
                addTextBlock("\(index + 1). \(solution)")
            }
        }

        // 可复制指令
        if !detail.copyableCommands.isEmpty {
            addSectionTitle("可复制指令")
            for command in detail.copyableCommands {
                addCodeBlock(command)
            }
        }
    }

    private func renderGenericDetail(_ item: ContentItem) {
        // 通用详情已由 relatedItems 统一处理，此方法保留为空
    }

    /// 渲染关联内容（可点击跳转）
    private func renderRelatedItems(_ items: [ContentItem]) {
        addSectionTitle("相关内容")

        for (index, relatedItem) in items.enumerated() {
            let button = NSButton(title: "", target: self, action: #selector(relatedItemClicked(_:)))
            button.translatesAutoresizingMaskIntoConstraints = false
            button.bezelStyle = .rounded
            button.isBordered = false
            button.alignment = .left
            button.tag = index

            // 标题 + 类型标签
            let title = relatedItem.title
            let typeName = relatedItem.type.displayName
            let attributedTitle = NSMutableAttributedString(string: "\(title)  ", attributes: [
                .font: NSFont.systemFont(ofSize: 13, weight: .medium),
                .foregroundColor: NSColor.labelColor
            ])
            attributedTitle.append(NSAttributedString(string: "(\(typeName))", attributes: [
                .font: NSFont.systemFont(ofSize: 11, weight: .regular),
                .foregroundColor: NSColor.secondaryLabelColor
            ]))
            button.attributedTitle = attributedTitle
            button.contentTintColor = NSColor(calibratedRed: 1.0, green: 0.584, blue: 0.0, alpha: 1.0)

            contentStackView.addArrangedSubview(button)
            button.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor, constant: 4).isActive = true
        }
    }

    @objc private func relatedItemClicked(_ sender: NSButton) {
        guard sender.tag >= 0 && sender.tag < currentRelatedItems.count else { return }
        let item = currentRelatedItems[sender.tag]
        onRelatedItemClick?(item)
    }

    // MARK: - 辅助方法

    private func addSectionTitle(_ title: String) {
        let label = NSTextField(labelWithString: title)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = NSColor(calibratedRed: 1.0, green: 0.584, blue: 0.0, alpha: 1.0)
        contentStackView.addArrangedSubview(label)
    }

    private func addTextBlock(_ text: String) {
        let label = NSTextField(labelWithString: text)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .labelColor
        label.lineBreakMode = .byWordWrapping
        label.maximumNumberOfLines = 0
        label.preferredMaxLayoutWidth = 500
        contentStackView.addArrangedSubview(label)
    }

    private func addCodeBlock(_ code: String) {
        let codeView = CopyableCodeView()
        codeView.translatesAutoresizingMaskIntoConstraints = false
        codeView.code = code
        contentStackView.addArrangedSubview(codeView)
        codeView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor).isActive = true
        let height = CopyableCodeView.preferredHeight(for: code, width: 500)
        codeView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    // MARK: - 动作

    @objc private func backClicked() {
        onBack?()
    }

    @objc private func favoriteClicked() {
        guard let item = item else { return }
        setFavorite(!isFavorite)
        onFavorite?(item)
    }

    @objc private func copyAllClicked() {
        guard let item = item else { return }
        onCopyAll?(item)
    }

    @objc private func keyhubClicked() {
        onKeyHub?()
    }
}
