import Foundation

public struct KeepResult: Sendable {
    public let moved: [URL]
    public let failed: [KeepFailure]

    public init(moved: [URL], failed: [KeepFailure]) {
        self.moved = moved
        self.failed = failed
    }
}

public struct KeepFailure: Identifiable, Sendable {
    public let id = UUID()
    public let url: URL
    public let errorDescription: String

    public init(url: URL, errorDescription: String) {
        self.url = url
        self.errorDescription = errorDescription
    }
}

public struct KeepService {
    private let moveToKeepHandler: ([URL]) -> KeepResult

    public init(fileManager: FileManager = .default, folderName: String = "Keep") {
        self.moveToKeepHandler = { urls in
            var moved: [URL] = []
            var failed: [KeepFailure] = []

            for url in urls {
                do {
                    let keepFolderURL = url.deletingLastPathComponent().appendingPathComponent(folderName, isDirectory: true)
                    try fileManager.createDirectory(at: keepFolderURL, withIntermediateDirectories: true)
                    let destinationURL = uniqueDestinationURL(for: url, in: keepFolderURL, fileManager: fileManager)
                    try fileManager.moveItem(at: url, to: destinationURL)
                    moved.append(url)
                } catch {
                    failed.append(KeepFailure(url: url, errorDescription: error.localizedDescription))
                }
            }

            return KeepResult(moved: moved, failed: failed)
        }
    }

    public init(moveToKeepHandler: @escaping ([URL]) -> KeepResult) {
        self.moveToKeepHandler = moveToKeepHandler
    }

    public func moveToKeep(urls: [URL]) -> KeepResult {
        moveToKeepHandler(urls)
    }
}

private func uniqueDestinationURL(for sourceURL: URL, in folderURL: URL, fileManager: FileManager) -> URL {
    let baseName = sourceURL.deletingPathExtension().lastPathComponent
    let fileExtension = sourceURL.pathExtension
    var candidateURL = folderURL.appendingPathComponent(sourceURL.lastPathComponent)
    var suffix = 2

    while fileManager.fileExists(atPath: candidateURL.path) {
        let candidateName = fileExtension.isEmpty ? "\(baseName) \(suffix)" : "\(baseName) \(suffix).\(fileExtension)"
        candidateURL = folderURL.appendingPathComponent(candidateName)
        suffix += 1
    }

    return candidateURL
}
