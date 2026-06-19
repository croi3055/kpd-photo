import AppKit
import SwiftUI
import UniformTypeIdentifiers
import WASDPhotoCore

struct ContentView: View {
    let input: OrganizerInput
    @Bindable var preferences: AppPreferences
    @Environment(\.openWindow) private var openWindow
    @State private var session = PhotoSession()
    @State private var isShowingTrashBin = false
    @State private var isShowingCloseConfirmation = false
    @State private var isRenamingInline = false
    @State private var renameBaseName = ""
    @State private var allowsWindowClose = false
    @State private var windowPendingClose: NSWindow?
    @State private var openedInput: OrganizerInput?
    @State private var isViewerVisible = true
    @State private var isShowingBrowsingComplete = false

    var body: some View {
        let strings = preferences.strings

        VStack(spacing: 0) {
            viewer
            statusBar
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    toggleSortOrder()
                } label: {
                    SortOrderIcon(sortOrder: preferences.mediaSortOrder)
                }
                .help(preferences.mediaSortOrder.displayName(strings: strings))

                Button(strings.openFolder) {
                    openFolder()
                }

                Button(strings.undo) {
                    session.undoLastAction()
                }
                .disabled(!session.hasPendingTrash)
            }
        }
        .onAppear {
            openSession(input)
        }
        .onChange(of: input) { _, newInput in
            openSession(newInput)
        }
        .onChange(of: preferences.mediaSortOrder) { _, newSortOrder in
            isShowingBrowsingComplete = false
            session.setSortOrder(newSortOrder)
        }
        .background(
            KeyEventHandlingView { event in
                if !isRenamingInline {
                    handleKey(event)
                }
            }
        )
        .background(
            WindowCloseHandler(
                shouldClose: {
                    allowsWindowClose || !session.hasPendingTrash
                },
                requestCloseConfirmation: { window in
                    windowPendingClose = window
                    isShowingCloseConfirmation = true
                },
                willClose: {
                    isViewerVisible = false
                    openedInput = nil
                    openWindow(id: "welcome")
                }
            )
        )
        .onDrop(of: [.fileURL], isTargeted: nil, perform: handleFolderDrop(providers:))
        .sheet(isPresented: $isShowingTrashBin) {
            TrashBinView(session: session, strings: strings, confirmAndClose: nil)
        }
        .alert(strings.closeWithTrashTitle, isPresented: $isShowingCloseConfirmation) {
            Button(strings.cancel, role: .cancel) {}
            Button(strings.moveToTrashAndClose, role: .destructive) {
                session.confirmTrashBin()
                if !session.hasPendingTrash {
                    allowsWindowClose = true
                    isViewerVisible = false
                    windowPendingClose?.close()
                }
            }
        } message: {
            Text(strings.closeWithTrashMessage(count: session.trashCount))
        }
        .alert(strings.appTitle, isPresented: errorBinding) {
            Button(strings.ok) {
                session.error = nil
            }
        } message: {
            Text(errorMessage)
        }
    }

    private func openSession(_ input: OrganizerInput) {
        guard openedInput != input else {
            isViewerVisible = true
            return
        }

        openedInput = input
        allowsWindowClose = false
        windowPendingClose = nil
        isShowingCloseConfirmation = false
        isShowingTrashBin = false
        isRenamingInline = false
        isShowingBrowsingComplete = false
        isViewerVisible = true
        session.open(urls: input.urls, sortOrder: preferences.mediaSortOrder)
    }

    private var viewer: some View {
        let strings = preferences.strings

        return ZStack {
            Rectangle()
                .fill(.background)

            if isViewerVisible {
                if isShowingBrowsingComplete {
                    BrowsingCompleteView(message: strings.browsingCompleteMessage)
                } else if let photo = session.currentPhoto {
                    PhotoViewer(photo: photo, strings: strings)
                } else {
                    EmptyStateView(
                        strings: strings,
                        openFolder: openFolder,
                        openDroppedItems: openItemsInNewWindow
                    )
                }
            } else {
                EmptyStateView(
                    strings: strings,
                    openFolder: openFolder,
                    openDroppedItems: openItemsInNewWindow
                )
            }
        }
    }

    private var statusBar: some View {
        let strings = preferences.strings

        return HStack(spacing: 12) {
            Text(session.currentPositionText)
                .font(.callout.monospacedDigit())

            Divider()
                .frame(height: 16)

            InlineRenameFileNameView(
                fileName: session.currentPhoto?.fileName ?? strings.noFolderSelected,
                extensionText: session.currentPhoto?.url.pathExtension ?? "",
                baseName: $renameBaseName,
                isRenaming: $isRenamingInline,
                placeholder: strings.fileNamePlaceholder,
                beginRename: beginRename,
                commitRename: commitRename,
                cancelRename: cancelRename
            )

            Spacer()

            TrashStatusButton(count: session.trashCount, label: strings.trashBin) {
                isShowingTrashBin = true
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { session.error != nil },
            set: { isPresented in
                if !isPresented {
                    session.error = nil
                }
            }
        )
    }

    private var errorMessage: String {
        guard let error = session.error else {
            return ""
        }

        return preferences.strings.message(for: error)
    }

    private func openFolder() {
        guard let url = FolderPicker.chooseFolder(prompt: preferences.strings.openFolder) else {
            return
        }

        openItemsInNewWindow([url])
    }

    private func openFolderInNewWindow(_ url: URL) {
        openItemsInNewWindow([url])
    }

    private func openItemsInNewWindow(_ urls: [URL]) {
        let usableURLs = urls.filter(\.isExistingDirectoryOrSupportedMediaFile)
        guard !usableURLs.isEmpty else {
            return
        }

        openWindow(id: "organizer", value: OrganizerInput(urls: usableURLs))
    }

    private func beginRename() {
        guard let currentPhoto = session.currentPhoto else {
            return
        }

        renameBaseName = currentPhoto.url.deletingPathExtension().lastPathComponent
        isRenamingInline = true
    }

    private func commitRename() {
        guard isRenamingInline else {
            return
        }

        session.renameCurrentPhoto(to: renameBaseName)
        isRenamingInline = false
    }

    private func cancelRename() {
        isRenamingInline = false
    }

    private func toggleSortOrder() {
        preferences.mediaSortOrder = preferences.mediaSortOrder.toggled
    }

    private func handleFolderDrop(providers: [NSItemProvider]) -> Bool {
        DroppedFileURLs.load(from: providers) { urls in
            guard !urls.isEmpty else {
                return
            }
            openItemsInNewWindow(urls)
        }
    }

    private func handleKey(_ event: KeyEvent) {
        switch event {
        case .previousItem:
            if isShowingBrowsingComplete {
                isShowingBrowsingComplete = false
                return
            }

            isShowingBrowsingComplete = false
            session.showPreviousPhoto()
        case .nextItem:
            if isShowingBrowsingComplete {
                isShowingBrowsingComplete = false
                session.currentIndex = 0
            } else if session.isAtLastPhoto {
                isShowingBrowsingComplete = true
            } else {
                isShowingBrowsingComplete = false
                session.showNextPhoto()
            }
        case .moveToTrash:
            isShowingBrowsingComplete = false
            session.markCurrentPhotoForDeletion()
        case .openTrashBin:
            isShowingTrashBin = true
        case .undo:
            isShowingBrowsingComplete = false
            session.undoLastAction()
        }
    }
}

