import AppKit

@MainActor
final class TerminalWindowModel: NSObject, ObservableObject {
    @Published private(set) var sessions: [TerminalSession] = []
    @Published var activeSessionID: TerminalSession.ID?

    private weak var window: NSWindow?
    nonisolated(unsafe) private weak var previousWindowDelegate: NSWindowDelegate?

    override init() {
        super.init()
        addTab()
    }

    var activeSession: TerminalSession? {
        sessions.first { $0.id == activeSessionID }
    }

    func addTab() {
        let session = TerminalSession()
        let sessionID = session.id
        session.onExit = { [weak self] in self?.closeTab(id: sessionID) }
        sessions.append(session)
        activeSessionID = sessionID
    }

    func closeActiveTab() {
        guard let activeSessionID else { return }
        closeTab(id: activeSessionID)
    }

    func closeTab(id: TerminalSession.ID) {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        let session = sessions.remove(at: index)
        session.terminalView.terminate()
        guard !sessions.isEmpty else {
            window?.close()
            return
        }
        if activeSessionID == id {
            activeSessionID = sessions[min(index, sessions.count - 1)].id
        }
    }

    func attach(to window: NSWindow) {
        guard self.window !== window else { return }
        self.window = window
        previousWindowDelegate = window.delegate
        window.delegate = self
    }
}

extension TerminalWindowModel: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        closeActiveTab()
        return false
    }

    override func responds(to aSelector: Selector!) -> Bool {
        super.responds(to: aSelector) || (previousWindowDelegate?.responds(to: aSelector) ?? false)
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        super.responds(to: aSelector) ? nil : previousWindowDelegate
    }
}
