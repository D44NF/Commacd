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
}
