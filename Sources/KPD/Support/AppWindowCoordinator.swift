import AppKit
import Foundation
import Observation
import SwiftUI

@Observable
final class AppWindowCoordinator {
    private static let fixedWelcomeContentSize = NSSize(width: 380, height: 380)

    var welcomeWindow: NSWindow?
    var noticeMessage: String?
    private var openOrganizerWindowsBySession: [UUID: OrganizerWindowRecord] = [:]
    private var organizerCloseObservers: [UUID: NSObjectProtocol] = [:]

    var hasOpenOrganizerWindows: Bool {
        pruneClosedOrganizerWindows()
        return !openOrganizerWindowsBySession.isEmpty
    }

    func registerWelcomeWindow(_ window: NSWindow?) {
        welcomeWindow = window
        window?.identifier = .kpdWelcomeWindow
        configureWelcomeWindow(window)
        DispatchQueue.main.async {
            self.configureWelcomeWindow(window)
        }
    }

    func showWelcomeIfNeeded(openWindow: OpenWindowAction) {
        guard !hasOpenOrganizerWindows else {
            return
        }

        if let welcomeWindow = currentWelcomeWindow {
            self.welcomeWindow = welcomeWindow
            welcomeWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            openWindow(id: "welcome")
        }
    }

    func closeWelcomeWindow() {
        DispatchQueue.main.async {
            let welcomeWindows = NSApp.windows.filter { window in
                window.identifier == .kpdWelcomeWindow
            }

            if welcomeWindows.isEmpty {
                self.welcomeWindow?.close()
            } else {
                welcomeWindows.forEach { $0.close() }
            }

            self.welcomeWindow = nil
        }
    }

    func registerOrganizerWindow(for input: OrganizerInput, window: NSWindow?) {
        guard let window else {
            return
        }

        window.identifier = .kpdOrganizerWindow
        window.representedURL = input.primaryDisplayURL
        window.title = input.windowTitle

        DispatchQueue.main.async {
            window.title = input.windowTitle
        }

        openOrganizerWindowsBySession[input.sessionID] = OrganizerWindowRecord(
            keys: Set(input.openDuplicateKeys),
            window: window
        )

        if organizerCloseObservers[input.sessionID] == nil {
            organizerCloseObservers[input.sessionID] = NotificationCenter.default.addObserver(
                forName: NSWindow.willCloseNotification,
                object: window,
                queue: .main
            ) { [weak self] _ in
                self?.unregisterOrganizerWindow(for: input)
            }
        }
    }

    func unregisterOrganizerWindow(for input: OrganizerInput) {
        openOrganizerWindowsBySession[input.sessionID] = nil
        if let observer = organizerCloseObservers.removeValue(forKey: input.sessionID) {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func isAlreadyOpen(_ input: OrganizerInput) -> Bool {
        pruneClosedOrganizerWindows()
        let openKeys = Set(openOrganizerWindowsBySession.values.flatMap(\.keys))
        return input.openDuplicateKeys.contains { openKeys.contains($0) }
    }

    func showNotice(_ message: String) {
        noticeMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { [weak self] in
            guard self?.noticeMessage == message else {
                return
            }
            self?.noticeMessage = nil
        }
    }

    private func pruneClosedOrganizerWindows() {
        for (sessionID, record) in openOrganizerWindowsBySession {
            guard let window = record.window else {
                unregisterOrganizerWindow(forSessionID: sessionID)
                continue
            }

            if !window.isVisible, !window.isMiniaturized {
                unregisterOrganizerWindow(forSessionID: sessionID)
            }
        }
    }

    private func unregisterOrganizerWindow(forSessionID sessionID: UUID) {
        openOrganizerWindowsBySession[sessionID] = nil
        if let observer = organizerCloseObservers.removeValue(forKey: sessionID) {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private var currentWelcomeWindow: NSWindow? {
        if let welcomeWindow, welcomeWindow.isVisible {
            return welcomeWindow
        }

        return NSApp.windows.first { window in
            window.identifier == .kpdWelcomeWindow && window.isVisible
        }
    }

    private func configureWelcomeWindow(_ window: NSWindow?) {
        guard let window else {
            return
        }

        let fixedContentRect = NSRect(origin: .zero, size: Self.fixedWelcomeContentSize)
        let fixedFrameSize = window.frameRect(forContentRect: fixedContentRect).size

        window.styleMask.remove(.resizable)
        window.minSize = fixedFrameSize
        window.maxSize = fixedFrameSize
        window.contentMinSize = Self.fixedWelcomeContentSize
        window.contentMaxSize = Self.fixedWelcomeContentSize
        window.standardWindowButton(.zoomButton)?.isEnabled = false

        if window.contentLayoutRect.size != Self.fixedWelcomeContentSize {
            window.setContentSize(Self.fixedWelcomeContentSize)
        }
    }
}

private struct OrganizerWindowRecord {
    var keys: Set<String>
    weak var window: NSWindow?
}

extension OrganizerInput {
    var primaryDisplayURL: URL? {
        urls.first
    }

    var windowTitle: String {
        guard urls.count == 1, let url = urls.first else {
            return "Selected Media"
        }

        return url.isExistingDirectory ? url.lastPathComponent : url.deletingLastPathComponent().lastPathComponent
    }

    var openDuplicateKeys: [String] {
        urls
            .filter(\.isExistingDirectory)
            .map { $0.standardizedFileURL.path }
    }
}

extension NSUserInterfaceItemIdentifier {
    static let kpdOrganizerWindow = NSUserInterfaceItemIdentifier("app.kpd.KPD.organizerWindow")
}
