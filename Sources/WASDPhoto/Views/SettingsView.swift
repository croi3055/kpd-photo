import SwiftUI

struct SettingsView: View {
    @Bindable var preferences: AppPreferences

    var body: some View {
        let strings = preferences.strings

        Form {
            Section(strings.generalSettings) {
                Picker(strings.languageTitle, selection: $preferences.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName)
                            .tag(language)
                    }
                }

                Picker(strings.appearanceTitle, selection: $preferences.appearance) {
                    ForEach(AppAppearance.allCases) { appearance in
                        Text(appearance.displayName(strings: strings))
                            .tag(appearance)
                    }
                }
            }

            Section(strings.shortcuts) {
                ShortcutSettingsRow(action: strings.actionOpenFolder, keys: ["⌘", "O"])
                ShortcutSettingsRow(action: strings.actionPreviousItem, keys: KeyboardShortcuts.shared.display(for: .previousItem))
                ShortcutSettingsRow(action: strings.actionNextItem, keys: KeyboardShortcuts.shared.display(for: .nextItem))
                ShortcutSettingsRow(action: strings.actionMarkForTrash, keys: KeyboardShortcuts.shared.display(for: .moveToTrash))
                ShortcutSettingsRow(action: strings.actionUndo, keys: KeyboardShortcuts.shared.display(for: .undo))
                ShortcutSettingsRow(action: strings.actionReviewDeletes, keys: KeyboardShortcuts.shared.display(for: .openTrashBin))
                ShortcutSettingsRow(action: strings.actionOpenNewWindow, keys: [strings.keyDropFolder])
            }

            Section(strings.contentSettings) {
                Button(strings.reloadText) {
                    preferences.reloadText()
                }
            }

            Text(strings.settingsFooter)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 440)
        .navigationTitle(strings.settingsTitle)
    }
}

private struct ShortcutSettingsRow: View {
    let action: String
    let keys: [String]

    var body: some View {
        HStack {
            Text(action)
            Spacer()
            HStack(spacing: 4) {
                ForEach(keys, id: \.self) { key in
                    KeyCap(text: key)
                }
            }
        }
    }
}

private struct KeyCap: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(.callout, design: .rounded).weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.separator.opacity(0.35), lineWidth: 1)
            }
    }
}
