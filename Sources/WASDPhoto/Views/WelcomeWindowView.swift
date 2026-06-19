import AppKit
import SwiftUI

struct WelcomeWindowView: View {
    @Bindable var preferences: AppPreferences
    @Environment(\.openWindow) private var openWindow
    @State private var isShowingOnboarding = false
    @State private var window: NSWindow?

    var body: some View {
        EmptyStateView(
            strings: preferences.strings,
            openFolder: openFolder,
            openDroppedItems: openItemsInNewWindow
        )
        .frame(minWidth: 560, minHeight: 480)
        .preferredColorScheme(preferences.colorScheme)
        .background {
            WindowAccessor { window in
                self.window = window
                window?.identifier = .wasdWelcomeWindow
            }
            .frame(width: 0, height: 0)
        }
        .onAppear {
            if !preferences.hasSeenOnboarding {
                isShowingOnboarding = true
            }
        }
        .alert(preferences.strings.gettingStartedTitle, isPresented: $isShowingOnboarding) {
            Button(preferences.strings.gotIt) {
                preferences.hasSeenOnboarding = true
            }
        } message: {
            Text(preferences.strings.gettingStartedMessage)
        }
    }

    private func openFolder() {
        guard let url = FolderPicker.chooseFolder(prompt: preferences.strings.openFolder) else {
            return
        }

        openFolderInNewWindow(url)
    }

    private func openFolderInNewWindow(_ url: URL) {
        guard url.isExistingDirectory else {
            return
        }

        openWindow(id: "organizer", value: OrganizerInput(url: url))
        closeWelcomeWindow()
    }

    private func openItemsInNewWindow(_ urls: [URL]) {
        let usableURLs = urls.filter(\.isExistingDirectoryOrSupportedMediaFile)
        guard !usableURLs.isEmpty else {
            return
        }

        openWindow(id: "organizer", value: OrganizerInput(urls: usableURLs))
        closeWelcomeWindow()
    }

    private func closeWelcomeWindow() {
        DispatchQueue.main.async {
            window?.close()
        }
    }
}
