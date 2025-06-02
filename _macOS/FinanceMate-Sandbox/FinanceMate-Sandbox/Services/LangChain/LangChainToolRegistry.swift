//
//  LangChainToolRegistry.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

// SANDBOX FILE: For testing/development. See .cursorrules.

import Foundation
import Combine

// MARK: - LangChain Tool Registry

public class LangChainToolRegistry: ObservableObject {
    
    // MARK: - Private Properties
    
    private var tools: [String: LangChainTool] = [:]
    
    // MARK: - Public Methods
    
    public func initialize() async throws {
        print("LangChain Tool Registry initialized")
    }
    
    public func registerTool(_ tool: LangChainTool) async throws {
        tools[tool.name] = tool
    }
    
    public func getTool(name: String) -> LangChainTool? {
        return tools[name]
    }
    
    public func getAllTools() -> [LangChainTool] {
        return Array(tools.values)
    }
}

// MARK: - LangChain Tool

public struct LangChainTool {
    public let name: String
    public let description: String
    public let parameters: [String: String]
    
    public init(name: String, description: String, parameters: [String: String]) {
        self.name = name
        self.description = description
        self.parameters = parameters
    }
}