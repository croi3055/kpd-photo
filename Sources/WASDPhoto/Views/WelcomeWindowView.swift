import AppKit
import SwiftUI
import WASDPhotoCore

struct WelcomeWindowView: View {
    @Bindable var preferences: AppPreferences
    @Bindable var windowCoordinator: AppWindowCoordinator
    @Environment(\.openWindow) private var openWindow
    @State private var isShowingOnboarding = false

    var body: some View {
        ZStack(alignment: .top) {
            EmptyStateView(
                strings: preferences.strings,
                openFolder: openFolder,
                openDroppedItems: openItemsInNewWindow
            )

            if let message = windowCoordinator.noticeMessage {
                NoticeBanner(message: message)
                    .padding(.top, 28)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(width: 380, height: 380)
        .preferredColorScheme(preferences.colorScheme)
        .background {
            WindowAccessor { window in
                windowCoordinator.registerWelcomeWindow(window)
            }
            .frame(width: 0, height: 0)
        }
        .background {
            MenuLocalizer(strings: preferences.strings)
                .frame(width: 0, height: 0)
        }
        .background(
            WindowCloseHandler(
                shouldClose: { true },
                requestCloseConfirmation: { _ in },
                willClose: {
                    windowCoordinator.welcomeWindow = nil
                }
            )
        )
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
        guard let url = FolderPicker.chooseFolder(strings: preferences.strings) else {
            return
        }

        openFolderInNewWindow(url)
    }

    private func openFolderInNewWindow(_ url: URL) {
        guard url.isExistingDirectory else {
            return
        }

        openItemsInNewWindow([url])
    }

    private func openItemsInNewWindow(_ urls: [URL]) {
        let usableURLs = urls.filter(\.isExistingDirectoryOrSupportedMediaFile)
        guard !usableURLs.isEmpty else {
            return
        }

        let input = OrganizerInput(urls: usableURLs)
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
}
