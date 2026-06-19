import AppKit

enum FolderPicker {
    static func chooseFolder(prompt: String) -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = prompt

        guard panel.runModal() == .OK else {
            return nil
        }

        return panel.url
    }
}
