//
//  File.swift
//  
//
//  Created by Nicolas Märki on 27.06.2024.
//

import Foundation

public struct Assistant {

    let id: String
    let client: Client

    public init(_ id: String, using client: Client) {
        self.id = id
        self.client = client
    }

    public func createThread() async throws -> Assistant.Thread {
        let raw = try await client.createThread().ok.body.json
        return Assistant.Thread(raw.id, using: client, assistant: self)
    }

    public struct Thread {
        let id: String
        let client: Client
        let assistant: Assistant

        init(_ id: String, using client: Client, assistant: Assistant) {
            self.id = id
            self.client = client
            self.assistant = assistant
        }

        @discardableResult
        public func addMessage(_ content: ContentPayload...) async throws -> Message {
            let payload = content.map { $0.payload }
            let raw = try await client.createMessage(path: .init(thread_id: id), body: .json(.init(role: .user, content: .case2(payload)))).ok.body.json
            return Message(raw: raw)
        }

        public func run() async throws -> [Message] {
            let run = try await client.createRun(path: .init(thread_id: id), body: .json(.init(assistant_id: assistant.id, stream: true))).ok.body.text_event_hyphen_stream

            var messages: [Message] = []

            for try await event in run.asDecodedServerSentEvents() {
                if event.data == "[DONE]" { break }
                if let data = event.data?.data(using: .utf8) {
                    let eventData = try JSONDecoder().decode(Components.Schemas.RunStreamEvent.self, from: data)
                    switch eventData {
                        case .MessageObject(let message):
                            break;
                            messages.append(.init(raw: message))
                        default: break
                    }

                }
            }

            return messages
        }
    }




}




