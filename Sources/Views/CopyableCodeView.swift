import Cocoa

// MARK: - 代码块视图

/// 深色背景代码块，文本可选中复制（P-054：移除悬浮复制按钮，复制走"选中 + ⌘C"或详情页整体操作）
final class CopyableCodeView: NSView {
    // MARK: - 属性

    private let textView = NSTextView()

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
        // 高光线贴代码块顶缘（图层坐标未翻转时 y=0 是底缘，P-051）
        let highlightY: CGFloat = (layer?.isGeometryFlipped == true) ? 0 : max(bounds.height - 1, 0)
        let highlight = sublayers[1]
        highlight.frame = CGRect(x: 0, y: highlightY, width: bounds.width, height: 1)
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
        // 渐变起点 (0,0) 在非翻转图层坐标中是底缘，颜色顺序需底→顶（P-051）
        gradient.colors = [
            NSColor(calibratedRed: 0.10, green: 0.10, blue: 0.12, alpha: 1.0).cgColor,
            NSColor(calibratedRed: 0.15, green: 0.15, blue: 0.17, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        layer?.insertSublayer(gradient, at: 0)

        // 顶部高光线（增强立体感）
        let highlight = CALayer()
        highlight.backgroundColor = NSColor.white.withAlphaComponent(0.12).cgColor
        highlight.cornerRadius = 0
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

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        updateVisibility()
    }

    private func updateVisibility() {
        isHidden = code.isEmpty
    }

    // MARK: - 高度计算

    /// 根据代码内容计算合适的高度
    static func preferredHeight(for code: String) -> CGFloat {
        let lines = code.components(separatedBy: .newlines).count
        let lineHeight: CGFloat = 18
        let padding: CGFloat = 20
        return max(CGFloat(lines) * lineHeight + padding, 40)
    }
}
