import Cocoa

// MARK: - 分类标签视图

/// 自定义分类标签，支持默认/悬停/按下/选中/禁用状态
final class CategoryTagView: NSView {
    // MARK: - 回调

    /// 点击回调
    var onClick: (() -> Void)?

    // MARK: - 属性

    private let label = NSTextField(labelWithString: "")
    private var trackingArea: NSTrackingArea?

    /// 标签文字
    var text: String = "" {
        didSet { label.stringValue = text }
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
        layer?.cornerRadius = 6
        layer?.borderWidth = 0

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        label.alignment = .center
        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
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
        let amber = NSColor(calibratedRed: 1.0, green: 0.584, blue: 0.0, alpha: 1.0)

        if !isEnabled {
            // 禁用态：次文字色，可视但不可点
            layer?.backgroundColor = NSColor.clear.cgColor
            label.textColor = .tertiaryLabelColor
            layer?.shadowOpacity = 0
        } else if isSelected {
            // 选中态：琥珀色背景 alpha 0.12，文字琥珀色，发光效果
            layer?.backgroundColor = amber.withAlphaComponent(0.12).cgColor
            label.textColor = amber
            layer?.shadowColor = amber.cgColor
            layer?.shadowOpacity = 0.25
            layer?.shadowRadius = 6
            layer?.shadowOffset = CGSize(width: 0, height: 0)
        } else if isHovering {
            // 悬停态：琥珀色背景 alpha 0.08，文字琥珀色，轻微发光
            layer?.backgroundColor = amber.withAlphaComponent(0.08).cgColor
            label.textColor = amber
            layer?.shadowColor = amber.cgColor
            layer?.shadowOpacity = 0.15
            layer?.shadowRadius = 4
            layer?.shadowOffset = CGSize(width: 0, height: 0)
        } else {
            // 默认态：透明背景，次文字色
            layer?.backgroundColor = NSColor.clear.cgColor
            label.textColor = .secondaryLabelColor
            layer?.shadowOpacity = 0
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
        // 按下态：稍微加深背景
        let amber = NSColor(calibratedRed: 1.0, green: 0.584, blue: 0.0, alpha: 1.0)
        layer?.backgroundColor = amber.withAlphaComponent(0.18).cgColor
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
