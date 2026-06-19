import AppKit
import SwiftUI
import WASDPhotoCore

@main
struct WASDPhotoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var preferences = AppPreferences()

    var body: some Scene {
        WindowGroup("WASD Photo", id: "welcome") {
            WelcomeWindowView(preferences: preferences)
                .preferredColorScheme(preferences.colorScheme)
        }
        .commands {
            WASDPhotoCommands(preferences: preferences)
        }

        WindowGroup("Organizer", id: "organizer", for: OrganizerInput.self) { $input in
            if let input {
                ContentView(input: input, preferences: preferences)
                    .frame(minWidth: 640, minHeight: 520)
                    .preferredColorScheme(preferences.colorScheme)
            } else {
                WelcomeWindowView(preferences: preferences)
                    .preferredColorScheme(preferences.colorScheme)
            }
        }
        .commands {
            WASDPhotoCommands(preferences: preferences)
        }

        Settings {
            SettingsView(preferences: preferences)
                .preferredColorScheme(preferences.colorScheme)
        }
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

        CommandGroup(replacing: .newItem) {
            Button(preferences.strings.openFolderMenu) {
                guard let url = FolderPicker.chooseFolder(prompt: preferences.strings.openFolder) else {
                    return
                }

                guard url.isExistingDirectory else {
                    return
                }

                let welcomeWindow = NSApp.keyWindow?.identifier == .wasdWelcomeWindow ? NSApp.keyWindow : nil
                openWindow(id: "organizer", value: OrganizerInput(url: url))
                if let welcomeWindow {
                    DispatchQueue.main.async {
                        welcomeWindow.close()
                    }
                }
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

extension NSUserInterfaceItemIdentifier {
    static let wasdWelcomeWindow = NSUserInterfaceItemIdentifier("app.wasd.WASDPhoto.welcomeWindow")
}
