import Foundation

public struct PhotoItem: Identifiable, Hashable, Sendable {
    public var id: URL { url }
    public var url: URL
    public var fileName: String
    public let kind: MediaKind
    public let sortDate: Date

    public init(url: URL, kind: MediaKind, sortDate: Date = .distantPast) {
        self.url = url
        self.fileName = url.lastPathComponent
        self.kind = kind
        self.sortDate = sortDate
    }
}

public enum MediaKind: String, Sendable {
    case image
    case video

    public var isVideo: Bool {
        self == .video
    }
}
