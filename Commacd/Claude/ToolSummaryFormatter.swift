import Foundation

enum ToolSummaryFormatter {
    static func summary(name: String, input: [String: Any]) -> String {
        switch name {
        case "Bash":
            guard let command = input["command"] as? String else { return name }
            return "bash: \(command)"
        case "Write", "Edit", "Read", "NotebookEdit":
            guard let path = input["file_path"] as? String else { return name }
            return "\(name): \(path)"
        default:
            return name
        }
    }
}
