import SwiftUI

private struct TerminalWindowModelKey: FocusedValueKey {
    typealias Value = TerminalWindowModel
}

extension FocusedValues {
    var terminalWindowModel: TerminalWindowModel? {
        get { self[TerminalWindowModelKey.self] }
        set { self[TerminalWindowModelKey.self] = newValue }
    }
}

struct TabCommands: Commands {
    @FocusedValue(\.terminalWindowModel) private var windowModel

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("New Tab") { windowModel?.addTab() }
                .keyboardShortcut("t", modifiers: .command)
                .disabled(windowModel == nil)
        }
    }
}
