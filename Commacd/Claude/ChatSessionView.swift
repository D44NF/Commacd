import SwiftUI

struct ChatSessionView: View {
    @ObservedObject var session: ClaudeChatSession
    @State private var draft = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(session.messages) { message in
                        ChatMessageView(message: message)
                    }
                }
                .padding(12)
            }
            Divider()
            HStack {
                TextField("Message Claude…", text: $draft)
                    .onSubmit(sendDraft)
                Button("Send", action: sendDraft)
                    .disabled(draft.isEmpty || session.isStreaming)
            }
            .padding(8)
        }
    }

    private func sendDraft() {
        guard !draft.isEmpty else { return }
        session.send(draft)
        draft = ""
    }
}

private struct ChatMessageView: View {
    let message: ChatMessage

    var body: some View {
        VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 6) {
            ForEach(message.blocks) { block in
                switch block {
                case .text(_, let text):
                    Text(text)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(message.role == .user ? Color.accentColor.opacity(0.18) : Color.primary.opacity(0.05))
                        )
                case .toolUse(let toolBlock):
                    ToolUseCardView(block: toolBlock)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
    }
}
