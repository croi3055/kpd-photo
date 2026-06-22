import AppKit
import SwiftUI

struct KeyEventHandlingView: NSViewRepresentable {
    let onKeyDown: (KeyEvent) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> KeyCaptureView {
        let view = KeyCaptureView()
        view.onKeyDown = onKeyDown
        context.coordinator.view = view
        context.coordinator.onKeyDown = onKeyDown
        context.coordinator.updateMonitor()
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: KeyCaptureView, context: Context) {
        nsView.onKeyDown = onKeyDown
        context.coordinator.view = nsView
        context.coordinator.onKeyDown = onKeyDown
        context.coordinator.updateMonitor()
        DispatchQueue.main.async {
            nsView.window?.makeFirstResponder(nsView)
        }
    }

    static func dismantleNSView(_ nsView: KeyCaptureView, coordinator: Coordinator) {
        coordinator.removeMonitor()
    }

    final class Coordinator {
        weak var view: NSView?
        var onKeyDown: ((KeyEvent) -> Void)?
        private var monitor: Any?

        func updateMonitor() {
            guard monitor == nil else {
                return
            }

            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self, self.handle(event) else {
                    return event
                }
                return nil
            }
        }

        func removeMonitor() {
            if let monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
        }

        private func handle(_ event: NSEvent) -> Bool {
            guard let view, event.window === view.window else {
                return false
            }

            guard let keyEvent = KeyboardShortcuts.shared.event(for: event) else {
                return false
            }

            onKeyDown?(keyEvent)
            return true
        }
    }
}

final class KeyCaptureView: NSView {
    var onKeyDown: ((KeyEvent) -> Void)?

    override var acceptsFirstResponder: Bool {
        true
    }

    override func keyDown(with event: NSEvent) {
        if let keyEvent = KeyboardShortcuts.shared.event(for: event) {
            onKeyDown?(keyEvent)
        } else {
            super.keyDown(with: event)
        }
    }
}
