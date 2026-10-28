import Foundation
import KPDCore

struct AppStrings {
    let language: AppLanguage
    let reloadToken: Int

    var openFolder: String { text("openFolder") }
    var openFolderMenu: String { text("openFolderMenu") }
    var openFolderPanelTitle: String { text("openFolderPanelTitle") }
    var openFolderPanelMessage: String { text("openFolderPanelMessage") }
    var aboutMenu: String { text("aboutMenu") }
    var settingsMenu: String { text("settingsMenu") }
    var quitMenu: String { text("quitMenu") }
    var hideMenu: String { text("hideMenu") }
    var hideOthersMenu: String { text("hideOthersMenu") }
    var showAllMenu: String { text("showAllMenu") }
    var helpMenu: String { text("helpMenu") }
    var fileMenu: String { text("fileMenu") }
    var editMenu: String { text("editMenu") }
    var viewMenu: String { text("viewMenu") }
    var windowMenu: String { text("windowMenu") }
    var helpTopMenu: String { text("helpTopMenu") }
    var cutMenu: String { text("cutMenu") }
    var copyMenu: String { text("copyMenu") }
    var pasteMenu: String { text("pasteMenu") }
    var selectAllMenu: String { text("selectAllMenu") }
    var undo: String { text("undo") }
    var confirmDeletes: String { text("confirmDeletes") }
    var movePhotosToTrashTitle: String { text("movePhotosToTrashTitle") }
    var cancel: String { text("cancel") }
    var ok: String { text("ok") }
    var moveToTrash: String { text("moveToTrash") }
    var trashBin: String { text("trashBin") }
    var keepBox: String { text("keepBox") }
    var openTrashBin: String { text("openTrashBin") }
    var openKeepBox: String { text("openKeepBox") }
    var showInFinder: String { text("showInFinder") }
    var openInPreview: String { text("openInPreview") }
    var shareViaAirDrop: String { text("shareViaAirDrop") }
    var emptyTrash: String { text("emptyTrash") }
    var moveSelectedToTrash: String { text("moveSelectedToTrash") }
    var restoreSelected: String { text("restoreSelected") }
    var restoreAll: String { text("restoreAll") }
    var backToPending: String { text("backToPending") }
    var allBackToPending: String { text("allBackToPending") }
    var selectAll: String { text("selectAll") }
    var deselectAll: String { text("deselectAll") }
    var emptyTrashTitle: String { text("emptyTrashTitle") }
    var moveToTrashAndClose: String { text("moveToTrashAndClose") }
    var applyAndClose: String { text("applyAndClose") }
    var discardChangesAndClose: String { text("discardChangesAndClose") }
    var restore: String { text("restore") }
    var emptyTrashBin: String { text("emptyTrashBin") }
    var unsupportedMediaError: String { text("unsupportedMediaError") }
    var unableToLoadImage: String { text("unableToLoadImage") }
    var renameFileTitle: String { text("renameFileTitle") }
    var rename: String { text("rename") }
    var fileNamePlaceholder: String { text("fileNamePlaceholder") }
    var browsingCompleteMessage: String { text("browsingCompleteMessage") }
    var sortNewestFirst: String { text("sortNewestFirst") }
    var sortOldestFirst: String { text("sortOldestFirst") }
    var previewTrashItem: String { text("previewTrashItem") }
    var noFolderSelected: String { text("noFolderSelected") }
    var markedForTrash: String { text("markedForTrash") }
    var noImportNoCache: String { text("noImportNoCache") }
    var appTitle: String { text("appTitle") }
    var shortcuts: String { text("shortcuts") }
    var gettingStartedTitle: String { text("gettingStartedTitle") }
    var gettingStartedMessage: String { text("gettingStartedMessage") }
    var gotIt: String { text("gotIt") }
    var privacyPromise: String { text("privacyPromise") }
    var dragFolderTitle: String { text("dragFolderTitle") }
    var dragFolderSubtitle: String { text("dragFolderSubtitle") }
    var privacyPromiseBody: String { text("privacyPromiseBody") }
    var actionOpenFolder: String { text("actionOpenFolder") }
    var actionPreviousItem: String { text("actionPreviousItem") }
    var actionNextItem: String { text("actionNextItem") }
    var actionKeepItem: String { text("actionKeepItem") }
    var actionMarkForTrash: String { text("actionMarkForTrash") }
    var actionUndo: String { text("actionUndo") }
    var actionReviewDeletes: String { text("actionReviewDeletes") }
    var actionToggleTimeInfo: String { text("actionToggleTimeInfo") }
    var actionOpenNewWindow: String { text("actionOpenNewWindow") }
    var keyButton: String { text("keyButton") }
    var keyDropFolder: String { text("keyDropFolder") }
    var settingsTitle: String { text("settingsTitle") }
    var languageTitle: String { text("languageTitle") }
    var appearanceTitle: String { text("appearanceTitle") }
    var systemAppearance: String { text("systemAppearance") }
    var lightAppearance: String { text("lightAppearance") }
    var darkAppearance: String { text("darkAppearance") }
    var generalSettings: String { text("generalSettings") }
    var contentSettings: String { text("contentSettings") }
    var reloadText: String { text("reloadText") }
    var settingsFooter: String { text("settingsFooter") }
    var folderAlreadyOpenTitle: String { text("folderAlreadyOpenTitle") }
    var folderAlreadyOpenMessage: String { text("folderAlreadyOpenMessage") }
    var dropToOpenNewWindow: String { text("dropToOpenNewWindow") }

