import XCTest
@testable import Commacd

final class ClaudeChatSessionTests: XCTestCase {
    @MainActor
    func testStreamingTextDeltaAccumulatesIntoAssistantMessage() {
        let session = ClaudeChatSession()
        session.handle(line: #"{"type":"stream_event","event":{"type":"content_block_delta","delta":{"type":"text_delta","text":"Hel"}}}"#)
        session.handle(line: #"{"type":"stream_event","event":{"type":"content_block_delta","delta":{"type":"text_delta","text":"lo"}}}"#)

        XCTAssertEqual(session.messages.count, 1)
        guard case .text(_, let text) = session.messages[0].blocks.first else {
            return XCTFail("expected a text block")
        }
        XCTAssertEqual(text, "Hello")
        XCTAssertEqual(session.messages[0].role, .assistant)
    }

    @MainActor
    func testFinalAssistantMessageReplacesStreamedPlaceholder() {
        let session = ClaudeChatSession()
        session.handle(line: #"{"type":"stream_event","event":{"type":"content_block_delta","delta":{"type":"text_delta","text":"Hel"}}}"#)
        session.handle(line: #"{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Hello there"}]}}"#)

        XCTAssertEqual(session.messages.count, 1)
        guard case .text(_, let text) = session.messages[0].blocks.first else {
            return XCTFail("expected a text block")
        }
        XCTAssertEqual(text, "Hello there")
    }

    @MainActor
    func testResultEventEndsStreaming() {
        let session = ClaudeChatSession()
        session.handle(line: #"{"type":"result","subtype":"success"}"#)
        XCTAssertFalse(session.isStreaming)
    }

    @MainActor
    func testToolUseGetsMatchedWithItsToolResult() {
        let session = ClaudeChatSession()
        session.handle(line: #"{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"toolu_1","name":"Bash","input":{"command":"ls"}}]}}"#)
        session.handle(line: #"{"type":"user","message":{"role":"user","content":[{"tool_use_id":"toolu_1","type":"tool_result","content":"file1\nfile2","is_error":false}]}}"#)

        XCTAssertEqual(session.messages.count, 1)
        guard case .toolUse(let block) = session.messages[0].blocks.first else {
            return XCTFail("expected a tool use block")
        }
        XCTAssertEqual(block.name, "Bash")
        XCTAssertEqual(block.result?.isError, false)
        XCTAssertEqual(block.result?.summaryText, "file1\nfile2")
    }

    @MainActor
    func testDeniedToolUseIsMarkedAsError() {
        let session = ClaudeChatSession()
        session.handle(line: #"{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"toolu_2","name":"Write","input":{"file_path":"/tmp/x.txt"}}]}}"#)
        session.handle(line: #"{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"Claude requested permissions to write to /tmp/x.txt, but you haven't granted it yet.","is_error":true,"tool_use_id":"toolu_2"}]}}"#)

        guard case .toolUse(let block) = session.messages[0].blocks.first else {
            return XCTFail("expected a tool use block")
        }
        XCTAssertEqual(block.result?.isError, true)
    }
}
