//
//  File.swift
//
//
//  Created by Nicolas Märki on 27.06.2024.
//

import Foundation
import OpenAPIRuntime

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
            let payload = content.map { $0.createMessageContentPayload }
            let raw = try await client.createMessage(path: .init(thread_id: id), body: .json(.init(role: .user, content: .case2(payload)))).ok.body.json
            return Message(raw: raw)
        }

        public struct CallArgument {
            let input: String
            public func decoded<T: Decodable>(as: T.Type = T.self) throws -> T {
                return try JSONDecoder().decode(T.self, from: input.data(using: .utf8)!)
            }
        }

        public func run(functions: [String: ((CallArgument) throws -> Encodable)] = [:]) async throws -> [Message] {
            var runStream: OpenAPIRuntime.HTTPBody? = try await client.createRun(path: .init(thread_id: id), body: .json(.init(assistant_id: assistant.id, stream: true))).ok.body.text_event_hyphen_stream

            var messages: [Components.Schemas.MessageObject] = []
            var calls: [String] = []

            while let lastStream = runStream {
                runStream = nil
                for try await event in lastStream.asDecodedServerSentEvents() {
                    if event.data == "[DONE]" { break }
                    if let data = event.data?.data(using: .utf8) {
                        let eventData = try JSONDecoder().decode(Components.Schemas.RunStreamEvent.self, from: data)
                        switch eventData {
                            case .MessageObject(let message):
                                messages.removeAll { $0.id == message.id }
                                messages.append(message)
                                break;
                            case .RunObject(let run):
                                if let requiredAction = run.required_action {
                                    var outputs: [Components.Schemas.SubmitToolOutputsRunRequest.tool_outputsPayloadPayload] = []
                                    for call in requiredAction.submit_tool_outputs.tool_calls {
                                        if calls.contains(call.id) {
                                            continue
                                        }
                                        calls.append(call.id)
                                        if let f = functions[call.function.name] {
                                            let response = try f(CallArgument(input: call.function.arguments))
                                            let encoded = String(data: try JSONEncoder().encode(response), encoding: .utf8)!
                                            outputs.append(.init(tool_call_id: call.id, output: encoded))
                                        }
                                        else {
                                            throw OpenAIError(errorDescription: "Tool \(call.function.name) not a known function")
                                        }
                                    }
                                    runStream = try await client.submitToolOutputsToRun(path: .init(thread_id: id, run_id: run.id), body: .json(.init(tool_outputs: outputs, stream: true))).ok.body.text_event_hyphen_stream
                                }
                            default: break
                        }
                    }

                }
            }

            return messages.map { .init(raw: $0) }
        }
    }






}





