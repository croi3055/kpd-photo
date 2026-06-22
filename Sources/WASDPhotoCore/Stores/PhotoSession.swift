import Foundation
import Observation

@Observable
public final class PhotoSession {
    public private(set) var folderURL: URL?
    public private(set) var photos: [PhotoItem] = []
    public var currentIndex: Int = 0
    public private(set) var trashItems: [PhotoItem] = []
    public private(set) var lastTrashResult: TrashResult?
    public var error: PhotoSessionError?
    public private(set) var sortOrder: MediaSortOrder = .newestFirst

    private var actionHistory: [SessionAction] = []
    private let scanner: FolderScanner
    private let trashService: TrashService

    public init(
        scanner: FolderScanner = FolderScanner(),
        trashService: TrashService = TrashService()
    ) {
        self.scanner = scanner
        self.trashService = trashService
    }

    public var currentPhoto: PhotoItem? {
        guard photos.indices.contains(currentIndex) else {
            return nil
        }

        return photos[currentIndex]
    }

    public var hasPhotos: Bool {
        !photos.isEmpty
    }

    public var currentPositionText: String {
        guard hasPhotos else {
            return "0 / 0"
        }

        return "\(currentIndex + 1) / \(photos.count)"
    }

    public var isAtLastPhoto: Bool {
        hasPhotos && currentIndex == photos.count - 1
    }

    public func open(folderURL: URL, sortOrder: MediaSortOrder = .newestFirst) {
        open(urls: [folderURL], sortOrder: sortOrder)
    }

    public func open(urls: [URL], sortOrder: MediaSortOrder = .newestFirst) {
        do {
            let scannedPhotos = try scanner.scan(urls: urls, sortOrder: sortOrder)
            self.sortOrder = sortOrder
            self.folderURL = urls.count == 1 ? urls.first : nil
            self.photos = scannedPhotos
            self.currentIndex = 0
            self.trashItems = []
            self.actionHistory = []
            self.lastTrashResult = nil
            self.error = scannedPhotos.isEmpty ? .noSupportedMedia : nil
        } catch {
            self.error = .system(error.localizedDescription)
        }
    }

    public func setSortOrder(_ sortOrder: MediaSortOrder) {
        guard self.sortOrder != sortOrder else {
            return
        }

        self.sortOrder = sortOrder
        photos = sorted(items: photos)
        trashItems = sorted(items: trashItems)
        currentIndex = 0
    }

    public func showPreviousPhoto() {
        guard !photos.isEmpty else {
            return
        }

        currentIndex = max(currentIndex - 1, 0)
    }

    public func showNextPhoto() {
        guard !photos.isEmpty else {
            return
        }

        currentIndex = min(currentIndex + 1, photos.count - 1)
    }

    public func markCurrentPhotoForDeletion() {
        guard let currentPhoto else {
            return
        }

        let removedIndex = currentIndex

        photos.remove(at: removedIndex)
        trashItems.append(currentPhoto)

        if currentIndex >= photos.count {
            currentIndex = max(photos.count - 1, 0)
        }

        actionHistory.append(.markDeletion(currentPhoto, removedIndex))
    }

    public func undoLastAction() {
        guard let action = actionHistory.popLast() else {
            return
        }

        switch action {
        case .markDeletion(let item, let originalIndex):
            trashItems.removeAll { $0.url == item.url }
            let insertionIndex = min(originalIndex, photos.count)
            photos.insert(item, at: insertionIndex)
            currentIndex = insertionIndex
        }
    }

    public var trashCount: Int {
        trashItems.count
    }

    public var hasPendingTrash: Bool {
        !trashItems.isEmpty
    }

    public func restoreFromTrash(_ item: PhotoItem) {
        guard let trashIndex = trashItems.firstIndex(where: { $0.url == item.url }) else {
            return
        }

        let restoredItem = trashItems.remove(at: trashIndex)
        photos.append(restoredItem)
        photos = sorted(items: photos)
        if let restoredIndex = photos.firstIndex(where: { $0.url == restoredItem.url }) {
            currentIndex = restoredIndex
        }
    }

    public func restoreFromTrash(urls: Set<URL>) {
        for url in urls {
            guard let item = trashItems.first(where: { $0.url == url }) else {
                continue
            }
            restoreFromTrash(item)
        }
    }

    public func discardPendingTrashChanges() {
        let pendingItems = trashItems
        guard !pendingItems.isEmpty else {
            return
        }

        trashItems.removeAll()
        photos.append(contentsOf: pendingItems)
        photos = sorted(items: photos)
        actionHistory.removeAll()
        currentIndex = min(max(currentIndex, 0), max(photos.count - 1, 0))
    }

    public func confirmTrashBin(urls targetURLs: Set<URL>? = nil) {
        let itemsToTrash = trashItems.filter { item in
            targetURLs?.contains(item.url) ?? true
        }

        let items = itemsToTrash.sorted {
            $0.fileName.localizedStandardCompare($1.fileName) == .orderedAscending
        }
        let urls = items.map(\.url)

        guard !urls.isEmpty else {
            return
        }

        let result = trashService.moveToTrash(urls: urls)
        lastTrashResult = result

        let trashedSet = Set(result.trashed)
        trashItems.removeAll { trashedSet.contains($0.url) }
        actionHistory.removeAll { action in
            trashedSet.contains(action.affectedURL)
        }

        if currentIndex >= photos.count {
            currentIndex = max(photos.count - 1, 0)
        }

        if !result.failed.isEmpty {
            error = .trashMoveFailed(result.failed.count)
        }
    }

    public func renameCurrentPhoto(to baseName: String) {
        guard let currentPhoto else {
            return
        }

        let trimmedBaseName = baseName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBaseName.isEmpty else {
            error = .emptyRename
            return
        }

        let ext = currentPhoto.url.pathExtension
        let newFileName = ext.isEmpty ? trimmedBaseName : "\(trimmedBaseName).\(ext)"
        guard newFileName != currentPhoto.fileName else {
            return
        }

        let destinationURL = currentPhoto.url
            .deletingLastPathComponent()
            .appendingPathComponent(newFileName)

        guard !FileManager.default.fileExists(atPath: destinationURL.path) else {
            error = .renameConflict(newFileName)
            return
        }

        do {
            try FileManager.default.moveItem(at: currentPhoto.url, to: destinationURL)
            let renamedItem = PhotoItem(url: destinationURL, kind: currentPhoto.kind, sortDate: currentPhoto.sortDate)
            photos[currentIndex] = renamedItem
        } catch {
            self.error = .system(error.localizedDescription)
        }
    }

    private func sorted(items: [PhotoItem]) -> [PhotoItem] {
        items.sorted { lhs, rhs in
            if lhs.sortDate != rhs.sortDate {
                switch sortOrder {
                case .newestFirst:
                    return lhs.sortDate > rhs.sortDate
                case .oldestFirst:
                    return lhs.sortDate < rhs.sortDate
                }
            }

            return lhs.fileName.localizedStandardCompare(rhs.fileName) == .orderedAscending
        }
    }
}

public enum PhotoSessionError: Equatable, Sendable {
    case noSupportedMedia
    case trashMoveFailed(Int)
    case emptyRename
    case renameConflict(String)
    case system(String)
}

private enum SessionAction {
    case markDeletion(PhotoItem, Int)

    var affectedURL: URL {
        switch self {
        case .markDeletion(let item, _):
            return item.url
        }
    }
}
