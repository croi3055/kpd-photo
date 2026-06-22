import AppKit
import SwiftUI
import UniformTypeIdentifiers
import WASDPhotoCore

struct ContentView: View {
    let input: OrganizerInput
    @Bindable var preferences: AppPreferences
    @Bindable var windowCoordinator: AppWindowCoordinator
    @Environment(\.openWindow) private var openWindow
    @State private var session = PhotoSession()
    @State private var isShowingTrashBin = false
    @State private var isShowingCloseConfirmation = false
    @State private var isRenamingInline = false
    @State private var renameBaseName = ""
    @State private var allowsWindowClose = false
    @State private var windowPendingClose: NSWindow?
    @State private var organizerWindow: NSWindow?
    @State private var closeConfirmationWindow: NSWindow?
    @State private var closeConfirmationDelegate: CloseConfirmationWindowDelegate?
    @State private var openedInput: OrganizerInput?
    @State private var isViewerVisible = true
    @State private var isShowingBrowsingComplete = false
    @State private var isDropTargeted = false
    @State private var didUnregisterOrganizer = false

    var body: some View {
        let strings = preferences.strings

        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    viewer
                        .blur(radius: isDropTargeted ? 8 : 0)

                    if isDropTargeted {
                        DropTargetOverlay(message: strings.dropToOpenNewWindow)
                    }
                }
                statusBar
            }

            if let message = windowCoordinator.noticeMessage {
                VStack {
                    NoticeBanner(message: message)
                        .padding(.top, 18)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
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
            }
        }
        .onAppear {
            didUnregisterOrganizer = false
            openSession(input)
        }
        .onDisappear {
            unregisterOrganizerIfNeeded()
        }
        .navigationTitle(input.windowTitle)
        .onChange(of: input) { _, newInput in
            openSession(newInput)
        }
        .onChange(of: preferences.mediaSortOrder) { _, newSortOrder in
            isShowingBrowsingComplete = false
            session.setSortOrder(newSortOrder)
        }
        .background {
            if !isRenamingInline && closeConfirmationWindow == nil {
                KeyEventHandlingView { event in
                    handleKey(event)
                }
            }
        }
        .background(
            WindowCloseHandler(
                shouldClose: {
                    allowsWindowClose || !session.hasPendingTrash
                },
                requestCloseConfirmation: { window in
                    windowPendingClose = window
                    presentCloseConfirmation(for: window, strings: strings)
                },
                willClose: {
                    isViewerVisible = false
                    openedInput = nil
                    unregisterOrganizerIfNeeded()
                    windowCoordinator.showWelcomeIfNeeded(openWindow: openWindow)
                }
            )
        )
        .background {
            WindowAccessor { window in
                guard !didUnregisterOrganizer else {
                    return
                }

                organizerWindow = window
                windowCoordinator.registerOrganizerWindow(for: input, window: window)
            }
            .frame(width: 0, height: 0)
        }
        .background {
            MenuLocalizer(strings: preferences.strings)
                .frame(width: 0, height: 0)
        }
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted, perform: handleFolderDrop(providers:))
        .sheet(isPresented: $isShowingTrashBin) {
            TrashBinView(session: session, strings: strings, confirmAndClose: nil)
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
        organizerWindow = nil
        isShowingCloseConfirmation = false
        isShowingTrashBin = false
        isRenamingInline = false
        isShowingBrowsingComplete = false
        isViewerVisible = true
        session.open(urls: input.urls, sortOrder: preferences.mediaSortOrder)
    }

    private func presentCloseConfirmation(for parentWindow: NSWindow, strings: AppStrings) {
        if let closeConfirmationWindow {
            closeConfirmationWindow.makeKeyAndOrderFront(nil)
            return
        }

        let confirmationWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 164),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        confirmationWindow.title = strings.closeWithTrashTitle
        confirmationWindow.isReleasedWhenClosed = false
        confirmationWindow.level = .floating
        confirmationWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
        confirmationWindow.standardWindowButton(.zoomButton)?.isHidden = true
        confirmationWindow.contentView = NSHostingView(
            rootView: CloseTrashConfirmationView(
                message: strings.closeWithTrashMessage(count: session.trashCount),
                discardTitle: strings.discardChangesAndClose,
                deleteTitle: strings.moveToTrashAndClose,
                dismiss: {
                    closeConfirmationWindow?.close()
                    closeConfirmationWindow = nil
                },
                discard: {
                    closeConfirmationWindow?.close()
                    closeConfirmationWindow = nil
                    session.discardPendingTrashChanges()
                    closeOrganizerAfterConfirmation(parentWindow)
                },
                delete: {
                    closeConfirmationWindow?.close()
                    closeConfirmationWindow = nil
                    session.confirmTrashBin()
                    if !session.hasPendingTrash {
                        closeOrganizerAfterConfirmation(parentWindow)
                    }
                }
            )
        )
        let delegate = CloseConfirmationWindowDelegate {
            parentWindow.removeChildWindow(confirmationWindow)
            closeConfirmationWindow = nil
            closeConfirmationDelegate = nil
        }
        confirmationWindow.delegate = delegate
        closeConfirmationDelegate = delegate
        parentWindow.addChildWindow(confirmationWindow, ordered: .above)
        centerCloseConfirmationWindow(confirmationWindow, in: parentWindow)
        closeConfirmationWindow = confirmationWindow
        confirmationWindow.makeKeyAndOrderFront(nil)
        parentWindow.makeKey()
        confirmationWindow.makeKey()
    }

    private func closeOrganizerAfterConfirmation(_ parentWindow: NSWindow) {
        allowsWindowClose = true
        isViewerVisible = false
        openedInput = nil
        unregisterOrganizerIfNeeded()
        parentWindow.close()
        windowCoordinator.showWelcomeIfNeeded(openWindow: openWindow)
    }

    private func requestOrganizerClose() {
        guard let organizerWindow else {
            windowCoordinator.showWelcomeIfNeeded(openWindow: openWindow)
            return
        }

        if session.hasPendingTrash {
            windowPendingClose = organizerWindow
            presentCloseConfirmation(for: organizerWindow, strings: preferences.strings)
        } else {
            closeOrganizerAfterConfirmation(organizerWindow)
        }
    }

    private func centerCloseConfirmationWindow(_ confirmationWindow: NSWindow, in parentWindow: NSWindow) {
        let parentFrame = parentWindow.frame
        let confirmationFrame = confirmationWindow.frame
        let origin = NSPoint(
            x: parentFrame.midX - confirmationFrame.width / 2,
            y: parentFrame.midY - confirmationFrame.height / 2
        )
        confirmationWindow.setFrameOrigin(origin)
    }

    private func unregisterOrganizerIfNeeded() {
        guard !didUnregisterOrganizer else {
            return
        }

        didUnregisterOrganizer = true
        windowCoordinator.unregisterOrganizerWindow(for: input)
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
        .contextMenu {
            viewerContextMenu(strings: strings)
        }
    }

    @ViewBuilder
    private func viewerContextMenu(strings: AppStrings) -> some View {
        if session.currentPhoto != nil, !isShowingBrowsingComplete {
            Button {
                revealCurrentPhotoInFinder()
            } label: {
                Label(strings.showInFinder, systemImage: "folder")
            }

            Button {
                openCurrentPhotoInPreview()
            } label: {
                Label(strings.openInPreview, systemImage: "eye")
            }

            Button {
                shareCurrentPhotoViaAirDrop()
            } label: {
                Label(strings.shareViaAirDrop, systemImage: "dot.radiowaves.left.and.right")
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
        guard let url = FolderPicker.chooseFolder(strings: preferences.strings) else {
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

    private func revealCurrentPhotoInFinder() {
        guard let currentPhoto = session.currentPhoto else {
            return
        }

        NSWorkspace.shared.activateFileViewerSelecting([currentPhoto.url])
    }

    private func openCurrentPhotoInPreview() {
        guard let currentPhoto = session.currentPhoto else {
            return
        }

        if let previewURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Preview") {
            let configuration = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.open([currentPhoto.url], withApplicationAt: previewURL, configuration: configuration)
        } else {
            NSWorkspace.shared.open(currentPhoto.url)
        }
    }

    private func shareCurrentPhotoViaAirDrop() {
        guard
            let currentPhoto = session.currentPhoto,
            let service = NSSharingService(named: .sendViaAirDrop)
        else {
            return
        }

        service.perform(withItems: [currentPhoto.url])
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
        case .closeWindow:
            requestOrganizerClose()
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

private struct DropTargetOverlay: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 54))

            Text(message)
                .font(.title3.weight(.semibold))
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 40)
        .padding(.vertical, 30)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(0.35), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}

