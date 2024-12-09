//
//  File 2.swift
//  
//
//  Created by Nicolas Märki on 27.06.2024.
//

import Foundation

struct OpenAIError: Error, LocalizedError {
    let errorDescription: String
    init(errorDescription: String) {
        self.errorDescription = errorDescription
    }

}
