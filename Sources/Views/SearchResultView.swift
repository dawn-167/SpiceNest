import Cocoa

// MARK: - 搜索结果页视图

/// 搜索结果页：顶部搜索框 + 按类型分组的结果列表 + 空状态 + 键盘选择
final class SearchResultView: NSView {
    // MARK: - 回调

    /// 搜索框文本变化回调
    var onSearchTextChange: ((String) -> Void)?

    /// 按下回车键回调
    var onSearchEnter: ((String) -> Void)?

    /// 按下 Esc 回调
    var onEscape: (() -> Void)?

    /// 点击结果卡片回调
    var onItemClick: ((ContentItem) -> Void)?

    /// 点击复制按钮回调
    var onItemCopy: ((ContentItem) -> Void)?

    // MARK: - 属性

    private let searchField = SearchFieldView()
    private let scrollView = NSScrollView()
    private let stackView = NSStackView()
    private let emptyState = EmptyStateView()

    private var results: [ContentType: [ContentItem]] = [:]
    private var flatResults: [ContentItem] = []
    private var selectedIndex: Int = -1
    private var cardViews: [ContentCardView] = []
    private var hoverTimer: Timer?

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

        // 搜索框
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.onTextChange = { [weak self] text in
            self?.onSearchTextChange?(text)
        }
        searchField.onEnter = { [weak self] text in
            guard let self = self else { return }
            // 有选中项时 Enter 打开选中项，否则重新搜索
            if let selected = self.selectedItem {
                self.onItemClick?(selected)
            } else {
                self.onSearchEnter?(text)
            }
        }
        searchField.onEscape = { [weak self] in
            self?.onEscape?()
        }
        searchField.onArrowKey = { [weak self] direction in
            self?.handleArrowKey(direction)
        }
        addSubview(searchField)

        // 滚动视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.automaticallyAdjustsContentInsets = false
        addSubview(scrollView)

        // 堆栈视图（容器）
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.orientation = .vertical
        stackView.spacing = 0
        stackView.alignment = .leading
        scrollView.documentView = stackView

        // 空状态
        emptyState.translatesAutoresizingMaskIntoConstraints = false
        emptyState.titleText = "未找到相关内容"
        emptyState.subtitleText = "试试其他关键词，或检查拼写"
        emptyState.isHidden = true
        addSubview(emptyState)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchField.heightAnchor.constraint(equalToConstant: 36),

            scrollView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            emptyState.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 40),
            emptyState.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyState.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyState.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - 公开方法

    /// 更新搜索结果
    func updateResults(_ groupedResults: [ContentType: [ContentItem]], query: String) {
        self.results = groupedResults
        self.flatResults = groupedResults.values.flatMap { $0 }
        self.selectedIndex = -1
        self.cardViews = []

        // 清空堆栈视图
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        // 显示空状态或结果列表
        if flatResults.isEmpty {
            emptyState.isHidden = false
            scrollView.isHidden = true
            stopHoverTimer()
        } else {
            emptyState.isHidden = true
            scrollView.isHidden = false
            renderResults()
            startHoverTimer()
        }

        // 更新搜索框文本
        searchField.text = query
    }

    /// 聚焦搜索框
    func focusSearchField() {
        searchField.focus()
    }

    /// 获取搜索框文本
    var searchText: String {
        return searchField.text
    }

    // MARK: - 渲染结果

    private func renderResults() {
        let sortedTypes = ContentType.allCases.filter { results[$0] != nil && !results[$0]!.isEmpty }

        for type in sortedTypes {
            guard let items = results[type], !items.isEmpty else { continue }

            // 分组标题
            let header = SectionHeaderView()
            header.title = type.displayName
            header.count = items.count
            header.contentType = type
            header.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(header)
            NSLayoutConstraint.activate([
                header.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                header.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                header.heightAnchor.constraint(equalToConstant: 28)
            ])

            // 结果卡片
            for item in items {
                let card = ContentCardView()
                card.configure(with: item)
                card.translatesAutoresizingMaskIntoConstraints = false
                card.onClick = { [weak self] item in
                    self?.onItemClick?(item)
                }
                card.onCopy = { [weak self] item in
                    self?.onItemCopy?(item)
                }
                stackView.addArrangedSubview(card)
                NSLayoutConstraint.activate([
                    card.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 12),
                    card.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -12),
                    card.heightAnchor.constraint(greaterThanOrEqualToConstant: 90)
                ])
                cardViews.append(card)
            }

            // 分组间距
            let spacer = NSView()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(spacer)
            spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
        }
    }

    // MARK: - 键盘操作

    private func handleArrowKey(_ direction: SearchFieldView.KeyDirection) {
        guard !flatResults.isEmpty else { return }

        switch direction {
        case .down:
            selectedIndex = min(selectedIndex + 1, flatResults.count - 1)
        case .up:
            selectedIndex = max(selectedIndex - 1, 0)
        }

        updateSelectionHighlight()
    }

    private func updateSelectionHighlight() {
        for (index, card) in cardViews.enumerated() {
            if index == selectedIndex {
                card.applyHoverState(true)
                // 滚动到可见区域
                scrollView.scrollToVisible(card.frame)
            } else {
                card.applyHoverState(false)
            }
        }
    }

    /// 获取当前选中的内容项
    var selectedItem: ContentItem? {
        guard selectedIndex >= 0 && selectedIndex < flatResults.count else { return nil }
        return flatResults[selectedIndex]
    }

    // MARK: - 悬停状态全局监听（滚轮兜底）

    private func startHoverTimer() {
        stopHoverTimer()
        let timer = Timer(timeInterval: 0.08, target: self, selector: #selector(checkHoverState), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        hoverTimer = timer
    }

    private func stopHoverTimer() {
        hoverTimer?.invalidate()
        hoverTimer = nil
    }

    @objc private func checkHoverState() {
        // 视图不在窗口中时停止 Timer
        guard window != nil, !isHidden else {
            stopHoverTimer()
            return
        }

        let mouseLocation = NSEvent.mouseLocation
        let localPoint = convert(mouseLocation, from: nil)

        for (index, card) in cardViews.enumerated() {
            // 键盘选中的卡片保持高亮，不被悬停逻辑覆盖
            if index == selectedIndex {
                card.applyHoverState(true)
                continue
            }

            let cardFrame = card.frame
            let isHovering = cardFrame.contains(localPoint)
            card.applyHoverState(isHovering)
        }
    }

    deinit {
        hoverTimer?.invalidate()
    }
}