struct NoticeBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.red)

            Text(message)
                .font(.callout.weight(.semibold))
                .lineLimit(2)
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 18)
        .padding(.vertical, 13)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .background(Color.red.opacity(0.07), in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}

private struct CloseTrashConfirmationView: View {
    let message: String
    let discardTitle: String
    let deleteTitle: String
    let dismiss: () -> Void
    let discard: () -> Void
    let delete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text(message)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                PermissionPromptButton(title: discardTitle, style: .secondary) {
                    discard()
                }

                PermissionPromptButton(title: deleteTitle, style: .primary) {
                    delete()
                }
                .keyboardShortcut(.defaultAction)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 22)
        .frame(width: 280, height: 136)
        .background(.regularMaterial)
        .background {
            CloseConfirmationKeyboardHandler(
                dismiss: dismiss,
                discard: discard,
                delete: delete
            )
        }
    }
}

private struct PermissionPromptButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(style == .primary ? .white : .primary)
            .padding(.horizontal, 20)
            .frame(height: 38)
            .background(background)
            .clipShape(Capsule())
            .contentShape(Capsule())
            .onTapGesture {
                action()
            }
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            Capsule()
                .fill(Color.accentColor)
        case .secondary:
            Capsule()
                .fill(.quaternary)
        }
    }
}

