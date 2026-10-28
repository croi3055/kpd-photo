import AppKit

enum FolderPicker {
    static func chooseFolder(strings: AppStrings) -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = strings.openFolder
        panel.title = strings.openFolderPanelTitle
        panel.message = strings.openFolderPanelMessage

        guard panel.runModal() == .OK else {
            return nil
        }

        return panel.url
    }
}
