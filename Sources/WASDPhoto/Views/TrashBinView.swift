import AppKit
import AVFoundation
import SwiftUI
import WASDPhotoCore

struct TrashBinView: View {
    @Bindable var session: PhotoSession
    let strings: AppStrings
    let confirmAndClose: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedURLs: Set<URL> = []
    @State private var focusedIndex = 0
    @State private var selectionAnchorIndex = 0
    @State private var rangeSelectionBase: Set<URL>?
    @State private var rangeSelectionMode: RangeSelectionMode?
    @State private var previewIndex: Int?

    private let columnCount = 4
    private let columns = Array(repeating: GridItem(.fixed(112), spacing: 14), count: 4)

    var body: some View {
        VStack(spacing: 0) {
            if session.trashItems.isEmpty {
                ContentUnavailableView(strings.emptyTrashBin, systemImage: "trash")
                    .frame(minHeight: 260)
            } else {
                HStack {
                    Spacer()

                    Text(trashSummary)
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(Array(session.trashItems.enumerated()), id: \.element.id) { index, item in
                            TrashThumbnailCell(
                                item: item,
                                isSelected: selectedURLs.contains(item.url),
                                isFocused: focusedIndex == index,
                                strings: strings
                            ) {
                                focusedIndex = index
                                selectionAnchorIndex = index
                                toggleSelection(item.url)
                            }
                        }
                    }
                    .padding()
                }
                .frame(minHeight: 320)
            }

            Divider()

            HStack {
                Button(strings.cancel) {
                    dismiss()
                }

                Spacer()

                if !session.trashItems.isEmpty {
                    Button(selectAllButtonTitle) {
                        toggleAllSelection()
                    }
                }

                if selectedURLs.isEmpty {
                    Button(strings.restoreAll) {
                        restoreAllItems()
                    }
                    .disabled(session.trashItems.isEmpty)
                } else {
                    Button {
                        restoreSelectedItems()
                        clearSelectionState()
                    } label: {
                        ButtonTitleWithKeyCaps(title: strings.restoreSelected, keys: ["R"])
                    }
                }

                if !selectedURLs.isEmpty {
                    Button(role: .destructive) {
                        session.confirmTrashBin(urls: selectedURLs)
                        clearSelectionState()

                        if session.trashItems.isEmpty {
                            confirmAndClose?()
                            dismiss()
                        }
                    } label: {
                        ButtonTitleWithKeyCaps(title: strings.moveSelectedToTrash, keys: ["D"])
                    }
                }

                Button(strings.emptyTrash, role: .destructive) {
                    session.confirmTrashBin()
                    clearSelectionState()

                    if session.trashItems.isEmpty {
                        confirmAndClose?()
                        dismiss()
                    }
                }
                .disabled(session.trashItems.isEmpty)
                .help("⌘D")
            }
            .padding()
        }
        .frame(width: 560)
        .background(
            TrashBinKeyboardHandler(isActive: !session.trashItems.isEmpty) { event in
                handleKeyboardEvent(event)
            }
        )
        .sheet(isPresented: previewPresentation) {
            if !session.trashItems.isEmpty {
                TrashPreviewView(items: session.trashItems, currentIndex: previewIndexBinding, strings: strings)
            }
        }
        .onAppear {
            clampFocusedIndex()
        }
        .onChange(of: session.trashItems) { _, _ in
            selectedURLs = selectedURLs.filter { url in
                session.trashItems.contains { $0.url == url }
            }
            clampFocusedIndex()
            clampPreviewIndex()
        }
    }

    private var previewPresentation: Binding<Bool> {
        Binding(
            get: { previewIndex != nil },
            set: { isPresented in
                if !isPresented {
                    previewIndex = nil
                }
            }
        )
    }

    private var previewIndexBinding: Binding<Int> {
        Binding(
            get: {
                guard !session.trashItems.isEmpty else {
                    return 0
                }
                return min(max(previewIndex ?? focusedIndex, 0), session.trashItems.count - 1)
            },
            set: { newValue in
                guard !session.trashItems.isEmpty else {
                    previewIndex = nil
                    return
                }
                previewIndex = min(max(newValue, 0), session.trashItems.count - 1)
            }
        )
    }

    private var isAllSelected: Bool {
        !session.trashItems.isEmpty && selectedURLs.count == session.trashItems.count
    }

    private var selectAllButtonTitle: String {
        isAllSelected ? strings.deselectAll : strings.selectAll
    }

    private var trashSummary: String {
        let photoCount = session.trashItems.filter { $0.kind == .image }.count
        let videoCount = session.trashItems.filter { $0.kind == .video }.count
        return strings.trashSummary(photoCount: photoCount, videoCount: videoCount)
    }

    private func toggleSelection(_ url: URL) {
        if selectedURLs.contains(url) {
            selectedURLs.remove(url)
        } else {
            selectedURLs.insert(url)
        }
        rangeSelectionBase = nil
        rangeSelectionMode = nil
    }

    private func toggleAllSelection() {
        if isAllSelected {
            selectedURLs = []
        } else {
            selectedURLs = Set(session.trashItems.map(\.url))
        }
        rangeSelectionBase = nil
        rangeSelectionMode = nil
    }

    private func restoreSelectedItems() {
        session.restoreFromTrash(urls: selectedURLs)
    }

    private func restoreAllItems() {
        session.restoreFromTrash(urls: Set(session.trashItems.map(\.url)))
        clearSelectionState()
    }

    private func clearSelectionState() {
        selectedURLs = []
        rangeSelectionBase = nil
        rangeSelectionMode = nil
    }

    private func handleKeyboardEvent(_ event: TrashBinKeyboardEvent) {
        guard !session.trashItems.isEmpty else {
            return
        }

        switch event {
        case .move(let direction, let isExtendingSelection):
            moveFocus(direction: direction, isExtendingSelection: isExtendingSelection)
        case .toggleSelection:
            let item = session.trashItems[focusedIndex]
            selectionAnchorIndex = focusedIndex
            rangeSelectionBase = nil
            toggleSelection(item.url)
        case .preview:
            previewIndex = focusedIndex
        case .toggleAll:
            toggleAllSelection()
        case .restoreSelected:
            guard !selectedURLs.isEmpty else {
                return
            }
            restoreSelectedItems()
            clearSelectionState()
        case .deleteSelected:
            guard !selectedURLs.isEmpty else {
                return
            }
            session.confirmTrashBin(urls: selectedURLs)
            clearSelectionState()
            if session.trashItems.isEmpty {
                confirmAndClose?()
                dismiss()
            }
        case .deleteAll:
            session.confirmTrashBin()
            clearSelectionState()
            if session.trashItems.isEmpty {
                confirmAndClose?()
                dismiss()
            }
        }
    }

    private func moveFocus(direction: TrashBinMoveDirection, isExtendingSelection: Bool) {
        let previousIndex = focusedIndex
        let candidateIndex: Int

        switch direction {
        case .left:
            candidateIndex = focusedIndex - 1
        case .right:
            candidateIndex = focusedIndex + 1
        case .up:
            candidateIndex = focusedIndex - columnCount
        case .down:
            candidateIndex = focusedIndex + columnCount
        }

        focusedIndex = min(max(candidateIndex, 0), session.trashItems.count - 1)

        if isExtendingSelection {
            if rangeSelectionBase == nil {
                selectionAnchorIndex = previousIndex
                rangeSelectionBase = selectedURLs
                let anchorURL = session.trashItems[previousIndex].url
                rangeSelectionMode = selectedURLs.contains(anchorURL) ? .remove : .insert
            }
            applyRangeSelection(from: selectionAnchorIndex, to: focusedIndex)
        } else {
            rangeSelectionBase = nil
            rangeSelectionMode = nil
            selectionAnchorIndex = focusedIndex
        }
    }

    private func applyRangeSelection(from start: Int, to end: Int) {
        let lower = min(start, end)
        let upper = max(start, end)
        let originalSelection = rangeSelectionBase ?? selectedURLs
        let activeRangeURLs = Set(session.trashItems[lower...upper].map(\.url))

        switch rangeSelectionMode ?? .insert {
        case .insert:
            selectedURLs = originalSelection.union(activeRangeURLs)
        case .remove:
            selectedURLs = originalSelection.subtracting(activeRangeURLs)
        }
    }

    private func clampFocusedIndex() {
        guard !session.trashItems.isEmpty else {
            focusedIndex = 0
            selectionAnchorIndex = 0
            rangeSelectionBase = nil
            rangeSelectionMode = nil
            previewIndex = nil
            return
        }

        focusedIndex = min(max(focusedIndex, 0), session.trashItems.count - 1)
        selectionAnchorIndex = min(max(selectionAnchorIndex, 0), session.trashItems.count - 1)
    }

    private func clampPreviewIndex() {
        guard let previewIndex else {
            return
        }

        guard !session.trashItems.isEmpty else {
            self.previewIndex = nil
            return
        }

        self.previewIndex = min(max(previewIndex, 0), session.trashItems.count - 1)
    }
}