    func trashSummary(photoCount: Int, videoCount: Int) -> String {
        let photoUnit = photoCount == 1 ? text("photoUnitSingular") : text("photoUnitPlural")
        let videoUnit = videoCount == 1 ? text("videoUnitSingular") : text("videoUnitPlural")
        return text("trashSummary", "\(photoCount) \(photoUnit)", "\(videoCount) \(videoUnit)")
    }

    func deleteConfirmationMessage(count: Int) -> String {
        text("deleteConfirmationMessage", count)
    }

    func emptyTrashMessage(count: Int) -> String {
        text("emptyTrashMessage", count)
    }

    func closeWithTrashMessage(count: Int) -> String {
        text("closeWithTrashMessage", count)
    }

    func closeWithKeepMessage(count: Int) -> String {
        text("closeWithKeepMessage", count)
    }

    var closeWithTrashTitle: String { text("closeWithTrashTitle") }
    var closeWithChangesTitle: String { text("closeWithChangesTitle") }

    func closeWithChangesMessage(keepCount: Int, trashCount: Int) -> String {
        if keepCount > 0, trashCount == 0 {
            return closeWithKeepMessage(count: keepCount)
        }

        if trashCount > 0, keepCount == 0 {
            return closeWithTrashMessage(count: trashCount)
        }

        return text("closeWithChangesMessage", keepCount, trashCount)
    }

    func markedCount(_ count: Int) -> String {
        text("markedCount", count)
    }

    func message(for error: PhotoSessionError) -> String {
        switch error {
        case .noSupportedMedia:
            return text("unsupportedMediaError")
        case .trashMoveFailed(let count):
            return text("trashMoveFailedError", count)
        case .keepMoveFailed(let count):
            return text("keepMoveFailedError", count)
        case .emptyRename:
            return text("emptyRenameError")
        case .renameConflict(let fileName):
            return text("renameConflictError", fileName)
        case .system(let message):
            return message
        }
    }

    private func text(_ key: String) -> String {
        AppStringCatalog.shared.text(key, language: language)
    }

    private func text(_ key: String, _ value: CustomStringConvertible) -> String {
        AppStringCatalog.shared.text(key, language: language, value)
    }

    private func text(_ key: String, _ firstValue: CustomStringConvertible, _ secondValue: CustomStringConvertible) -> String {
        AppStringCatalog.shared.text(key, language: language, firstValue, secondValue)
    }
}

private final class AppStringCatalog {
    static let shared = AppStringCatalog()

    private init() {}

