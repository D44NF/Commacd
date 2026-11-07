import SwiftUI

struct RootView: View {
    @StateObject private var windowModel = TerminalWindowModel()

    var body: some View {
        VStack(spacing: 0) {
            TabBarView(windowModel: windowModel)
            if let session = windowModel.activeSession {
                TerminalSessionView(session: session)
            }
        }
        .frame(minWidth: 480, minHeight: 300)
        .background(WindowAccessor { windowModel.attach(to: $0) })
        .focusedSceneValue(\.terminalWindowModel, windowModel)
    }
}
