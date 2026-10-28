import Foundation

struct OrganizerInput: Codable, Hashable {
    var sessionID: UUID
    var urls: [URL]

    init(urls: [URL], sessionID: UUID = UUID()) {
        self.sessionID = sessionID
        self.urls = urls
    }

    init(url: URL, sessionID: UUID = UUID()) {
        self.sessionID = sessionID
        self.urls = [url]
    }
}
