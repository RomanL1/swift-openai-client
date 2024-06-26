import XCTest
@testable import OpenAISwift
import OpenAPIRuntime
import OSLog


final class AssistantsTests: XCTestCase {

    var client: Client!
    let Log = Logger(subsystem: "Tests", category: "Assistants")
    let api_key = ProcessInfo.processInfo.environment["OPENAI_KEY"]!
    let assistant_id = ProcessInfo.processInfo.environment["ASSISTANT_ID"]!

    override func setUp() {
        client = try! Client(key: api_key)
    }

    func testThreadRun() async throws {
        let thread = try await client.createThread().ok.body.json

        _ = try await client.createMessage(path: .init(thread_id: thread.id), body: .json(.init(role: .user, content: .case1("Hello Assistant"))))

        var run = try await client.createRun(path: .init(thread_id: thread.id), body: .json(.init(assistant_id: assistant_id, stream: false))).ok.body.json

        while !run.status.done {
            XCTAssertFalse(run.status.blocked)
            run = try await client.getRun(path: .init(thread_id: thread.id, run_id: run.id)).ok.body.json
        }

        let messages = try await client.listMessages(path: .init(thread_id: thread.id), query: .init(run_id: run.id)).ok.body.json

        for message in messages.data {
            for content in message.content {
                switch content {
                    case .MessageContentImageFileObject(let imageFile):
                        Log.info("Image File: \(imageFile.image_file.file_id)")
                    case .MessageContentImageUrlObject(let imageUrl):
                        Log.info("Image URL: \(imageUrl.image_url.url)")
                    case .MessageContentTextObject(let text):
                        Log.info(("Text: \(text.text.value)"))
                }
            }
        }

    }

    func testRunStream() async throws {
        let thread = try await client.createThread().ok.body.json

        _ = try await client.createMessage(path: .init(thread_id: thread.id), body: .json(.init(role: .user, content: .case1("Hello Assistant"))))

        let run = try await client.createRun(path: .init(thread_id: thread.id), body: .json(.init(assistant_id: assistant_id, stream: true))).ok.body.text_event_hyphen_stream

        for try await event in run.asDecodedServerSentEvents() {
            if event.data == "[DONE]" { break }
            if let data = event.data?.data(using: .utf8) {
                let eventData = try JSONDecoder().decode(Components.Schemas.RunStreamEvent.self, from: data)
                switch eventData {
                    case .RunObject(_):
                        Log.debug("Received RunObject")
                    case .RunStepObject(_):
                        Log.debug("Received RunStepObject")
                    case .RunStepDeltaObject(_):
                        Log.debug("Received RunStepDeltaObject")
                    case .MessageObject(_):
                        Log.debug("Received MessageObject")
                    case .MessageDeltaObject(_):
                        Log.debug("Received MessageDeltaObject")
                    case .case6(_):
                        Log.debug("Received Case6")
                }

            }
        }
    }
}
