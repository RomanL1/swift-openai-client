//
//  File.swift
//  
//
//  Created by Nicolas Märki on 27.06.2024.
//

import Foundation

public protocol ContentPayload {
    var payload: Components.Schemas.CreateMessageRequest.contentPayload.Case2PayloadPayload { get }
}

extension String: ContentPayload {
    public var payload: Components.Schemas.CreateMessageRequest.contentPayload.Case2PayloadPayload {
        .MessageRequestContentTextObject(.init(_type: .text, text: self))
    }
}

