//
//  File.swift
//  
//
//  Created by Nicolas Märki on 27.06.2024.
//

import Foundation
import OpenAPIRuntime

public struct File {

    public enum Purpose: String, Codable  {
        case assistants
        case batch
        case fineTune = "fine-tune"
        case vision
    }

    let id: String
    let purpose: Purpose
    let raw: Components.Schemas.OpenAIFile

    init(id: String, purpose: Purpose, raw: Components.Schemas.OpenAIFile) {
        self.id = id
        self.purpose = purpose
        self.raw = raw
    }

    public static func upload(_ data: Data, purpose: Purpose, using client: Client) async throws -> File {
        let body = HTTPBody(data)
        let purposeBody = HTTPBody(purpose.rawValue)


        let file = try await client.createFile(body: .multipartForm([
            .file(.init(payload: .init(body: body))),
            .purpose(.init(payload: .init(body: purposeBody)))
        ])).ok.body.json

        return File(id: file.id, purpose: purpose, raw: file)
    }
}

 extension File: ContentPayload {
    public var payload: Components.Schemas.CreateMessageRequest.contentPayload.Case2PayloadPayload {
        .MessageContentImageFileObject(.init(_type: .image_file, image_file: .init(file_id: id)))
    }

}

extension URL: ContentPayload {
    public var payload: Components.Schemas.CreateMessageRequest.contentPayload.Case2PayloadPayload {
        .MessageContentImageUrlObject(.init(_type: .image_url, image_url: .init(url: self.absoluteString)))
    }
    

}
