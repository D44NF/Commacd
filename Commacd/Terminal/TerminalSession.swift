import Combine
import Foundation
import SwiftTerm

@MainActor
final class TerminalSession: ObservableObject, LocalProcessTerminalViewDelegate, Identifiable {
    let id = UUID()
    let terminalView = LocalProcessTerminalView(frame: .zero)
    @Published private(set) var title = "Shell"
    var onExit: (() -> Void)?

    init(initialCommand: String? = nil) {
        terminalView.processDelegate = self
        let shellPath = ShellLocator.loginShellPath()
        let shellName = (shellPath as NSString).lastPathComponent
        terminalView.startProcess(executable: shellPath, execName: "-" + shellName)
        if let initialCommand {
            terminalView.process.send(data: ArraySlice(Array((initialCommand + "\n").utf8)))
        }
    }

    func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

    func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
        self.title = title
    }

    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}

    func processTerminated(source: TerminalView, exitCode: Int32?) {
        onExit?()
    }
}
