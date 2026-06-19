import AppKit
import SwiftUI

struct KeyEventHandlingView: NSViewRepresentable {
    let onKeyDown: (KeyEvent) -> Void

    func makeNSView(context: Context) -> KeyCaptureView {
        let view = KeyCaptureView()
        view.onKeyDown = onKeyDown
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: KeyCaptureView, context: Context) {
        nsView.onKeyDown = onKeyDown
        DispatchQueue.main.async {
            nsView.window?.makeFirstResponder(nsView)
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
