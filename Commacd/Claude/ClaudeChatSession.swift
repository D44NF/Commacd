import Foundation

@MainActor
final class ClaudeChatSession: ObservableObject, Identifiable {
    let id = UUID()
    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var isStreaming = false

    private var process: Process?
    private var stdinHandle: FileHandle?
    private var readTask: Task<Void, Never>?
    private var currentAssistantMessageID: String?

    deinit {
        process?.terminate()
    }

    func start(workingDirectory: URL = FileManager.default.homeDirectoryForCurrentUser) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [
            ClaudeLocator.binaryPath(),
            "-p",
            "--input-format", "stream-json",
            "--output-format", "stream-json",
            "--include-partial-messages",
            "--verbose"
        ]
        process.currentDirectoryURL = workingDirectory

        let stdin = Pipe()
        let stdout = Pipe()
        process.standardInput = stdin
        process.standardOutput = stdout
        process.standardError = stdout

        guard (try? process.run()) != nil else { return }

        self.process = process
        self.stdinHandle = stdin.fileHandleForWriting

        let readHandle = stdout.fileHandleForReading
        readTask = Task { [weak self] in
            do {
                for try await line in readHandle.bytes.lines {
                    self?.handle(line: line)
                }
            } catch {
                // Stream ended or the process exited; nothing to do.
            }
        }
    }

    func send(_ text: String) {
        messages.append(ChatMessage(id: UUID().uuidString, role: .user, blocks: [.text(id: UUID().uuidString, text: text)]))
        currentAssistantMessageID = nil
        let payload: [String: Any] = [
            "type": "user",
            "message": ["role": "user", "content": text]
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: payload) else { return }
        stdinHandle?.write(data)
        stdinHandle?.write(Data("\n".utf8))
        isStreaming = true
    }

    func handle(line: String) {
        guard !line.isEmpty,
              let data = line.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else { return }

        switch type {
        case "stream_event":
            handleStreamEvent(json)
        case "assistant":
            reconcileAssistantMessage(json)
        case "user":
            handleToolResultMessage(json)
        case "result":
            isStreaming = false
        default:
            break
        }
    }

    private func handleStreamEvent(_ json: [String: Any]) {
        guard let event = json["event"] as? [String: Any],
              let delta = event["delta"] as? [String: Any],
              delta["type"] as? String == "text_delta",
              let text = delta["text"] as? String else { return }
        appendAssistantText(text)
    }

    private func appendAssistantText(_ text: String) {
        if let id = currentAssistantMessageID,
           let index = messages.firstIndex(where: { $0.id == id }),
           let lastBlock = messages[index].blocks.last,
           case .text(let blockID, let existing) = lastBlock {
            messages[index].blocks[messages[index].blocks.count - 1] = .text(id: blockID, text: existing + text)
        } else {
            let messageID = UUID().uuidString
            currentAssistantMessageID = messageID
            messages.append(ChatMessage(id: messageID, role: .assistant, blocks: [.text(id: UUID().uuidString, text: text)]))
        }
    }

    private func reconcileAssistantMessage(_ json: [String: Any]) {
        guard let message = json["message"] as? [String: Any],
              let content = message["content"] as? [[String: Any]] else { return }
        let blocks: [ContentBlock] = content.compactMap { block in
            switch block["type"] as? String {
            case "text":
                guard let text = block["text"] as? String else { return nil }
                return .text(id: UUID().uuidString, text: text)
            case "tool_use":
                guard let id = block["id"] as? String,
                      let name = block["name"] as? String else { return nil }
                let input = block["input"] as? [String: Any] ?? [:]
                return .toolUse(ToolUseBlock(id: id, name: name, input: input))
            default:
                return nil
            }
        }
        guard !blocks.isEmpty else { return }
        if let id = currentAssistantMessageID,
           let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index].blocks = blocks
        } else {
            messages.append(ChatMessage(id: UUID().uuidString, role: .assistant, blocks: blocks))
        }
        currentAssistantMessageID = nil
    }

    private func handleToolResultMessage(_ json: [String: Any]) {
        guard let message = json["message"] as? [String: Any],
              let content = message["content"] as? [[String: Any]] else { return }
        for block in content {
            guard block["type"] as? String == "tool_result",
                  let toolUseID = block["tool_use_id"] as? String else { continue }
            let isError = block["is_error"] as? Bool ?? false
            let summary = Self.summarizeToolResultContent(block["content"])
            attachResult(toolUseID: toolUseID, result: ToolResultBlock(isError: isError, summaryText: summary))
        }
    }

    private static func summarizeToolResultContent(_ content: Any?) -> String {
        if let text = content as? String { return text }
        if let blocks = content as? [[String: Any]] {
            return blocks.compactMap { $0["text"] as? String }.joined(separator: "\n")
        }
        return ""
    }

    private func attachResult(toolUseID: String, result: ToolResultBlock) {
        for messageIndex in messages.indices {
            for blockIndex in messages[messageIndex].blocks.indices {
                guard case .toolUse(var toolUseBlock) = messages[messageIndex].blocks[blockIndex],
                      toolUseBlock.id == toolUseID else { continue }
                toolUseBlock.result = result
                messages[messageIndex].blocks[blockIndex] = .toolUse(toolUseBlock)
                return
            }
        }
    }
}
