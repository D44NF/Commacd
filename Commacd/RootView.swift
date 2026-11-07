import SwiftUI

struct RootView: View {
    @StateObject private var windowModel = TerminalWindowModel()
    @State private var sidebarSelection: SidebarSelection = .shell
    @State private var claudeSession: TerminalSession?

    var body: some View {
        NavigationSplitView {
            SidebarView(windowModel: windowModel, selection: $sidebarSelection)
        } detail: {
            ZStack {
                VStack(spacing: 0) {
                    TabBarView(windowModel: windowModel)
                    if let session = windowModel.activeSession {
                        TerminalSessionView(session: session)
                            .id(session.id)
                    }
                }
                .opacity(sidebarSelection == .shell ? 1 : 0)
                .allowsHitTesting(sidebarSelection == .shell)

                if let claudeSession {
                    TerminalSessionView(session: claudeSession)
                        .opacity(sidebarSelection == .claude ? 1 : 0)
                        .allowsHitTesting(sidebarSelection == .claude)
                }

                if sidebarSelection == .settings {
                    Color(nsColor: .windowBackgroundColor)
                }
            }
        }
        .frame(minWidth: 480, minHeight: 300)
        .background(WindowAccessor { windowModel.attach(to: $0) })
        .focusedSceneValue(\.terminalWindowModel, windowModel)
        .onChange(of: sidebarSelection) { newValue in
            if newValue == .claude, claudeSession == nil {
                claudeSession = TerminalSession(initialCommand: "claude")
            }
        }
    }
}