private struct TrashThumbnailCell: View {
    let item: PhotoItem
    let isSelected: Bool
    let isFocused: Bool
    let strings: AppStrings
    let toggleSelection: () -> Void

    var body: some View {
        Button(action: toggleSelection) {
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    MediaThumbnailView(item: item)
                        .frame(width: 96, height: 96)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.2), lineWidth: isSelected ? 3 : 1)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isFocused ? Color.accentColor.opacity(0.8) : Color.clear, lineWidth: 2)
                                .padding(-4)
                        }

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                        .padding(6)
                }

                Text(item.fileName)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)
                    .frame(width: 96, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 112, height: 136, alignment: .top)
        .help(strings.trashBin)
    }
}

private struct ButtonTitleWithKeyCaps: View {
    let title: String
    let keys: [String]

    var body: some View {
        HStack(spacing: 6) {
            Text(title)

            HStack(spacing: 3) {
                ForEach(keys, id: \.self) { key in
                    Text(key)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 5))
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.separator.opacity(0.35), lineWidth: 1)
                        }
                }
            }
        }
    }
}

private struct MediaThumbnailView: View {
    let item: PhotoItem
    @State private var videoThumbnail: NSImage?

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.quaternary)

            if item.kind.isVideo {
                if let videoThumbnail {
                    Image(nsImage: videoThumbnail)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.secondary)
                }
            } else if let image = NSImage(contentsOf: item.url) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 30))
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .clipped()
        .onAppear {
            guard item.kind.isVideo, videoThumbnail == nil else {
                return
            }

            generateVideoThumbnail(for: item.url)
        }
    }

    private func generateVideoThumbnail(for url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true

            guard let cgImage = try? generator.copyCGImage(at: .zero, actualTime: nil) else {
                return
            }

            let image = NSImage(cgImage: cgImage, size: .zero)
            DispatchQueue.main.async {
                videoThumbnail = image
            }
        }
    }
}

