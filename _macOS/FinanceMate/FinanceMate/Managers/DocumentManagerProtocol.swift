//
//  DocumentManagerProtocol.swift
//  FinanceMate
//
//  Created by Assistant on 6/11/25.
//

import Foundation
import SwiftUI

/// Base Manager Protocol for Document Management System
/// Defines common interface for all document-related managers
@MainActor
protocol DocumentManagerProtocol: ObservableObject {
    associatedtype DataType
    var isProcessing: Bool { get set }
    var errorMessage: String { get set }
    var hasError: Bool { get set }

    func performOperation() async throws -> DataType
    func handleError(_ error: Error)
    func reset()
}
