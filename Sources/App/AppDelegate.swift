import Cocoa
import Carbon.HIToolbox

// MARK: - SpiceNest 应用主体
// Nexus 元宇宙成员应用 - LTspice 仿真参考助手

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupWindow()
        setupStatusItem()
        setupHotKey()
        showWindow()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showWindow()
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        NXHotKeyManager.unregister()
    }

    // MARK: - Nexus URL Scheme 接收（必须实现）

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            guard let result = NXURLScheme.parse(url) else { continue }
            showWindow()
            // TODO: 根据 result.action 执行深度链接操作
            switch result.action {
            case "search":
                if let q = result.params["q"] { print("搜索: \(q)") }
            default:
                break
            }
        }
    }

    // MARK: - 全局热键

    private func setupHotKey() {
        NXHotKeyManager.register(
            keyCode: UInt32(kVK_ANSI_S),
            modifiers: UInt32(controlKey) | UInt32(optionKey),
            signature: OSType(0x534E), // "SN" - SpiceNest
            onHotKey: { [weak self] in self?.toggleWindow() }
        )
    }

    // MARK: - 菜单栏（必须包含 Nexus 应用子菜单）

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            let img = NSImage(systemSymbolName: "bolt", accessibilityDescription: "SpiceNest")?.withSymbolConfiguration(config)
            img?.isTemplate = true
            button.image = img
            button.imagePosition = .imageOnly
        }

        let menu = NSMenu()

        // 显示/隐藏
        let toggle = NSMenuItem(title: "显示 / 隐藏 SpiceNest", action: #selector(toggleWindow), keyEquivalent: "")
        toggle.target = self
        menu.addItem(toggle)
        menu.addItem(.separator())

        // Nexus 应用子菜单（必须）
        let nexusMenu = makeNexusAppsMenu()
        let nexusItem = NSMenuItem(title: "Nexus 应用", action: nil, keyEquivalent: "")
        nexusItem.submenu = nexusMenu
        menu.addItem(nexusItem)
        menu.addItem(.separator())

        // 退出
        let quit = NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        item.menu = menu
        statusItem = item
    }

    /// 构建 Nexus 应用子菜单
    private func makeNexusAppsMenu() -> NSMenu {
        let menu = NSMenu(title: "Nexus 应用")

        // Nexus Hub（元宇宙中心）
        let hubItem = NSMenuItem(title: "Nexus Hub", action: #selector(openNexusApp(_:)), keyEquivalent: "")
        hubItem.target = self
        hubItem.representedObject = "hub"
        hubItem.isEnabled = NXURLScheme.isAppInstalled(appId: "hub")
        if !hubItem.isEnabled { hubItem.title = "Nexus Hub（未安装）" }
        menu.addItem(hubItem)
        menu.addItem(.separator())

        // 已知的 Nexus 应用列表
        let knownApps: [(id: String, name: String)] = [
            ("keyhub", "KeyHub"),
            ("spicenest", "SpiceNest"),
        ]
        for app in knownApps {
            let item = NSMenuItem(title: app.name, action: #selector(openNexusApp(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = app.id
            item.isEnabled = NXURLScheme.isAppInstalled(appId: app.id)
            if !item.isEnabled { item.title = "\(app.name)（未安装）" }
            menu.addItem(item)
        }

        if menu.items.filter({ $0.action != nil }).count <= 1 {
            let hint = NSMenuItem(title: "暂无其他已安装应用", action: nil, keyEquivalent: "")
            hint.isEnabled = false
            menu.addItem(hint)
        }
        return menu
    }

    @objc private func openNexusApp(_ sender: NSMenuItem) {
        guard let appId = sender.representedObject as? String else { return }
        NXURLScheme.openApp(appId: appId)
    }

    // MARK: - 窗口
    // 注意：窗口样式完全由应用自行决定，Nexus 不强制毛玻璃/固定宽度等。
    // 这里使用 NXWindowStyle 作为示例，也可以完全自定义 NSWindow。

    private func setupWindow() {
        let win = NXWindowStyle.makeFloatingWindow(
            size: NSSize(width: 560, height: 400),
            title: "SpiceNest",
            tintColor: NSColor(red: 1.0, green: 0.584, blue: 0.0, alpha: 0.12),
            fixedWidth: true
        )
        win.center()
        window = win
    }

    // MARK: - 窗口切换

    @objc func toggleWindow() {
        if let win = window, win.isVisible {
            win.orderOut(nil)
        } else {
            showWindow()
        }
    }

    private func showWindow() {
        guard let win = window else { return }
        win.makeKeyAndOrderFront(nil)
        win.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() { NSApp.terminate(nil) }
}
