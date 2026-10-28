import Foundation
import KPDCore

extension URL {
    var isExistingDirectory: Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
    }

    var isExistingRegularFile: Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && !isDirectory.boolValue
    }

    var isSupportedMediaFile: Bool {
        isExistingRegularFile && FolderScanner.supportedMediaExtensions.contains(pathExtension.lowercased())
    }

    var isExistingDirectoryOrSupportedMediaFile: Bool {
        isExistingDirectory || isSupportedMediaFile
    }
}