private struct CloseConfirmationKeyboardHandler: NSViewRepresentable {
    let dismiss: () -> Void
    let discard: () -> Void
    let delete: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss, discard: discard, delete: delete)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        context.coordinator.attach(to: view)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.dismiss = dismiss
        context.coordinator.discard = discard
        context.coordinator.delete = delete
        context.coordinator.attach(to: nsView)
    }

    final class Coordinator {
        var dismiss: () -> Void
        var discard: () -> Void
        var delete: () -> Void
        private weak var view: NSView?
        private var monitor: Any?

        init(dismiss: @escaping () -> Void, discard: @escaping () -> Void, delete: @escaping () -> Void) {
            self.dismiss = dismiss
            self.discard = discard
            self.delete = delete
        }

        deinit {
            if let monitor {
                NSEvent.removeMonitor(monitor)
            }
        }

        func attach(to view: NSView) {
            self.view = view
            guard monitor == nil else {
                return
            }

            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                self?.handle(event) ?? event
            }
        }

        private func handle(_ event: NSEvent) -> NSEvent? {
            guard let window = view?.window else {
                return event
            }

            switch event.keyCode {
            case 53:
                guard event.window === window || window.parent === event.window else {
                    return event
                }
                dismiss()
                return nil
            case 49:
                guard event.window === window || window.parent === event.window else {
                    return event
                }
                discard()
                return nil
            case 36, 76:
                guard event.window === window || window.parent === event.window else {
                    return event
                }
                delete()
                return nil
            default:
                return event
            }
        }
    }
}

private final class CloseConfirmationWindowDelegate: NSObject, NSWindowDelegate {
    let onClose: () -> Void

    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }

    func windowWillClose(_ notification: Notification) {
        onClose()
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
