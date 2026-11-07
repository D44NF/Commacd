import SwiftUI

struct ToolUseCardView: View {
    let block: ToolUseBlock

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: statusIcon)
                .foregroundStyle(statusColor)
            VStack(alignment: .leading, spacing: 4) {
                Text(ToolSummaryFormatter.summary(name: block.name, input: block.input))
                    .font(.system(.body, design: .monospaced))
                if let result = block.result, !result.summaryText.isEmpty {
                    Text(result.summaryText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(4)
                }
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
    }

    private var statusIcon: String {
        guard let result = block.result else { return "circle.dotted" }
        return result.isError ? "xmark.circle.fill" : "checkmark.circle.fill"
    }

    private var statusColor: Color {
        guard let result = block.result else { return .secondary }
        return result.isError ? .red : .green
    }
}