    func text(
        _ key: String,
        language: AppLanguage,
        _ values: CustomStringConvertible...
    ) -> String {
        let entries = loadEntries()
        let languageKey = language.rawValue
        let template = entries[key]?[languageKey]
            ?? entries[key]?[AppLanguage.english.rawValue]
            ?? Self.fallbackEntries[key]?[languageKey]
            ?? Self.fallbackEntries[key]?[AppLanguage.english.rawValue]
            ?? key

        guard !values.isEmpty else {
            return template
        }

        return String(format: template, arguments: values.map { String(describing: $0) })
    }

    private func loadEntries() -> [String: [String: String]] {
        for url in editableContentURLs() {
            guard
                let data = try? Data(contentsOf: url),
                let decoded = try? JSONDecoder().decode([String: [String: String]].self, from: data)
            else {
                continue
            }

            return decoded.merging(Self.fallbackEntries) { loaded, _ in loaded }
        }

        return Self.fallbackEntries
    }

    private func editableContentURLs() -> [URL] {
        var urls: [URL] = []

        let projectRootFromBundle = Bundle.main.bundleURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        urls.append(
            projectRootFromBundle
                .appendingPathComponent("Sources/KPD/Resources/LocalizableContent.json")
        )

        if let bundledURL = Bundle.module.url(forResource: "LocalizableContent", withExtension: "json") {
            urls.append(bundledURL)
        }

        return urls
    }

