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

    // MARK: - UI 设置

    private func setupUI() {
        wantsLayer = true
        layer?.cornerRadius = 6
        layer?.backgroundColor = NSColor(calibratedRed: 0.12, green: 0.12, blue: 0.14, alpha: 1.0).cgColor

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
