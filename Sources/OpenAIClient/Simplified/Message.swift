//
//  File.swift
//  
//
//  Created by Nicolas Märki on 27.06.2024.
//

import Foundation

public struct Message {
    public let raw: Components.Schemas.MessageObject
    init(raw: Components.Schemas.MessageObject) {
        self.raw = raw
    }

    public var text: String  {
        get throws {
            if raw.content.count != 1 {
                throw OpenAIError(errorDescription: "Not a single object as content")
            }
            switch raw.content.first {
                case .some(.MessageContentTextObject(let object)):
                    return object.text.value
                default: throw OpenAIError(errorDescription: "No text object at index 0")
            }
        }
    }

    public func decoded<T: Decodable>(as type: T.Type = T.self) throws ->  T {
        if raw.content.count != 1 {
            throw OpenAIError(errorDescription: "Not a single object as content")
        }
        switch raw.content.first {
            case .some(.MessageContentTextObject(let object)):
                return try JSONDecoder().decode(T.self, from: object.text.value.data(using: .utf8)!)
            default: throw OpenAIError(errorDescription: "No text object at index 0")
        }
    }
}