private struct TrashPreviewView: View {
    let items: [PhotoItem]
    @Binding var currentIndex: Int
    let strings: AppStrings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            PhotoViewer(photo: currentItem, strings: strings)
                .frame(width: 760, height: 520)

            HStack {
                Text(currentItem.fileName)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .background(.bar)
        }
        .frame(width: 760)
        .background(
            TrashPreviewKeyboardHandler(
                isActive: !items.isEmpty,
                onMove: movePreview,
                onClose: { dismiss() }
            )
        )
    }

    private var currentItem: PhotoItem {
        items[min(max(currentIndex, 0), items.count - 1)]
    }

    private func movePreview(_ direction: TrashBinMoveDirection) {
        switch direction {
        case .left, .up:
            currentIndex = max(currentIndex - 1, 0)
        case .right, .down:
            currentIndex = min(currentIndex + 1, items.count - 1)
        }
    }
}

private enum TrashBinKeyboardEvent {
    case move(TrashBinMoveDirection, isExtendingSelection: Bool)
    case toggleSelection
    case preview
    case toggleAll
    case restoreSelected
    case deleteSelected
    case deleteAll
}

private enum RangeSelectionMode {
    case insert
    case remove
}

private enum TrashBinMoveDirection {
    case left
    case right
    case up
    case down
}

