import SwiftUI

struct SidebarView: View {
    @ObservedObject var windowModel: TerminalWindowModel

    var body: some View {
        List(windowModel.sessions, selection: $windowModel.activeSessionID) { session in
            SidebarRowView(session: session)
                .tag(session.id)
        }
        .listStyle(.sidebar)
    }
}

private struct SidebarRowView: View {
    @ObservedObject var session: TerminalSession

    var body: some View {
        Label(session.title, systemImage: "terminal")
    }
}
