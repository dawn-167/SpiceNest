import Cocoa

// MARK: - 分类标签视图

/// 自定义分类标签：类型图标 + 文字 + 锁徽章（P-029 / P-033）
/// 支持默认（类型色描边）/悬停（类型色浅填充）/按下/选中/禁用（灰字+锁）状态
final class CategoryTagView: NSView {
    // MARK: - 回调

    /// 点击回调
    var onClick: (() -> Void)?

    // MARK: - 属性

    private let iconView = NSImageView()
    private let label = NSTextField(labelWithString: "")
    private let lockView = NSImageView()
    private var trackingArea: NSTrackingArea?

    /// 类型主题色
    private var typeColor: NSColor = NSColor(calibratedRed: 1.0, green: 0.584, blue: 0.0, alpha: 1.0)

    /// 标签文字
    var text: String = "" {
        didSet { label.stringValue = text }
    }

    /// 内容类型（决定图标与主题色）
    var contentType: ContentType? {
        didSet {
            guard let type = contentType else { return }
            let config = NSImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            iconView.image = NSImage(systemSymbolName: type.iconName, accessibilityDescription: nil)?.withSymbolConfiguration(config)
            typeColor = type.color
            updateStyle()
        }
    }

    /// 是否启用
    var isEnabled: Bool = true {
        didSet { updateStyle() }
    }

    /// 是否选中
    var isSelected: Bool = false {
        didSet { updateStyle() }
    }

    /// 是否悬停
    private var isHovering: Bool = false {
        didSet { updateStyle() }
    }

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
        layer?.cornerRadius = 15
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.clear.cgColor

        // 类型图标
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.imageScaling = .scaleProportionallyUpOrDown
        addSubview(iconView)

        // 文字
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        label.alignment = .center
        addSubview(label)

        // 锁徽章（禁用态显示，P-033）
        lockView.translatesAutoresizingMaskIntoConstraints = false
        let lockConfig = NSImage.SymbolConfiguration(pointSize: 9, weight: .medium)
        lockView.image = NSImage(systemSymbolName: "lock.fill", accessibilityDescription: nil)?.withSymbolConfiguration(lockConfig)
        lockView.contentTintColor = .tertiaryLabelColor
        lockView.isHidden = true
        addSubview(lockView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 30),

            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 14),
            iconView.heightAnchor.constraint(equalToConstant: 14),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),

            lockView.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 6),
            lockView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            lockView.centerYAnchor.constraint(equalTo: centerYAnchor),
            lockView.widthAnchor.constraint(equalToConstant: 10),
            lockView.heightAnchor.constraint(equalToConstant: 10)
        ])

        updateStyle()
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

    // MARK: - 样式更新

    private func updateStyle() {
        if !isEnabled {
            // 禁用态：无描边无填充，灰字 + 锁徽章
            layer?.backgroundColor = NSColor.clear.cgColor
            layer?.borderColor = NSColor.clear.cgColor
            layer?.borderWidth = 1
            label.textColor = .tertiaryLabelColor
            iconView.contentTintColor = .tertiaryLabelColor
            lockView.isHidden = false
            toolTip = "第二阶段上线"
        } else {
            lockView.isHidden = true
            toolTip = nil
            iconView.contentTintColor = typeColor

            if isSelected {
                // 选中态：类型色填充 0.20 + 1.5pt 描边
                layer?.backgroundColor = typeColor.withAlphaComponent(0.20).cgColor
                layer?.borderColor = typeColor.withAlphaComponent(0.8).cgColor
                layer?.borderWidth = 1.5
                label.textColor = typeColor
            } else if isHovering {
                // 悬停态：类型色填充 0.12 + 文字变类型色
                layer?.backgroundColor = typeColor.withAlphaComponent(0.12).cgColor
                layer?.borderColor = typeColor.withAlphaComponent(0.6).cgColor
                layer?.borderWidth = 1
                label.textColor = typeColor
            } else {
                // 默认态：透明底 + 1pt 类型色描边，看起来像可点的胶囊
                layer?.backgroundColor = NSColor.clear.cgColor
                layer?.borderColor = typeColor.withAlphaComponent(0.35).cgColor
                layer?.borderWidth = 1
                label.textColor = .secondaryLabelColor
            }
        }
    }

    // MARK: - 鼠标事件

    override func mouseEntered(with event: NSEvent) {
        guard isEnabled else { return }
        isHovering = true
    }

    override func mouseExited(with event: NSEvent) {
        isHovering = false
    }

    override func mouseDown(with event: NSEvent) {
        guard isEnabled else { return }
        // 按下态：加深填充
        layer?.backgroundColor = typeColor.withAlphaComponent(0.20).cgColor
    }

    override func mouseUp(with event: NSEvent) {
        guard isEnabled else { return }
        isHovering = false
        onClick?()
    }

    override func resetCursorRects() {
        if isEnabled {
            addCursorRect(bounds, cursor: .pointingHand)
        }
    }
}
