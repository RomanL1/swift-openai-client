//
//  Client+Initialization.swift
//
//
//  Created by Nicolas Märki on 26.06.2024.
//

import OpenAPIRuntime
import Foundation
import OpenAPIURLSession
import HTTPTypes
import OSLog

public extension Client {
    init(key: String, beta: Bool = true) throws {
        var middlewares: [ClientMiddleware] = [AuthMiddleware(key: key)]
        if beta{
            middlewares.append(BetaMiddleware())
        }
        self.init(serverURL: try Servers.server1(), transport: URLSessionTransport(), middlewares: middlewares)
    }
}
