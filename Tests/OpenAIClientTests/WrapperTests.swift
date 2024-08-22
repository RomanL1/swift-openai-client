//
//  WrapperTests.swift
//  
//
//  Created by Nicolas Märki on 30.06.2024.
//

import XCTest
@testable import OpenAIClient

final class WrapperTests: XCTestCase {

    var client: Client!
    let api_key = ProcessInfo.processInfo.environment["OPENAI_KEY"]!
    let assistant_id = ProcessInfo.processInfo.environment["ASSISTANT_ID"]!

    override func setUpWithError() throws {
        client = try Client(key: api_key)
    }

    func testAssistant() async throws {
        let assistant = Assistant(assistant_id, using: client)
        let thread = try await assistant.createThread()
        try await thread.addMessage("Hello Assistant")
        let messages = try await thread.run()
        for message in messages {
            let text = try message.text
            print("Message: \(text)")
        }
    }

    func testDecoding() async throws {
        let assistant = Assistant(assistant_id, using: client)
        let thread = try await assistant.createThread()
        try await thread.addMessage("Reply in the json format {'greeting': 'A nice greeting'")
        let messages = try await thread.run()
        for message in messages {
            struct Greeting: Codable {
                let greeting: String
            }
            let object = try message.decoded(as: Greeting.self)
            print("Message: \(object.greeting)")
        }
    }

    func testChat() async throws {
        let chat = Chat(using: client)
        let response = try await chat.completion("Wer bist du?").text
        print("\(response)")
    }

    func testImageUpload() async throws {
        let image = UIImage(systemName: "figure.sailing")!
        let file = try await File.upload(image.pngData()!, purpose: .assistants, using: client)
        print("File created: \(file.id)")
    }



}
