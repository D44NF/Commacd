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

    var id: String {
        switch self {
        case .text(let id, _):
            return id
        }
    }
}
