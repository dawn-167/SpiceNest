import Cocoa

// MARK: - 可复制代码块视图

/// 深色背景代码块，右上角复制按钮，复制成功变对勾，2秒后恢复
final class CopyableCodeView: NSView {
    // MARK: - 回调

    /// 复制完成回调
    var onCopy: (() -> Void)?

    // MARK: - 属性

    private let textView = NSTextView()
    private let copyButton = NSButton()
    private var isCopied = false

    var code: String = "" {
        didSet {
            textView.string = code
            updateVisibility()
        }
    }

    // MARK: - 初始化

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        // 更新渐变层和高光线层的 frame
        guard let sublayers = layer?.sublayers, sublayers.count >= 2 else { return }
        if let gradient = sublayers[0] as? CAGradientLayer {
            gradient.frame = bounds
        }
        let highlight = sublayers[1]
        highlight.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
    }

    // MARK: - UI 设置

    private func setupUI() {
        wantsLayer = true
        layer?.cornerRadius = 6
        layer?.masksToBounds = false
        // 大阴影（立体感）
        layer?.shadowColor = NSColor.black.cgColor
        layer?.shadowOpacity = 0.15
        layer?.shadowRadius = 6
        layer?.shadowOffset = CGSize(width: 0, height: -2)

        // 渐变背景（顶亮底暗，增强立体感）
        let gradient = CAGradientLayer()
        gradient.cornerRadius = 6
        gradient.colors = [
            NSColor(calibratedRed: 0.15, green: 0.15, blue: 0.17, alpha: 1.0).cgColor,
            NSColor(calibratedRed: 0.10, green: 0.10, blue: 0.12, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        layer?.insertSublayer(gradient, at: 0)

        // 顶部高光线（增强立体感）
        let highlight = CALayer()
        highlight.backgroundColor = NSColor.white.withAlphaComponent(0.08).cgColor
        highlight.cornerRadius = 6
        highlight.masksToBounds = true
        layer?.insertSublayer(highlight, above: gradient)
        highlight.frame = CGRect(x: 0, y: 0, width: 0, height: 1) // 会在 layout 中更新

        // 文本视图（直接使用，不包 ScrollView）
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.font = NSFont(name: "SF Mono", size: 12) ?? NSFont.userFixedPitchFont(ofSize: 12)
        textView.textColor = NSColor(calibratedRed: 0.85, green: 0.85, blue: 0.88, alpha: 1.0)
        textView.textContainerInset = NSSize(width: 12, height: 10)
        textView.isHorizontallyResizable = true
        textView.autoresizingMask = [.width, .height]
        addSubview(textView)

        // 复制按钮
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.bezelStyle = .rounded
        copyButton.title = ""
        copyButton.isBordered = false
        copyButton.target = self
        copyButton.action = #selector(copyCode)
        let config = NSImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let copyIcon = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "复制")?.withSymbolConfiguration(config)
        copyButton.image = copyIcon
        copyButton.imagePosition = .imageOnly
        copyButton.contentTintColor = .secondaryLabelColor
        addSubview(copyButton)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),

            copyButton.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            copyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            copyButton.widthAnchor.constraint(equalToConstant: 24),
            copyButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        updateVisibility()
    }

    private func updateVisibility() {
        isHidden = code.isEmpty
    }

    // MARK: - 复制动作

    @objc private func copyCode() {
        guard !code.isEmpty else { return }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(code, forType: .string)

        // 切换到对勾图标
        isCopied = true
        let config = NSImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let checkIcon = NSImage(systemSymbolName: "checkmark", accessibilityDescription: "已复制")?.withSymbolConfiguration(config)
        copyButton.image = checkIcon
        copyButton.contentTintColor = NSColor.systemGreen

        onCopy?()

        // 2秒后恢复
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self, self.isCopied else { return }
            self.isCopied = false
            let config = NSImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            let copyIcon = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "复制")?.withSymbolConfiguration(config)
            self.copyButton.image = copyIcon
            self.copyButton.contentTintColor = .secondaryLabelColor
        }
    }

    // MARK: - 高度计算

    /// 根据代码内容计算合适的高度
    static func preferredHeight(for code: String, width: CGFloat) -> CGFloat {
        let lines = code.components(separatedBy: .newlines).count
        let lineHeight: CGFloat = 18
        let padding: CGFloat = 20
        return max(CGFloat(lines) * lineHeight + padding, 40)
    }
}
