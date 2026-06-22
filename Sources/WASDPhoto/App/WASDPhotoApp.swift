import AppKit
import SwiftUI
import WASDPhotoCore

@main
struct WASDPhotoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var preferences = AppPreferences()
    @State private var windowCoordinator = AppWindowCoordinator()

    var body: some Scene {
        Group {
            WindowGroup("untitled-photo-organizer", id: "welcome") {
                WelcomeWindowView(preferences: preferences, windowCoordinator: windowCoordinator)
                    .preferredColorScheme(preferences.colorScheme)
            }
            .defaultSize(width: 380, height: 380)
            .windowResizability(.contentSize)

            WindowGroup("Organizer", id: "organizer", for: OrganizerInput.self) { $input in
                if let input {
                    ContentView(input: input, preferences: preferences, windowCoordinator: windowCoordinator)
                        .frame(minWidth: 640, minHeight: 520)
                        .preferredColorScheme(preferences.colorScheme)
                } else {
                    MissingOrganizerInputView()
                        .preferredColorScheme(preferences.colorScheme)
                }
            }

            Settings {
                SettingsView(preferences: preferences)
                    .preferredColorScheme(preferences.colorScheme)
            }
        }
        .commands {
            WASDPhotoCommands(preferences: preferences, windowCoordinator: windowCoordinator)
        }
    }
}

private struct MissingOrganizerInputView: View {
    var body: some View {
        Color.clear
            .frame(width: 1, height: 1)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension Notification.Name {
    static let openFolderRequested = Notification.Name("openFolderRequested")
}

struct WASDPhotoCommands: Commands {
    @Bindable var preferences: AppPreferences
    @Bindable var windowCoordinator: AppWindowCoordinator

    var body: some Commands {
        WASDPhotoPrimaryCommands(preferences: preferences, windowCoordinator: windowCoordinator)
        WASDPhotoCleanupCommands(preferences: preferences)
    }
}

private struct WASDPhotoPrimaryCommands: Commands {
    @Bindable var preferences: AppPreferences
    @Bindable var windowCoordinator: AppWindowCoordinator
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button(preferences.strings.aboutMenu) {
                NSApp.orderFrontStandardAboutPanel(nil)
            }
        }

        CommandGroup(replacing: .appSettings) {
            Button(preferences.strings.settingsMenu) {
                openSettings()
            }
            .keyboardShortcut(",", modifiers: [.command])
        }

        CommandGroup(replacing: .appVisibility) {
            Button(preferences.strings.hideMenu) {
                NSApp.hide(nil)
            }
            .keyboardShortcut("h", modifiers: [.command])

            Button(preferences.strings.hideOthersMenu) {
                NSApp.hideOtherApplications(nil)
            }
            .keyboardShortcut("h", modifiers: [.command, .option])

            Button(preferences.strings.showAllMenu) {
                NSApp.unhideAllApplications(nil)
            }
        }

        CommandGroup(replacing: .newItem) {
            Button(preferences.strings.openFolderMenu) {
                guard let url = FolderPicker.chooseFolder(strings: preferences.strings) else {
                    return
                }

                guard url.isExistingDirectory else {
                    return
                }

                let input = OrganizerInput(url: url)
                guard !windowCoordinator.isAlreadyOpen(input) else {
                    windowCoordinator.showNotice(preferences.strings.folderAlreadyOpenMessage)
                    return
                }

                guard FolderScanner.containsSupportedMedia(urls: input.urls) else {
                    windowCoordinator.showNotice(preferences.strings.unsupportedMediaError)
                    return
                }

                openWindow(id: "organizer", value: input)
                windowCoordinator.closeWelcomeWindow()
            }
            .keyboardShortcut("o", modifiers: [.command])
        }

        CommandGroup(replacing: .appTermination) {
            Button(preferences.strings.quitMenu) {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: [.command])
        }
    }
}

private struct WASDPhotoCleanupCommands: Commands {
    @Bindable var preferences: AppPreferences

    var body: some Commands {
        CommandGroup(replacing: .saveItem) {}
        CommandGroup(replacing: .printItem) {}
        CommandGroup(replacing: .undoRedo) {}
        CommandGroup(replacing: .pasteboard) {
            Button(preferences.strings.cutMenu) {
                NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("x", modifiers: [.command])

            Button(preferences.strings.copyMenu) {
                NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("c", modifiers: [.command])

            Button(preferences.strings.pasteMenu) {
                NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("v", modifiers: [.command])

            Button(preferences.strings.selectAllMenu) {
                NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("a", modifiers: [.command])
        }
        CommandGroup(replacing: .textEditing) {}
        CommandGroup(replacing: .textFormatting) {}
        CommandGroup(replacing: .toolbar) {}
        CommandGroup(replacing: .windowSize) {}
        CommandGroup(replacing: .windowArrangement) {}
        CommandGroup(replacing: .help) {
            Button(preferences.strings.helpMenu) {}
                .disabled(true)
        }
    }
}

extension NSUserInterfaceItemIdentifier {
    static let wasdWelcomeWindow = NSUserInterfaceItemIdentifier("app.wasd.WASDPhoto.welcomeWindow")
}
