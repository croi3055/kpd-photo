import Foundation
import UniformTypeIdentifiers

enum DroppedFileURLs {
    static func load(from providers: [NSItemProvider], completion: @escaping ([URL]) -> Void) -> Bool {
        let fileProviders = providers.filter {
            $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
        }

        guard !fileProviders.isEmpty else {
            return false
        }

        var urlsByIndex = Array<URL?>(repeating: nil, count: fileProviders.count)
        let group = DispatchGroup()
        let lock = NSLock()

        for (index, provider) in fileProviders.enumerated() {
            group.enter()
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                let url = url(from: item)
                lock.lock()
                urlsByIndex[index] = url
                lock.unlock()
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(urlsByIndex.compactMap { $0 })
        }

        return true
    }

    private static func url(from item: NSSecureCoding?) -> URL? {
        if let data = item as? Data {
            return URL(dataRepresentation: data, relativeTo: nil)
        }

        if let url = item as? URL {
            return url
        }

        if let nsURL = item as? NSURL {
            return nsURL as URL
        }

        return nil
    }
}
