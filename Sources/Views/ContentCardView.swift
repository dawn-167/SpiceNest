import Cocoa

// MARK: - 内容卡片视图

/// 搜索结果卡片：类型图标 + 标题 + 中文标题 + 摘要 + 关键信息预览 + 复制按钮
/// 悬停效果：上浮 3pt + 阴影加深 + 1pt 琥珀色边框 + 手型光标
final class ContentCardView: NSView {
    // MARK: - 回调

    /// 点击卡片回调
    var onClick: ((ContentItem) -> Void)?

    /// 点击复制按钮回调
    var onCopy: ((ContentItem) -> Void)?

    // MARK: - 属性

    private let iconView = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let chineseTitleLabel = NSTextField(labelWithString: "")
    private let previewLabel = NSTextField(labelWithString: "")
    private let summaryLabel = NSTextField(labelWithString: "")
    private let typeTag = TagView()
    private let copyButton = NSButton()

    private var item: ContentItem?
    private var trackingArea: NSTrackingArea?

    // MARK: - 初始化

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
        setupTrackingArea()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI 设置

    private func setupUI() {
        wantsLayer = true
        layer?.cornerRadius = 10
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.clear.cgColor
        // 默认阴影（规范 0 1pt 4pt rgba(0,0,0,0.06)）
        layer?.shadowColor = NSColor.black.cgColor
        layer?.shadowOpacity = 0.06
        layer?.shadowRadius = 4
        layer?.shadowOffset = CGSize(width: 0, height: -1)

        // 类型图标
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.imageScaling = .scaleProportionallyUpOrDown
        addSubview(iconView)

        // 标题（14pt Semibold Code 字体）
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = NSFont(name: "SF Mono", size: 14) ?? NSFont.monospacedSystemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.maximumNumberOfLines = 1
        addSubview(titleLabel)

        // 中文标题（13pt Body）
        chineseTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        chineseTitleLabel.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        chineseTitleLabel.textColor = .secondaryLabelColor
        chineseTitleLabel.lineBreakMode = .byTruncatingTail
        chineseTitleLabel.maximumNumberOfLines = 1
        addSubview(chineseTitleLabel)

        // 关键信息预览（第三行，11pt Code 字体）
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        previewLabel.font = NSFont(name: "SF Mono", size: 11) ?? NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        previewLabel.textColor = .tertiaryLabelColor
        previewLabel.lineBreakMode = .byTruncatingTail
        previewLabel.maximumNumberOfLines = 1
        addSubview(previewLabel)

        // 摘要（11pt Small 1行省略）
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.font = NSFont.systemFont(ofSize: 11, weight: .regular)
        summaryLabel.textColor = .tertiaryLabelColor
        summaryLabel.lineBreakMode = .byTruncatingTail
        summaryLabel.maximumNumberOfLines = 1
        addSubview(summaryLabel)

        // 复制按钮
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.bezelStyle = .rounded
        copyButton.isBordered = false
        copyButton.target = self
        copyButton.action = #selector(copyButtonClicked)
        let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        let copyIcon = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "复制")?.withSymbolConfiguration(config)
        copyButton.image = copyIcon
        copyButton.imagePosition = .imageOnly
        copyButton.contentTintColor = .secondaryLabelColor
        copyButton.isHidden = true
        addSubview(copyButton)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 图标（左 14pt，上 14pt）
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            // 标题（第一行）
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -8),

            // 中文标题（第二行）
            chineseTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            chineseTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            chineseTitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            // 关键信息预览（第三行）
            previewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            previewLabel.topAnchor.constraint(equalTo: chineseTitleLabel.bottomAnchor, constant: 4),
            previewLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            // 摘要（第四行）
            summaryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            summaryLabel.topAnchor.constraint(equalTo: previewLabel.bottomAnchor, constant: 4),
            summaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            summaryLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),

            // 复制按钮（右上 14pt）
            copyButton.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            copyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            copyButton.widthAnchor.constraint(equalToConstant: 28),
            copyButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    // MARK: - 跟踪区域

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

    // MARK: - 公开方法

    /// 配置卡片内容
    func configure(with item: ContentItem) {
        self.item = item

        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let icon = NSImage(systemSymbolName: item.type.iconName, accessibilityDescription: nil)?.withSymbolConfiguration(config)
        iconView.image = icon
        iconView.contentTintColor = item.type.color

        titleLabel.stringValue = item.title
        chineseTitleLabel.stringValue = item.chineseTitle
        previewLabel.stringValue = item.preview ?? ""
        summaryLabel.stringValue = item.summary
    }

    // MARK: - 鼠标事件

    override func mouseEntered(with event: NSEvent) {
        applyHoverState(true)
    }

    override func mouseExited(with event: NSEvent) {
        applyHoverState(false)
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        // 点击缩放 0.98
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.1
            context.allowsImplicitAnimation = true
            layer?.transform = CATransform3DMakeScale(0.98, 0.98, 1)
        }
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        // 恢复缩放
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.1
            context.allowsImplicitAnimation = true
            layer?.transform = CATransform3DIdentity
        }

        guard let item = item else { return }
        // 检查是否点击了复制按钮
        let copyButtonPoint = convert(event.locationInWindow, from: nil)
        if copyButton.frame.contains(copyButtonPoint) {
            onCopy?(item)
            return
        }
        onClick?(item)
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }

    // MARK: - 悬停状态

    /// 应用悬停状态（公开方法，供外部调用以修复滚轮滚动时的跟踪区域丢失问题）
    func applyHoverState(_ hovering: Bool) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            context.allowsImplicitAnimation = true

            if hovering {
                layer?.borderColor = NSColor(calibratedRed: 1.0, green: 0.584, blue: 0.0, alpha: 0.6).cgColor
                layer?.shadowColor = NSColor.black.cgColor
                layer?.shadowOpacity = 0.15
                layer?.shadowRadius = 8
                layer?.shadowOffset = CGSize(width: 0, height: -3)
                // 用 layer.transform 上移 3pt，替代 setFrameOrigin 避免布局抖动
                layer?.transform = CATransform3DMakeTranslation(0, 3, 0)
                copyButton.isHidden = false
            } else {
                layer?.borderColor = NSColor.clear.cgColor
                // 恢复默认阴影
                layer?.shadowColor = NSColor.black.cgColor
                layer?.shadowOpacity = 0.06
                layer?.shadowRadius = 4
                layer?.shadowOffset = CGSize(width: 0, height: -1)
                layer?.transform = CATransform3DIdentity
                copyButton.isHidden = true
            }
        }
    }

    // MARK: - 动作

    @objc private func copyButtonClicked() {
        guard let item = item else { return }
        onCopy?(item)
    }
}
