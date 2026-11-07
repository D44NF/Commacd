import SwiftUI

enum SidebarSelection {
    case shell
    case claude
    case settings
}

struct SidebarView: View {
    @ObservedObject var windowModel: TerminalWindowModel
    @Binding var selection: SidebarSelection

    var body: some View {
        VStack(spacing: 4) {
            SidebarRow(title: "Shell", systemImage: "terminal", isSelected: selection == .shell) {
                if windowModel.sessions.isEmpty {
                    windowModel.addTab()
                }
                selection = .shell
            }
            SidebarRow(title: "Claude", systemImage: "sparkles", isSelected: selection == .claude) {
                selection = .claude
            }
            Spacer()
            SidebarRow(title: "Settings", systemImage: "gearshape", isSelected: selection == .settings) {
                selection = .settings
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.bar)
    }
}

private struct SidebarRow: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
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
                .fill(isSelected ? Color.accentColor.opacity(0.18) : (isHovering ? Color.primary.opacity(0.06) : .clear))
        )
        .onHover { isHovering = $0 }
    }
}
