import SwiftUI

struct TabBarView: View {
    @ObservedObject var windowModel: TerminalWindowModel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(windowModel.sessions) { session in
                TabBarItemView(
                    session: session,
                    isActive: session.id == windowModel.activeSessionID,
                    onSelect: { windowModel.activeSessionID = session.id },
                    onClose: { windowModel.closeTab(id: session.id) }
                )
            }
        }
    }
}

private struct TabBarItemView: View {
    @ObservedObject var session: TerminalSession
    let isActive: Bool
    let onSelect: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack {
            Text(session.title)
            Button(action: onClose) {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isActive ? Color.accentColor.opacity(0.2) : .clear)
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }
}
