import Foundation
import WASDPhotoCore

func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() {
        fputs("Smoke test failed: \(message)\n", stderr)
        exit(1)
    }
}

let folderURL = FileManager.default.temporaryDirectory
    .appendingPathComponent(UUID().uuidString, isDirectory: true)
try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
defer {
    try? FileManager.default.removeItem(at: folderURL)
}

try Data().write(to: folderURL.appendingPathComponent("b.PNG"))
try Data().write(to: folderURL.appendingPathComponent("a.jpg"))
try Data().write(to: folderURL.appendingPathComponent("c.mov"))
try Data().write(to: folderURL.appendingPathComponent("notes.txt"))
try FileManager.default.setAttributes(
    [.modificationDate: Date(timeIntervalSince1970: 200)],
    ofItemAtPath: folderURL.appendingPathComponent("b.PNG").path
)
try FileManager.default.setAttributes(
    [.modificationDate: Date(timeIntervalSince1970: 100)],
    ofItemAtPath: folderURL.appendingPathComponent("a.jpg").path
)
try FileManager.default.setAttributes(
    [.modificationDate: Date(timeIntervalSince1970: 300)],
    ofItemAtPath: folderURL.appendingPathComponent("c.mov").path
)
try FileManager.default.createDirectory(
    at: folderURL.appendingPathComponent("nested"),
    withIntermediateDirectories: false
)

let photos = try FolderScanner().scan(folderURL: folderURL)
expect(photos.map(\.fileName) == ["c.mov", "b.PNG", "a.jpg"], "FolderScanner should return supported media sorted newest to oldest by default.")
expect(photos.map(\.kind) == [.video, .image, .image], "FolderScanner should classify images and videos.")
expect(FolderScanner.containsSupportedMedia(urls: [folderURL]), "FolderScanner should report folders with supported media as openable.")

let emptyFolderURL = folderURL.appendingPathComponent("empty", isDirectory: true)
try FileManager.default.createDirectory(at: emptyFolderURL, withIntermediateDirectories: false)
expect(!FolderScanner.containsSupportedMedia(urls: [emptyFolderURL]), "FolderScanner should report empty folders as not openable.")

let oldestFirstPhotos = try FolderScanner().scan(folderURL: folderURL, sortOrder: .oldestFirst)
expect(oldestFirstPhotos.map(\.fileName) == ["a.jpg", "b.PNG", "c.mov"], "FolderScanner should support oldest to newest sorting.")

let selectedPhotos = try FolderScanner().scan(urls: [
    folderURL.appendingPathComponent("notes.txt"),
    folderURL.appendingPathComponent("c.mov"),
    folderURL.appendingPathComponent("b.PNG")
])
expect(selectedPhotos.map(\.fileName) == ["c.mov", "b.PNG"], "FolderScanner should open selected media files and ignore unsupported files.")

let session = PhotoSession()
session.open(folderURL: folderURL)
expect(session.photos.map(\.fileName) == ["c.mov", "b.PNG", "a.jpg"], "PhotoSession should open scanned media.")
session.setSortOrder(.oldestFirst)
expect(session.photos.map(\.fileName) == ["a.jpg", "b.PNG", "c.mov"], "PhotoSession should reorder current media.")
expect(session.currentIndex == 0, "PhotoSession should jump to the first item after changing sort order.")
session.currentIndex = 0
session.markCurrentPhotoForDeletion()
expect(session.photos.map(\.fileName) == ["b.PNG", "c.mov"], "Marked items should leave the browsing list.")
expect(session.trashItems.map(\.fileName) == ["a.jpg"], "Marked items should move into the app trash bin.")
session.undoLastAction()
expect(session.photos.map(\.fileName) == ["a.jpg", "b.PNG", "c.mov"], "Undo should restore the marked item to browsing.")
expect(session.trashItems.isEmpty, "Undo should remove the item from the app trash bin.")
session.renameCurrentPhoto(to: "renamed-a")
expect(session.currentPhoto?.fileName == "renamed-a.jpg", "Rename should update the current session item.")
expect(FileManager.default.fileExists(atPath: folderURL.appendingPathComponent("renamed-a.jpg").path), "Rename should move the file on disk.")

let selectedSession = PhotoSession()
selectedSession.open(urls: [
    folderURL.appendingPathComponent("c.mov"),
    folderURL.appendingPathComponent("b.PNG")
])
expect(selectedSession.photos.map(\.fileName) == ["c.mov", "b.PNG"], "PhotoSession should open selected media files.")

let restoreSession = PhotoSession()
restoreSession.open(folderURL: folderURL, sortOrder: .oldestFirst)
restoreSession.markCurrentPhotoForDeletion()
expect(restoreSession.trashItems.map(\.fileName) == ["renamed-a.jpg"], "Restore test should start with the oldest item in trash.")
restoreSession.restoreFromTrash(restoreSession.trashItems[0])
expect(restoreSession.photos.map(\.fileName) == ["renamed-a.jpg", "b.PNG", "c.mov"], "Restored items should keep the active sort order.")

let discardSession = PhotoSession()
discardSession.open(folderURL: folderURL, sortOrder: .newestFirst)
discardSession.markCurrentPhotoForDeletion()
discardSession.markCurrentPhotoForDeletion()
discardSession.discardPendingTrashChanges()
expect(discardSession.trashItems.isEmpty, "Discarding pending changes should empty the app trash.")
expect(discardSession.photos.map(\.fileName) == ["c.mov", "b.PNG", "renamed-a.jpg"], "Discarding pending changes should restore trash items in active sort order.")
discardSession.undoLastAction()
expect(discardSession.trashItems.isEmpty, "Discarding pending changes should clear undo history for pending trash actions.")

let fakeTrashService = TrashService { urls in
    TrashResult(trashed: urls, failed: [])
}
let deleteSession = PhotoSession(trashService: fakeTrashService)
deleteSession.open(folderURL: folderURL, sortOrder: .newestFirst)
deleteSession.markCurrentPhotoForDeletion()
deleteSession.markCurrentPhotoForDeletion()
expect(deleteSession.trashItems.map(\.fileName) == ["c.mov", "b.PNG"], "Delete test should queue two items in the app trash bin.")
let confirmedDeleteURL = deleteSession.trashItems[0].url
deleteSession.confirmTrashBin(urls: [confirmedDeleteURL])
expect(deleteSession.trashItems.map(\.fileName) == ["b.PNG"], "Confirming selected deletes should leave unconfirmed trash items queued.")
deleteSession.undoLastAction()
expect(deleteSession.photos.map(\.fileName).contains("b.PNG"), "Undo should still restore unconfirmed trash items.")
deleteSession.undoLastAction()
expect(!deleteSession.photos.map(\.fileName).contains("c.mov"), "Undo should not restore items after confirmed deletion.")

print("WASDPhotoCoreSmokeTests passed")
