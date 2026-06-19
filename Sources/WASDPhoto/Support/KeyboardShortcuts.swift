import AppKit
import Foundation

enum KeyEvent: String {
    case previousItem
    case nextItem
    case moveToTrash
    case openTrashBin
    case undo
}

struct KeyboardShortcutDisplay {
    let event: KeyEvent
    let keys: [String]
}

final class KeyboardShortcuts {
    static let shared = KeyboardShortcuts()

    private let bindings: [KeyEvent: ShortcutBinding]
    private let keyMap: [String: KeyEvent]

    private init() {
        let loadedBindings = Self.loadBindings()
        self.bindings = loadedBindings

        var loadedKeyMap: [String: KeyEvent] = [:]
        for (event, binding) in loadedBindings {
            for key in binding.keys {
                loadedKeyMap[key] = event
            }
        }
        self.keyMap = loadedKeyMap
    }

    func event(for nsEvent: NSEvent) -> KeyEvent? {
        let key = ShortcutKey(nsEvent: nsEvent)
        return keyMap[key.identifier]
    }

    func display(for event: KeyEvent) -> [String] {
        bindings[event]?.display ?? Self.fallbackBindings[event]?.display ?? []
    }

    private static func loadBindings() -> [KeyEvent: ShortcutBinding] {
        guard
            let url = Bundle.module.url(forResource: "KeyboardShortcuts", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([String: ShortcutBinding].self, from: data)
        else {
            return fallbackBindings
        }

        var result = fallbackBindings
        for (rawEvent, binding) in decoded {
            guard let event = KeyEvent(rawValue: rawEvent), !binding.keys.isEmpty else {
                continue
            }
            result[event] = binding
        }
        return result
    }

    private static let fallbackBindings: [KeyEvent: ShortcutBinding] = [
        .previousItem: ShortcutBinding(keys: ["leftArrow"], display: ["←"]),
        .nextItem: ShortcutBinding(keys: ["rightArrow"], display: ["→"]),
        .moveToTrash: ShortcutBinding(keys: ["upArrow", "w"], display: ["↑", "W"]),
        .openTrashBin: ShortcutBinding(keys: ["delete"], display: ["Delete"]),
        .undo: ShortcutBinding(keys: ["z"], display: ["Z"])
    ]
}

private struct ShortcutBinding: Decodable {
    let keys: [String]
    let display: [String]
}

private struct ShortcutKey {
    let identifier: String

    init(nsEvent: NSEvent) {
        switch nsEvent.keyCode {
        case 123:
            identifier = "leftArrow"
        case 124:
            identifier = "rightArrow"
        case 125:
            identifier = "downArrow"
        case 126:
            identifier = "upArrow"
        case 51, 117:
            identifier = "delete"
        case 49:
            identifier = "space"
        default:
            identifier = nsEvent.charactersIgnoringModifiers?.lowercased() ?? ""
        }
    }
}
