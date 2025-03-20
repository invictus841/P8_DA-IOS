//
//  AppError.swift
//  Arista
//
//  Created by Alexandre Talatinian on 03/03/2025.
//

import Foundation

enum AppError: Error, Equatable {
    case invalidInput(String)
    case coreDataError(Error)
    case unknown(String)
    case noUserFound
    case exerciseNotFound

    var localizedDescription: String {
        switch self {
        case .invalidInput(let field):
            return "Invalid input for \(field)."
        case .coreDataError(let error):
            return "Core Data Error: \(error.localizedDescription)"
        case .unknown(let message):
            return "An unknown error occurred: \(message)"
        case .noUserFound:
            return "No User Found"
        case .exerciseNotFound:
            return "Exercise not found"
        }
   
    }

    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidInput(let a), .invalidInput(let b)):
            return a == b
        case (.coreDataError(let a), .coreDataError(let b)):
            return a.localizedDescription == b.localizedDescription
        case (.unknown(let a), .unknown(let b)):
            return a == b
        case (.noUserFound, .noUserFound):
            return true
        case (.exerciseNotFound, .exerciseNotFound):
            return true
        default:
            return false
        }
    }
}
