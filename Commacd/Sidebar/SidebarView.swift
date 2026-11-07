import SwiftUI

struct SidebarView: View {
    @ObservedObject var windowModel: TerminalWindowModel

    var body: some View {
        VStack(spacing: 4) {
            SidebarRow(title: "Shell", systemImage: "terminal") {
                windowModel.addTab()
            }
            SidebarRow(title: "Claude", systemImage: "sparkles") {}
            Spacer()
            SidebarRow(title: "Settings", systemImage: "gearshape") {}
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.bar)
    }
}

private struct SidebarRow: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isHovering ? Color.primary.opacity(0.06) : .clear)
        )
        .onHover { isHovering = $0 }
    }
}
