import SwiftUI
import WASDPhotoCore

@Observable
final class AppPreferences {
    var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Keys.language)
        }
    }

    var appearance: AppAppearance {
        didSet {
            UserDefaults.standard.set(appearance.rawValue, forKey: Keys.appearance)
        }
    }

    var hasSeenOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding)
        }
    }

    var mediaSortOrder: MediaSortOrder {
        didSet {
            UserDefaults.standard.set(mediaSortOrder.rawValue, forKey: Keys.mediaSortOrder)
        }
    }

    var textReloadToken = 0

    init() {
        let languageValue = UserDefaults.standard.string(forKey: Keys.language)
        self.language = AppLanguage(rawValue: languageValue ?? "") ?? .english

        let appearanceValue = UserDefaults.standard.string(forKey: Keys.appearance)
        self.appearance = AppAppearance(rawValue: appearanceValue ?? "") ?? .system

        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: Keys.hasSeenOnboarding)

        let mediaSortOrderValue = UserDefaults.standard.string(forKey: Keys.mediaSortOrder)
        self.mediaSortOrder = MediaSortOrder(rawValue: mediaSortOrderValue ?? "") ?? .newestFirst
    }

    var colorScheme: ColorScheme? {
        appearance.colorScheme
    }

    var strings: AppStrings {
        AppStrings(language: language, reloadToken: textReloadToken)
    }

    func reloadText() {
        textReloadToken += 1
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english
    case chinese

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .chinese:
            return "中文"
        }
    }
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String {
        rawValue
    }

    func displayName(strings: AppStrings) -> String {
        switch self {
        case .system:
            return strings.systemAppearance
        case .light:
            return strings.lightAppearance
        case .dark:
            return strings.darkAppearance
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

private enum Keys {
    static let language = "app.language"
    static let appearance = "app.appearance"
    static let hasSeenOnboarding = "app.hasSeenOnboarding"
    static let mediaSortOrder = "app.mediaSortOrder"
}

extension MediaSortOrder {
    var toggled: MediaSortOrder {
        switch self {
        case .newestFirst:
            return .oldestFirst
        case .oldestFirst:
            return .newestFirst
        }
    }

    func displayName(strings: AppStrings) -> String {
        switch self {
        case .newestFirst:
            return strings.sortNewestFirst
        case .oldestFirst:
            return strings.sortOldestFirst
        }
    }
}
