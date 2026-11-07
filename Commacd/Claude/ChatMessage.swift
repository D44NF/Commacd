import Foundation

struct ChatMessage: Identifiable {
    enum Role: Equatable {
        case user
        case assistant
    }

    let id: String
    let role: Role
    var blocks: [ContentBlock]
}

enum ContentBlock: Identifiable {
    case text(id: String, text: String)
    case toolUse(ToolUseBlock)

    var id: String {
        switch self {
        case .text(let id, _):
            return id
        case .toolUse(let block):
            return block.id
        }
    }
}

struct ToolUseBlock: Identifiable {
    let id: String
    let name: String
    let input: [String: Any]
    var result: ToolResultBlock?
}

struct ToolResultBlock {
    var isError: Bool
    var summaryText: String
}
