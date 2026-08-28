import Cocoa

// MARK: - 搜索框视图

/// 搜索框组件，自定义样式，自动聚焦，实时搜索回调，清除按钮
final class SearchFieldView: NSView {
    // MARK: - 回调

    /// 搜索文本变化回调（带 100ms 节流）
    var onTextChange: ((String) -> Void)?

    /// 按下回车键回调
    var onEnter: ((String) -> Void)?

    /// 按下 Esc 键回调
    var onEscape: (() -> Void)?

    /// 按下上下箭头回调
    var onArrowKey: ((KeyDirection) -> Void)?

    enum KeyDirection {
        case up, down
    }

    // MARK: - 属性

    private let backgroundView = NSView()
    private let iconView = NSImageView()
    private let textField = NSTextField()
    private let clearButton = NSButton()
    private var debounceTimer: Timer?

    var text: String {
        get { textField.stringValue }
        set {
            textField.stringValue = newValue
            updateClearButtonVisibility()
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
        wantsLayer = false

        // 背景视图（渐变 + 圆角 + 边框 + 内阴影）
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = 10
        // 渐变背景（顶亮底暗，增强立体感）
        let gradient = CAGradientLayer()
        gradient.colors = [
            NSColor(white: 0.99, alpha: 1.0).cgColor,
            NSColor(white: 0.96, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.cornerRadius = 10
        backgroundView.layer?.insertSublayer(gradient, at: 0)
        backgroundView.layer?.borderWidth = 1
        backgroundView.layer?.borderColor = NSColor.separatorColor.cgColor
        addSubview(backgroundView)

        // 左侧放大镜图标
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let icon = NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: "搜索")?.withSymbolConfiguration(config)
        iconView.image = icon
        iconView.contentTintColor = NSColor(calibratedRed: 1.0, green: 0.584, blue: 0.0, alpha: 1.0)
        backgroundView.addSubview(iconView)

        // 文本字段
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholderString = "搜索指令、参数、报错、公式…"
        textField.font = NSFont.systemFont(ofSize: 14)
        textField.textColor = .labelColor
        textField.backgroundColor = .clear
        textField.bezelStyle = .squareBezel
        textField.isBordered = false
        textField.focusRingType = .none
        textField.delegate = self
        textField.target = self
        textField.action = #selector(textFieldAction)
        textField.cell?.usesSingleLineMode = true
        textField.cell?.lineBreakMode = .byTruncatingTail
        backgroundView.addSubview(textField)

        // 清除按钮
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.bezelStyle = .rounded
        clearButton.isBordered = false
        clearButton.title = ""
        clearButton.target = self
        clearButton.action = #selector(clearClicked)
        let clearConfig = NSImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let clearIcon = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: "清除")?.withSymbolConfiguration(clearConfig)
        clearButton.image = clearIcon
        clearButton.imagePosition = .imageOnly
        clearButton.contentTintColor = .tertiaryLabelColor
        clearButton.isHidden = true
        backgroundView.addSubview(clearButton)

        // 约束
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 36),

            iconView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            textField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -8),
            textField.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 22),

            clearButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8),
            clearButton.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 20),
            clearButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    // MARK: - 公开方法

    /// 聚焦搜索框
    func focus() {
        window?.makeFirstResponder(textField)
    }

    /// 清除搜索内容
    func clear() {
        textField.stringValue = ""
        updateClearButtonVisibility()
        onTextChange?("")
    }

    // MARK: - 动作

    @objc private func textFieldAction() {
        onEnter?(textField.stringValue)
    }

    @objc private func clearClicked() {
        clear()
        focus()
    }

    // MARK: - 聚焦态样式

    private func updateFocusStyle(_ focused: Bool) {
        if focused {
            backgroundView.layer?.borderColor = NSColor(calibratedRed: 1.0, green: 0.584, blue: 0.0, alpha: 1.0).cgColor
            backgroundView.layer?.shadowColor = NSColor(calibratedRed: 1.0, green: 0.584, blue: 0.0, alpha: 0.3).cgColor
            backgroundView.layer?.shadowOpacity = 1.0
            backgroundView.layer?.shadowRadius = 3
            backgroundView.layer?.shadowOffset = CGSize(width: 0, height: 0)
        } else {
            backgroundView.layer?.borderColor = NSColor.separatorColor.cgColor
            backgroundView.layer?.shadowOpacity = 0
        }
    }

    private func updateClearButtonVisibility() {
        clearButton.isHidden = textField.stringValue.isEmpty
    }

    // MARK: - 节流

    private func debounceSearch(_ text: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
            self?.onTextChange?(text)
        }
    }
}

// MARK: - NSTextFieldDelegate

extension SearchFieldView: NSTextFieldDelegate {
    func controlTextDidBeginEditing(_ obj: Notification) {
        updateFocusStyle(true)
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        updateFocusStyle(false)
    }

    func controlTextDidChange(_ obj: Notification) {
        updateClearButtonVisibility()
        debounceSearch(textField.stringValue)
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            onEnter?(textField.stringValue)
            return true
        }
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            onEscape?()
            return true
        }
        if commandSelector == #selector(NSResponder.moveUp(_:)) {
            onArrowKey?(.up)
            return true
        }
        if commandSelector == #selector(NSResponder.moveDown(_:)) {
            onArrowKey?(.down)
            return true
        }
        return false
    }
}
