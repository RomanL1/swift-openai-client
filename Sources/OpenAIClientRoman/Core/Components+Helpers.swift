//
//  File.swift
//  
//
//  Created by Nicolas Märki on 26.06.2024.
//

import Foundation

public extension Components.Schemas.RunObject.statusPayload {

    var done: Bool {
        switch self {
            case .queued:
                return false
            case .in_progress:
                return false
            case .requires_action:
                return false
            case .cancelling:
                return false
            case .cancelled:
                return true
            case .failed:
                return true
            case .completed:
                return true
            case .incomplete:
                return true
            case .expired:
                return true
        }
    }

    var blocked: Bool {
        switch self {
            case .queued:
                return false
            case .in_progress:
                return false
            case .requires_action:
                return true
            case .cancelling:
                return false
            case .cancelled:
                return false
            case .failed:
                return false
            case .completed:
                return false
            case .incomplete:
                return false
            case .expired:
                return false
        }
    }

}
