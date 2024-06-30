//
//  File.swift
//  
//
//  Created by Nicolas Märki on 27.06.2024.
//

import Foundation

public protocol ContentPayload {
    var createMessageContentPayload: Components.Schemas.CreateMessageRequest.contentPayload.Case2PayloadPayload { get }
}

public protocol ChatContentPayload {
    var chatCompletionContentPayload: Components.Schemas.ChatCompletionRequestMessageContentPart { get }
}

extension String: ContentPayload, ChatContentPayload {
    public var createMessageContentPayload: Components.Schemas.CreateMessageRequest.contentPayload.Case2PayloadPayload {
        .MessageRequestContentTextObject(.init(_type: .text, text: self))
    }
    public var chatCompletionContentPayload: Components.Schemas.ChatCompletionRequestMessageContentPart {
        .ChatCompletionRequestMessageContentPartText(.init(_type: .text, text: self))
    }
}

