import SwiftUI

struct RootView: View {
    @StateObject private var session = TerminalSession()

    var body: some View {
        TerminalSessionView(session: session)
            .frame(minWidth: 480, minHeight: 300)
    }
}