private struct TrashBinKeyboardHandler: NSViewRepresentable {
    let isActive: Bool
    let onEvent: (TrashBinKeyboardEvent) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        context.coordinator.view = view
        updateCoordinator(context.coordinator)
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.view = nsView
        updateCoordinator(context.coordinator)
        DispatchQueue.main.async {
            if isActive {
                nsView.window?.makeFirstResponder(nsView)
            }
        }
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        coordinator.removeMonitor()
    }

    private func updateCoordinator(_ coordinator: Coordinator) {
        coordinator.isActive = isActive
        coordinator.onEvent = onEvent
        coordinator.updateMonitor()
    }

    final class Coordinator {
        weak var view: NSView?
        var isActive = false
        var onEvent: ((TrashBinKeyboardEvent) -> Void)?
        private var monitor: Any?

        func updateMonitor() {
            if isActive, monitor == nil {
                monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                    guard self?.handle(event) == true else {
                        return event
                    }
                    return nil
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

        private func handle(_ event: NSEvent) -> Bool {
            guard isActive, let view, event.window === view.window else {
                return false
            }

            let isExtendingSelection = event.modifierFlags.contains(.shift)
            let isCommand = event.modifierFlags.contains(.command)
            let keyboardEvent: TrashBinKeyboardEvent?

            let key = event.charactersIgnoringModifiers?.lowercased()

            if isCommand, key == "a" {
                keyboardEvent = .toggleAll
            } else if isCommand, key == "d" {
                keyboardEvent = .deleteAll
            } else {
                switch event.keyCode {
            case 123:
                keyboardEvent = .move(.left, isExtendingSelection: isExtendingSelection)
            case 124:
                keyboardEvent = .move(.right, isExtendingSelection: isExtendingSelection)
            case 125:
                keyboardEvent = .move(.down, isExtendingSelection: isExtendingSelection)
            case 126:
                keyboardEvent = .move(.up, isExtendingSelection: isExtendingSelection)
            case 36, 76:
                keyboardEvent = .toggleSelection
            case 49:
                keyboardEvent = .preview
            default:
                    if key == "r" {
                        keyboardEvent = .restoreSelected
                    } else if key == "d" {
                        keyboardEvent = .deleteSelected
                    } else {
                        keyboardEvent = nil
                    }
                }
            }

            guard let keyboardEvent else {
                return false
            }

            onEvent?(keyboardEvent)
            return true
        }
    }
}

private struct TrashPreviewKeyboardHandler: NSViewRepresentable {
    let isActive: Bool
    let onMove: (TrashBinMoveDirection) -> Void
    let onClose: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        context.coordinator.view = view
        updateCoordinator(context.coordinator)
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.view = nsView
        updateCoordinator(context.coordinator)
        DispatchQueue.main.async {
            if isActive {
                nsView.window?.makeFirstResponder(nsView)
            }
        }
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        coordinator.removeMonitor()
    }

    private func updateCoordinator(_ coordinator: Coordinator) {
        coordinator.isActive = isActive
        coordinator.onMove = onMove
        coordinator.onClose = onClose
        coordinator.updateMonitor()
    }

    final class Coordinator {
        weak var view: NSView?
        var isActive = false
        var onMove: ((TrashBinMoveDirection) -> Void)?
        var onClose: (() -> Void)?
        private var monitor: Any?

        func updateMonitor() {
            if isActive, monitor == nil {
                monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                    guard self?.handle(event) == true else {
                        return event
                    }
                    return nil
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

        private func handle(_ event: NSEvent) -> Bool {
            guard isActive, let view, event.window === view.window else {
                return false
            }

            let direction: TrashBinMoveDirection?
            switch event.keyCode {
            case 123:
                direction = .left
            case 124:
                direction = .right
            case 125:
                direction = .down
            case 126:
                direction = .up
            case 49:
                onClose?()
                return true
            default:
                direction = nil
            }

            guard let direction else {
                return false
            }

            onMove?(direction)
            return true
        }
    }
}
