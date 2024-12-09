//
//  File.swift
//  
//
//  Created by Nicolas Märki on 27.06.2024.
//

import Foundation

public struct Message {
    public enum MessageType {
        case messageObject(Components.Schemas.MessageObject)
        case chatCompletionMessage(Components.Schemas.ChatCompletionResponseMessage)
    }
    public let raw: MessageType
    init(raw: Components.Schemas.MessageObject) {
        self.raw = .messageObject(raw)
    }
    init(raw: Components.Schemas.ChatCompletionResponseMessage) {
        self.raw = .chatCompletionMessage(raw)
    }

    public var text: String  {
        get throws {
            switch raw {
                case .messageObject(let object):
                    if object.content.count != 1 {
                        throw OpenAIError(errorDescription: "Not a single object as content")
                    }
                    switch object.content.first {
                        case .some(.MessageContentTextObject(let object)):
                            return object.text.value
                        default: throw OpenAIError(errorDescription: "No text object at index 0")
                    }
                case .chatCompletionMessage(let message):
                    if let text = message.content {
                        return text
                    }
                    else {
                        throw OpenAIError(errorDescription: "No content")
                    }
            }
        }
    }

    public func decoded<T: Decodable>(as type: T.Type = T.self) throws ->  T {
        return try JSONDecoder().decode(T.self, from: self.text.data(using: .utf8)!)
    }
}

