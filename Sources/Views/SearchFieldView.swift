import Cocoa

// MARK: - 搜索框视图

/// 搜索框组件，自动聚焦，实时搜索回调，清除按钮
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

    private let searchField = NSSearchField()
    private var debounceTimer: Timer?

    var text: String {
        get { searchField.stringValue }
        set { searchField.stringValue = newValue }
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

        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholderString = "搜索指令、参数、错误、公式..."
        searchField.font = NSFont.systemFont(ofSize: 14)
        searchField.bezelStyle = .roundedBezel
        searchField.focusRingType = .none
        searchField.delegate = self
        searchField.target = self
        searchField.action = #selector(searchFieldAction)
        addSubview(searchField)

        NSLayoutConstraint.activate([
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            searchField.centerYAnchor.constraint(equalTo: centerYAnchor),
            searchField.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    // MARK: - 公开方法

    /// 聚焦搜索框
    func focus() {
        window?.makeFirstResponder(searchField)
    }

    /// 清除搜索内容
    func clear() {
        searchField.stringValue = ""
        onTextChange?("")
    }

    // MARK: - 动作

    @objc private func searchFieldAction() {
        onEnter?(searchField.stringValue)
    }

    // MARK: - 节流

    private func debounceSearch(_ text: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
            self?.onTextChange?(text)
        }
    }
}

// MARK: - NSSearchFieldDelegate

extension SearchFieldView: NSSearchFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        debounceSearch(searchField.stringValue)
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            onEnter?(searchField.stringValue)
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
