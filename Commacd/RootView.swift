import SwiftUI

struct RootView: View {
    @StateObject private var windowModel = TerminalWindowModel()
    @State private var sidebarSelection: SidebarSelection = .shell

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

                if sidebarSelection != .shell {
                    Color(nsColor: .windowBackgroundColor)
                }
            }
        }
        .frame(minWidth: 480, minHeight: 300)
        .background(WindowAccessor { windowModel.attach(to: $0) })
        .focusedSceneValue(\.terminalWindowModel, windowModel)
    }
}