private struct InlineRenameFileNameView: View {
    let fileName: String
    let extensionText: String
    @Binding var baseName: String
    @Binding var isRenaming: Bool
    let placeholder: String
    let beginRename: () -> Void
    let commitRename: () -> Void
    let cancelRename: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        Group {
            if isRenaming {
                renameField
            } else {
                Text(fileName)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .onTapGesture(count: 2) {
                        beginRename()
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: isRenaming) { _, newValue in
            if newValue {
                DispatchQueue.main.async {
                    isFocused = true
                }
            }
        }
        .onChange(of: isFocused) { oldValue, newValue in
            if oldValue, !newValue, isRenaming {
                commitRename()
            }
        }
    }

    private var renameField: some View {
        HStack(spacing: 4) {
            TextField(placeholder, text: $baseName)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .onSubmit {
                    commitRename()
                }
                .onExitCommand {
                    cancelRename()
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(.background, in: RoundedRectangle(cornerRadius: 4))
                .overlay {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.separator.opacity(0.5), lineWidth: 1)
                }

            if !extensionText.isEmpty {
                Text(".\(extensionText)")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: 320, alignment: .leading)
        .background {
            RenameOutsideClickHandler(isActive: isRenaming) {
                commitRename()
            }
        }
    }
}

private struct BrowsingCompleteView: View {
    let message: String

    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .fill(.quaternary)
                    .frame(width: 104, height: 104)

                Image(systemName: "checkmark")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 10) {
                Text(message)
                    .font(.title2.weight(.semibold))

                HStack(spacing: 8) {
                    Text("press")
                        .foregroundStyle(.secondary)

                    Text("→")
                        .font(.title3.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))

                    Text("回到第一张")
                        .foregroundStyle(.secondary)
                }
                .font(.callout)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct RenameOutsideClickHandler: NSViewRepresentable {
    let isActive: Bool
    let onOutsideClick: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        context.coordinator.view = view
        updateCoordinator(context.coordinator)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.view = nsView
        updateCoordinator(context.coordinator)
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        coordinator.removeMonitor()
    }

    private func updateCoordinator(_ coordinator: Coordinator) {
        coordinator.isActive = isActive
        coordinator.onOutsideClick = onOutsideClick
        coordinator.updateMonitor()
    }

    final class Coordinator {
        weak var view: NSView?
        var isActive = false
        var onOutsideClick: (() -> Void)?
        private var monitor: Any?

        func updateMonitor() {
            if isActive, monitor == nil {
                monitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
                    self?.handle(event)
                    return event
                }
            } else if !isActive {
                removeMonitor()
            }
        }

        func removeMonitor() {
            if let monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
        }

        private func handle(_ event: NSEvent) {
            guard isActive, let view, event.window === view.window else {
                return
            }

            let location = view.convert(event.locationInWindow, from: nil)
            guard !view.bounds.contains(location) else {
                return
            }

            DispatchQueue.main.async { [weak self] in
                guard self?.isActive == true else {
                    return
                }
                self?.onOutsideClick?()
            }
        }
    }
}

private struct TrashStatusButton: View {
    let count: Int
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                FontAwesomeTrashIcon()
                    .frame(width: 16, height: 18)
                    .foregroundStyle(.secondary)
                    .padding(6)

                if count > 0 {
                    Text("\(count)")
                        .font(.caption2.bold())
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(.red, in: Capsule())
                        .offset(x: 8, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
        .help(label)
    }
}

private struct SortOrderIcon: View {
    let sortOrder: MediaSortOrder

    private var topLetter: String {
        sortOrder == .oldestFirst ? "A" : "Z"
    }

    private var bottomLetter: String {
        sortOrder == .oldestFirst ? "Z" : "A"
    }

    var body: some View {
        HStack(spacing: 3) {
            VStack(spacing: -2) {
                Text(topLetter)
                Text(bottomLetter)
            }
            .font(.system(size: 9, weight: .bold, design: .rounded))
            .monospaced()

            Image(systemName: "arrow.down")
                .font(.system(size: 10, weight: .semibold))
        }
        .frame(width: 24, height: 18)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        switch sortOrder {
        case .newestFirst:
            return "Z-A"
        case .oldestFirst:
            return "A-Z"
        }
    }
}
