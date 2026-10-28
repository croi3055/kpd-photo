import Foundation

public struct FolderScanner {
    public static let supportedImageExtensions: Set<String> = [
        "jpg",
        "jpeg",
        "png",
        "heic",
        "heif",
        "webp",
        "tif",
        "tiff",
        "gif"
    ]

    public static let supportedVideoExtensions: Set<String> = [
        "mov",
        "mp4",
        "m4v",
        "avi",
        "mkv"
    ]

    public static let supportedMediaExtensions = supportedImageExtensions.union(supportedVideoExtensions)

    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public static func containsSupportedMedia(urls: [URL]) -> Bool {
        do {
            return try FolderScanner().scan(urls: urls).isEmpty == false
        } catch {
            return false
        }
    }

    public func scan(folderURL: URL, sortOrder: MediaSortOrder = .newestFirst) throws -> [PhotoItem] {
        let resourceKeys: Set<URLResourceKey> = [.isRegularFileKey, .isHiddenKey]
        let urls = try fileManager.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsHiddenFiles]
        )

        return try sortedMediaItems(from: urls, sortOrder: sortOrder)
    }

    public func scan(urls: [URL], sortOrder: MediaSortOrder = .newestFirst) throws -> [PhotoItem] {
        var items: [PhotoItem] = []

        for url in urls {
            if try isDirectory(url) {
                items.append(contentsOf: try scan(folderURL: url, sortOrder: sortOrder))
            } else if let item = try mediaItem(from: url) {
                items.append(item)
            }
        }

        var seenURLs = Set<URL>()
        return sort(items: items
            .filter { item in
                let canonicalURL = item.url.standardizedFileURL
                guard !seenURLs.contains(canonicalURL) else {
                    return false
                }
                seenURLs.insert(canonicalURL)
                return true
            },
            sortOrder: sortOrder
        )
    }

    private func mediaItem(from url: URL) throws -> PhotoItem? {
        let resourceKeys: Set<URLResourceKey> = [.isRegularFileKey, .isHiddenKey, .contentModificationDateKey, .creationDateKey]
        let values = try url.resourceValues(forKeys: resourceKeys)
        guard values.isRegularFile == true, values.isHidden != true else {
            return nil
        }

        let ext = url.pathExtension.lowercased()
        guard Self.supportedMediaExtensions.contains(ext) else {
            return nil
        }

        let kind: MediaKind = Self.supportedVideoExtensions.contains(ext) ? .video : .image
        let sortDate = values.contentModificationDate ?? values.creationDate ?? .distantPast
        return PhotoItem(url: url, kind: kind, sortDate: sortDate)
    }

    private func isDirectory(_ url: URL) throws -> Bool {
        try url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true
    }

    private func sortedMediaItems(from urls: [URL], sortOrder: MediaSortOrder) throws -> [PhotoItem] {
        try sort(
            items: urls.compactMap { url in
                try mediaItem(from: url)
            },
            sortOrder: sortOrder
        )
    }

    private func sort(items: [PhotoItem], sortOrder: MediaSortOrder) -> [PhotoItem] {
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
