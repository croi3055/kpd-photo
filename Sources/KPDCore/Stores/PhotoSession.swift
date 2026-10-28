import Foundation
import Observation

@Observable
public final class PhotoSession {
    public private(set) var folderURL: URL?
    public private(set) var photos: [PhotoItem] = []
    public var currentIndex: Int = 0
    public private(set) var trashItems: [PhotoItem] = []
    public private(set) var keptItems: [PhotoItem] = []
    public private(set) var lastTrashResult: TrashResult?
    public private(set) var lastKeepResult: KeepResult?
    public var error: PhotoSessionError?
    public private(set) var sortOrder: MediaSortOrder = .newestFirst

    private var actionHistory: [SessionAction] = []
    private let scanner: FolderScanner
    private let trashService: TrashService
    private let keepService: KeepService

    public init(
        scanner: FolderScanner = FolderScanner(),
        trashService: TrashService = TrashService(),
        keepService: KeepService = KeepService()
    ) {
        self.scanner = scanner
        self.trashService = trashService
        self.keepService = keepService
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
            self.keptItems = []
            self.actionHistory = []
            self.lastTrashResult = nil
            self.lastKeepResult = nil
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
        keptItems = sorted(items: keptItems)
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

    public func keepCurrentPhoto() {
        guard let currentPhoto else {
            return
        }

        let removedIndex = currentIndex

        photos.remove(at: removedIndex)
        keptItems.append(currentPhoto)

        if currentIndex >= photos.count {
            currentIndex = max(photos.count - 1, 0)
        }

        actionHistory.append(.keep(currentPhoto, removedIndex))
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
        case .keep(let item, let originalIndex):
            keptItems.removeAll { $0.url == item.url }
            let insertionIndex = min(originalIndex, photos.count)
            photos.insert(item, at: insertionIndex)
            currentIndex = insertionIndex
        }
    }

    public var keptCount: Int {
        keptItems.count
    }

    public var trashCount: Int {
        trashItems.count
    }

    public var hasPendingTrash: Bool {
        !trashItems.isEmpty
    }

    public var hasPendingKeep: Bool {
        !keptItems.isEmpty
    }

    public var hasPendingChanges: Bool {
        hasPendingKeep || hasPendingTrash
    }

    public func restoreFromTrash(_ item: PhotoItem) {
        guard let trashIndex = trashItems.firstIndex(where: { $0.url == item.url }) else {
            return
        }

        let restoredItem = trashItems.remove(at: trashIndex)
        photos.append(restoredItem)
        photos = sorted(items: photos)
        actionHistory.removeAll { $0.affectedURL == restoredItem.url }
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

    public func moveKeptToPending(_ item: PhotoItem) {
        guard let keptIndex = keptItems.firstIndex(where: { $0.url == item.url }) else {
            return
        }

        let pendingItem = keptItems.remove(at: keptIndex)
        photos.append(pendingItem)
        photos = sorted(items: photos)
        actionHistory.removeAll { $0.affectedURL == pendingItem.url }
        if let pendingIndex = photos.firstIndex(where: { $0.url == pendingItem.url }) {
            currentIndex = pendingIndex
        }
    }

    public func moveKeptToPending(urls: Set<URL>) {
        for url in urls {
            guard let item = keptItems.first(where: { $0.url == url }) else {
                continue
            }
            moveKeptToPending(item)
        }
    }

    public func discardPendingChanges() {
        let pendingItems = trashItems + keptItems
        guard !pendingItems.isEmpty else {
            return
        }

        trashItems.removeAll()
        keptItems.removeAll()
        photos.append(contentsOf: pendingItems)
        photos = sorted(items: photos)
        actionHistory.removeAll()
        currentIndex = min(max(currentIndex, 0), max(photos.count - 1, 0))
    }

    public func discardPendingTrashChanges() {
        discardPendingChanges()
    }

    public func confirmKeepBox(urls targetURLs: Set<URL>? = nil) {
        let itemsToKeep = keptItems.filter { item in
            targetURLs?.contains(item.url) ?? true
        }

        let items = itemsToKeep.sorted {
            $0.fileName.localizedStandardCompare($1.fileName) == .orderedAscending
        }
        let urls = items.map(\.url)

        guard !urls.isEmpty else {
            return
        }

        let result = keepService.moveToKeep(urls: urls)
        lastKeepResult = result

        let movedSet = Set(result.moved)
        keptItems.removeAll { movedSet.contains($0.url) }
        actionHistory.removeAll { action in
            movedSet.contains(action.affectedURL)
        }

        if currentIndex >= photos.count {
            currentIndex = max(photos.count - 1, 0)
        }

        if !result.failed.isEmpty {
            error = .keepMoveFailed(result.failed.count)
        }
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
            actionHistory = actionHistory.map { $0.replacingURL(currentPhoto.url, with: destinationURL) }
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
    case keepMoveFailed(Int)
    case emptyRename
    case renameConflict(String)
    case system(String)
}

private enum SessionAction {
    case markDeletion(PhotoItem, Int)
    case keep(PhotoItem, Int)

    var affectedURL: URL {
        switch self {
        case .markDeletion(let item, _):
            return item.url
        case .keep(let item, _):
            return item.url
        }
    }

    func replacingURL(_ oldURL: URL, with newURL: URL) -> SessionAction {
        switch self {
        case .markDeletion(let item, let index):
            guard item.url == oldURL else {
                return self
            }
            let renamedItem = PhotoItem(url: newURL, kind: item.kind, sortDate: item.sortDate)
            return .markDeletion(renamedItem, index)
        case .keep(let item, let index):
            guard item.url == oldURL else {
                return self
            }
            let renamedItem = PhotoItem(url: newURL, kind: item.kind, sortDate: item.sortDate)
            return .keep(renamedItem, index)
        }
    }
}
