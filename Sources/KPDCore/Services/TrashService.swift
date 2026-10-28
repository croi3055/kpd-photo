import Foundation

public struct TrashResult: Sendable {
    public let trashed: [URL]
    public let failed: [TrashFailure]

    public init(trashed: [URL], failed: [TrashFailure]) {
        self.trashed = trashed
        self.failed = failed
    }
}

public struct TrashFailure: Identifiable, Sendable {
    public let id = UUID()
    public let url: URL
    public let errorDescription: String

    public init(url: URL, errorDescription: String) {
        self.url = url
        self.errorDescription = errorDescription
    }
}

public struct TrashService {
    private let moveToTrashHandler: ([URL]) -> TrashResult

    public init(fileManager: FileManager = .default) {
        self.moveToTrashHandler = { urls in
            var trashed: [URL] = []
            var failed: [TrashFailure] = []

            for url in urls {
                do {
                    var resultingURL: NSURL?
                    try fileManager.trashItem(at: url, resultingItemURL: &resultingURL)
                    trashed.append(url)
                } catch {
                    failed.append(TrashFailure(url: url, errorDescription: error.localizedDescription))
                }
            }

            return TrashResult(trashed: trashed, failed: failed)
        }
    }

    public init(moveToTrashHandler: @escaping ([URL]) -> TrashResult) {
        self.moveToTrashHandler = moveToTrashHandler
    }

    public func moveToTrash(urls: [URL]) -> TrashResult {
        moveToTrashHandler(urls)
    }
}
