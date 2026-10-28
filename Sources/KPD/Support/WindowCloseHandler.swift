import AppKit
import SwiftUI

struct WindowCloseHandler: NSViewRepresentable {
    let shouldClose: () -> Bool
    let requestCloseConfirmation: (NSWindow) -> Void
    let willClose: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        updateCoordinator(context.coordinator)
        DispatchQueue.main.async {
            if let window = view.window {
                context.coordinator.attach(to: window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        updateCoordinator(context.coordinator)
        DispatchQueue.main.async {
            if let window = nsView.window {
                context.coordinator.attach(to: window)
            }
        }
    }

    private func updateCoordinator(_ coordinator: Coordinator) {
        coordinator.shouldClose = shouldClose
        coordinator.requestCloseConfirmation = requestCloseConfirmation
        coordinator.willClose = willClose
    }

    final class Coordinator: NSObject, NSWindowDelegate {
        var shouldClose: (() -> Bool)?
        var requestCloseConfirmation: ((NSWindow) -> Void)?
        var willClose: (() -> Void)?
        weak var window: NSWindow?
        var allowsClose = false

        func attach(to window: NSWindow) {
            guard self.window !== window else {
                return
            }

            self.window = window
            window.delegate = self
        }

        func closeAfterConfirmation() {
            allowsClose = true
            window?.close()
        }

        func windowShouldClose(_ sender: NSWindow) -> Bool {
            if allowsClose || shouldClose?() == true {
                willClose?()
                return true
            }

            requestCloseConfirmation?(sender)
            return false
        }
    }
}