    private static let fallbackEntries: [String: [String: String]] = [
        "openFolder": ["english": "Open Folder", "chinese": "打开文件夹"],
        "openFolderMenu": ["english": "Open Folder...", "chinese": "打开文件夹..."],
        "openFolderPanelTitle": ["english": "Open Folder", "chinese": "打开文件夹"],
        "openFolderPanelMessage": [
            "english": "Choose a folder that contains photos or videos.",
            "chinese": "选择包含图片或视频的文件夹。"
        ],
        "aboutMenu": ["english": "About KPD", "chinese": "关于 KPD"],
        "settingsMenu": ["english": "Settings...", "chinese": "设置..."],
        "quitMenu": ["english": "Quit KPD", "chinese": "退出 KPD"],
        "hideMenu": ["english": "Hide KPD", "chinese": "隐藏 KPD"],
        "hideOthersMenu": ["english": "Hide Others", "chinese": "隐藏其他"],
        "showAllMenu": ["english": "Show All", "chinese": "全部显示"],
        "helpMenu": ["english": "KPD Help", "chinese": "KPD 帮助"],
        "fileMenu": ["english": "File", "chinese": "文件"],
        "editMenu": ["english": "Edit", "chinese": "编辑"],
        "viewMenu": ["english": "View", "chinese": "显示"],
        "windowMenu": ["english": "Window", "chinese": "窗口"],
        "helpTopMenu": ["english": "Help", "chinese": "帮助"],
        "cutMenu": ["english": "Cut", "chinese": "剪切"],
        "copyMenu": ["english": "Copy", "chinese": "复制"],
        "pasteMenu": ["english": "Paste", "chinese": "粘贴"],
        "selectAllMenu": ["english": "Select All", "chinese": "全选"],
        "undo": ["english": "Undo", "chinese": "撤销"],
        "confirmDeletes": ["english": "Confirm Delete", "chinese": "确认删除"],
        "movePhotosToTrashTitle": ["english": "Delete Items?", "chinese": "确认删除？"],
        "cancel": ["english": "Cancel", "chinese": "取消"],
        "ok": ["english": "OK", "chinese": "好"],
        "moveToTrash": ["english": "Mark for Deletion", "chinese": "加入垃圾桶"],
        "trashBin": ["english": "Trash", "chinese": "垃圾桶"],
        "keepBox": ["english": "Keep Box", "chinese": "保留箱"],
        "openTrashBin": ["english": "Open Trash", "chinese": "打开垃圾桶"],
        "openKeepBox": ["english": "Open Keep Box", "chinese": "打开保留箱"],
        "showInFinder": ["english": "Show in Finder", "chinese": "在 Finder 中显示"],
        "openInPreview": ["english": "Open in Preview", "chinese": "在预览中打开"],
        "shareViaAirDrop": ["english": "AirDrop", "chinese": "隔空投送"],
        "emptyTrash": ["english": "Delete All", "chinese": "删除全部"],
        "moveSelectedToTrash": ["english": "Delete Selected", "chinese": "删除所选"],
        "restoreSelected": ["english": "Restore Selected", "chinese": "恢复所选"],
        "restoreAll": ["english": "Restore All", "chinese": "恢复全部"],
        "backToPending": ["english": "Back to Pending", "chinese": "移回待定"],
        "allBackToPending": ["english": "All Back to Pending", "chinese": "全部移回待定"],
        "selectAll": ["english": "Select All", "chinese": "全选"],
        "deselectAll": ["english": "Deselect All", "chinese": "取消全选"],
        "emptyTrashTitle": ["english": "Delete Items?", "chinese": "确认删除？"],
        "emptyTrashMessage": [
            "english": "Delete %@ item(s)? They will move to the system Trash.",
            "chinese": "删除 %@ 个项目？"
        ],
        "closeWithTrashTitle": ["english": "Trash Has Items", "chinese": "垃圾桶中还有项目"],
        "closeWithTrashMessage": [
            "english": "Delete %@ item(s) before closing?",
            "chinese": "关闭前删除 %@ 个项目？"
        ],
        "closeWithKeepMessage": [
            "english": "Move %@ item(s) to Keep before closing?",
            "chinese": "关闭前将 %@ 个项目移入保留文件夹？"
        ],
        "closeWithChangesTitle": ["english": "Pending Changes", "chinese": "有待处理更改"],
        "closeWithChangesMessage": [
            "english": "%@ item(s) will move to Keep. %@ item(s) will be deleted.",
            "chinese": "%@ 个项目将移入保留文件夹，%@ 个项目将删除。"
        ],
        "moveToTrashAndClose": ["english": "Delete and Close", "chinese": "删除并关闭"],
        "applyAndClose": ["english": "Confirm and Close", "chinese": "确认并关闭"],
        "discardChangesAndClose": ["english": "Discard Changes", "chinese": "放弃更改"],
        "restore": ["english": "Restore", "chinese": "恢复"],
        "emptyTrashBin": ["english": "Trash is empty.", "chinese": "垃圾桶是空的。"],
        "unsupportedMediaError": [
            "english": "No supported images or videos found in this folder.",
            "chinese": "这个文件夹里没有受支持的图片或视频。"
        ],
        "unableToLoadImage": ["english": "Unable to load this image", "chinese": "无法加载这张图片"],
        "renameFileTitle": ["english": "Rename File", "chinese": "重命名文件"],
        "rename": ["english": "Rename", "chinese": "重命名"],
        "fileNamePlaceholder": ["english": "File name", "chinese": "文件名"],
        "browsingCompleteMessage": ["english": "This folder has been fully browsed.", "chinese": "本文件夹已经浏览完"],
        "sortNewestFirst": ["english": "Newest to Oldest", "chinese": "时间倒序：最新到最旧"],
        "sortOldestFirst": ["english": "Oldest to Newest", "chinese": "时间正序：最旧到最新"],
        "previewTrashItem": ["english": "Preview Trash Item", "chinese": "预览垃圾桶项目"],
        "emptyRenameError": ["english": "File name cannot be empty.", "chinese": "文件名不能为空。"],
        "renameConflictError": [
            "english": "A file named %@ already exists.",
            "chinese": "已经存在名为 %@ 的文件。"
        ],
        "trashMoveFailedError": [
            "english": "%@ file(s) could not be deleted.",
            "chinese": "%@ 个文件无法删除。"
        ],
        "keepMoveFailedError": [
            "english": "%@ file(s) could not be moved to Keep.",
            "chinese": "%@ 个文件无法移入保留文件夹。"
        ],
        "noFolderSelected": ["english": "No folder selected", "chinese": "未选择文件夹"],
        "markedForTrash": ["english": "Added to Trash", "chinese": "已加入垃圾桶"],
        "noImportNoCache": ["english": "No import • No image cache", "chinese": "不导入 • 不生成图片缓存"],
        "appTitle": ["english": "KPD", "chinese": "KPD"],
        "shortcuts": ["english": "Shortcuts", "chinese": "快捷键"],
        "gettingStartedTitle": ["english": "Getting Started", "chinese": "快速上手"],
        "gettingStartedMessage": [
            "english": "Drop a Finder folder, photos, or videos to start organizing. KPD keeps your media in place.",
            "chinese": "拖入 Finder 文件夹、图片或视频即可开始整理。KPD 会让媒体保留在原位置。"
        ],
        "gotIt": ["english": "Got It", "chinese": "明白了"],
        "privacyPromise": ["english": "Lightweight by design", "chinese": "轻量设计"],
        "dragFolderTitle": ["english": "Drop a folder, photos, or videos here", "chinese": "拖拽文件夹、图片或视频到这里"],
        "dragFolderSubtitle": [
            "english": "Or",
            "chinese": "或"
        ],
        "privacyPromiseBody": [
            "english": "No library, no import, no copied originals, and no persistent image or video cache.",
            "chinese": "无图库、不导入、不复制原图、不创建持久图片或视频缓存。"
        ],
        "actionOpenFolder": ["english": "Open Folder", "chinese": "打开文件夹"],
        "actionPreviousItem": ["english": "Previous Item", "chinese": "上一个项目"],
        "actionNextItem": ["english": "Next Item", "chinese": "下一个项目"],
        "actionKeepItem": ["english": "Keep Item", "chinese": "保留项目"],
        "actionMarkForTrash": ["english": "Add to Trash", "chinese": "加入垃圾桶"],
        "actionUndo": ["english": "Undo", "chinese": "撤销"],
        "actionReviewDeletes": ["english": "Open Trash", "chinese": "查看垃圾桶"],
        "actionToggleTimeInfo": ["english": "Show/Hide Time", "chinese": "显示/隐藏时间"],
        "actionOpenNewWindow": ["english": "Open New Organizer Window", "chinese": "打开新的整理窗口"],
        "keyButton": ["english": "Button", "chinese": "按钮"],
        "keyDropFolder": ["english": "Drop Folder", "chinese": "拖入文件夹"],
        "settingsTitle": ["english": "Settings", "chinese": "设置"],
        "languageTitle": ["english": "Language", "chinese": "语言"],
        "appearanceTitle": ["english": "Appearance", "chinese": "外观"],
        "systemAppearance": ["english": "System", "chinese": "跟随系统"],
        "lightAppearance": ["english": "Light", "chinese": "浅色"],
        "darkAppearance": ["english": "Dark", "chinese": "深色"],
        "generalSettings": ["english": "General", "chinese": "通用"],
        "contentSettings": ["english": "Content", "chinese": "内容"],
        "reloadText": ["english": "Reload Text", "chinese": "重新加载文案"],
        "settingsFooter": [
            "english": "These preferences are stored locally on this Mac.",
            "chinese": "这些偏好设置只保存在这台 Mac 上。"
        ],
        "folderAlreadyOpenTitle": ["english": "Folder Already Open", "chinese": "文件夹已打开"],
        "folderAlreadyOpenMessage": [
            "english": "This folder is already open in another organizer window.",
            "chinese": "这个文件夹已经在另一个整理窗口中打开。"
        ],
        "dropToOpenNewWindow": [
            "english": "Drop to open a new organizer window",
            "chinese": "松开以打开新的整理窗口"
        ],
        "trashSummary": ["english": "%@, %@", "chinese": "%@，%@"],
        "photoUnitSingular": ["english": "photo", "chinese": "张照片"],
        "photoUnitPlural": ["english": "photos", "chinese": "张照片"],
        "videoUnitSingular": ["english": "video", "chinese": "个视频"],
        "videoUnitPlural": ["english": "videos", "chinese": "个视频"],
        "deleteConfirmationMessage": [
            "english": "Delete %@ item(s)?",
            "chinese": "删除 %@ 个项目？"
        ],
        "markedCount": ["english": "%@ in Trash", "chinese": "%@ 个在垃圾桶"]
    ]
}
