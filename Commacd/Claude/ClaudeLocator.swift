import Foundation

enum ClaudeLocator {
    static func binaryPath() -> String {
        for candidate in ["/opt/homebrew/bin/claude", "/usr/local/bin/claude"] {
            if FileManager.default.isExecutableFile(atPath: candidate) {
                return candidate
            }
        }
        return "claude"
    }
}
