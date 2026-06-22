import AppKit
import SwiftUI

struct MenuLocalizer: NSViewRepresentable {
    let strings: AppStrings

    func makeNSView(context: Context) -> NSView {
        DispatchQueue.main.async {
            localizeMenus()
        }
        return NSView(frame: .zero)
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            localizeMenus()
        }
    }

    private func localizeMenus() {
        guard let mainMenu = NSApp.mainMenu else {
            return
        }

        for item in mainMenu.items {
            switch item.title {
            case "File", "文件":
                item.title = strings.fileMenu
            case "Edit", "编辑":
                item.title = strings.editMenu
            case "View", "显示":
                item.title = strings.viewMenu
            case "Window", "窗口":
                item.title = strings.windowMenu
            case "Help", "帮助":
                item.title = strings.helpTopMenu
            case "Format", "格式":
                mainMenu.removeItem(item)
            default:
                break
            }

            removeServicesItem(from: item.submenu)
        }
    }

    private func removeServicesItem(from menu: NSMenu?) {
        guard let menu else {
            return
        }

        for item in menu.items where item.title == "Services" || item.title == "服务" {
            menu.removeItem(item)
            return
        }
    }
}
