//
//  DataValidationService.swift
//  FinanceMate
//
//  Purpose: Comprehensive data validation and sanitization service for security hardening
//  Prevents injection attacks, validates input data, and ensures data integrity

import CryptoKit
import Foundation
import RegexBuilder

@MainActor
public final class DataValidationService {
    public static let shared = DataValidationService()
    
    private let auditLogger = SecurityAuditLogger.shared
    
    // Input validation patterns
    private let emailPattern = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
    private let phonePattern = #"^\+?[1-9]\d{1,14}$"#
    private let currencyPattern = #"^[0-9]+(\.[0-9]{1,2})?$"#
    private let alphanumericPattern = #"^[a-zA-Z0-9\s\-_\.]+$"#
    
    // Dangerous patterns to detect and block
    private let sqlInjectionPatterns = [
        #"(?i)(union|select|insert|update|delete|drop|create|alter|exec|execute)"#,
        #"(?i)(script|javascript|vbscript)"#,
        #"(?i)(<|>|&lt;|&gt;)"#,
        #"(?i)(or\s+1\s*=\s*1|and\s+1\s*=\s*1)"#,
        #"(?i)(;|--|/\*|\*/)"#
    ]
    
    private let xssPatterns = [
        #"(?i)<script[^>]*>.*?</script>"#,
        #"(?i)javascript:"#,
        #"(?i)on\w+\s*="#,
        #"(?i)<iframe[^>]*>.*?</iframe>"#,
        #"(?i)<object[^>]*>.*?</object>"#,
        #"(?i)<embed[^>]*>.*?</embed>"#
    ]
    
    private let pathTraversalPatterns = [
        #"\.\./"#,
        #"\.\.\\"#,
        #"~/"#,
        #"/etc/"#,
        #"/var/"#,
        #"/tmp/"#
    ]
    
    private init() {}
    
    // MARK: - Primary Validation Methods
    
    /// Validates and sanitizes financial data input
    public func validateFinancialData(_ data: [String: Any]) throws -> [String: Any] {
        var sanitizedData: [String: Any] = [:]
        
        for (key, value) in data {
            // Validate key name
            guard isValidFieldName(key) else {
                auditLogger.log(event: .securityPolicyViolation(
                    policy: "Data Validation",
                    details: "Invalid field name detected: \(key)"
                ))
                throw ValidationError.invalidFieldName(key)
            }
            
            // Validate and sanitize value based on field type
            sanitizedData[key] = try validateAndSanitizeValue(value, forField: key)
        }
        
        return sanitizedData
    }
    
    /// Validates document upload data
    public func validateDocumentData(_ fileName: String, _ fileData: Data) throws -> (fileName: String, data: Data) {
        // Validate file name
        let sanitizedFileName = try sanitizeFileName(fileName)
        
        // Validate file size (max 50MB for financial documents)
        guard fileData.count <= 50 * 1024 * 1024 else {
            throw ValidationError.fileTooLarge(fileData.count)
        }
        
        // Validate file type
        guard isValidFileType(fileData) else {
            throw ValidationError.invalidFileType
        }
        
        // Scan for malicious content
        try scanFileForThreats(fileData)
        
        return (sanitizedFileName, fileData)
    }
    
    /// Validates user input from forms
    public func validateUserInput(_ input: String, type: InputType) throws -> String {
        // Check for injection attempts
        try detectInjectionAttempts(input)
        
        // Validate format based on type
        guard isValidFormat(input, type: type) else {
            throw ValidationError.invalidFormat(type.rawValue)
        }
        
        // Sanitize the input
        return sanitizeString(input, type: type)
    }
    
    /// Validates API request data
    public func validateAPIRequest(_ request: [String: Any]) throws -> [String: Any] {
        var validatedRequest: [String: Any] = [:]
        
        for (key, value) in request {
            // Check for malicious keys
            guard !containsMaliciousPatterns(key) else {
                auditLogger.log(event: .suspiciousActivity(
                    details: "Malicious API request key detected: \(key)"
                ))
                throw ValidationError.maliciousInput
            }
            
            // Validate and sanitize value
            if let stringValue = value as? String {
                validatedRequest[key] = try validateUserInput(stringValue, type: .general)
            } else if let numberValue = value as? NSNumber {
                validatedRequest[key] = validateNumber(numberValue)
            } else if let arrayValue = value as? [Any] {
                validatedRequest[key] = try validateArray(arrayValue)
            } else if let dictValue = value as? [String: Any] {
                validatedRequest[key] = try validateAPIRequest(dictValue)
            } else {
                validatedRequest[key] = value
            }
        }
        
        return validatedRequest
    }
    
    // MARK: - Specific Validation Methods
    
    private func validateAndSanitizeValue(_ value: Any, forField field: String) throws -> Any {
        switch field.lowercased() {
        case "email":
            guard let email = value as? String else { throw ValidationError.typeMismatch(field) }
            return try validateUserInput(email, type: .email)
            
        case "phone":
            guard let phone = value as? String else { throw ValidationError.typeMismatch(field) }
            return try validateUserInput(phone, type: .phone)
            
        case "amount", "totalamount", "taxamount", "subtotal":
            if let stringValue = value as? String {
                return try validateUserInput(stringValue, type: .currency)
            } else if let numberValue = value as? NSNumber {
                return validateCurrency(numberValue.doubleValue)
            } else {
                throw ValidationError.typeMismatch(field)
            }
            
        case "vendorname", "customerName", "description":
            guard let text = value as? String else { throw ValidationError.typeMismatch(field) }
            return try validateUserInput(text, type: .text)
            
        case "invoicenumber", "purchaseorder":
            guard let alphanumeric = value as? String else { throw ValidationError.typeMismatch(field) }
            return try validateUserInput(alphanumeric, type: .alphanumeric)
            
        case "notes", "metadata":
            guard let text = value as? String else { throw ValidationError.typeMismatch(field) }
            return sanitizeText(text)
            
        case "date", "invoicedate", "duedate":
            if let dateString = value as? String {
                return try validateDateString(dateString)
            } else if let date = value as? Date {
                return date
            } else {
                throw ValidationError.typeMismatch(field)
            }
            
        default:
            // Generic validation for unknown fields
            if let stringValue = value as? String {
                return try validateUserInput(stringValue, type: .general)
            }
            return value
        }
    }
    
    private func isValidFieldName(_ fieldName: String) -> Bool {
        // Field names should only contain alphanumeric characters and underscores
        let pattern = #"^[a-zA-Z][a-zA-Z0-9_]{0,50}$"#
        return fieldName.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func isValidFormat(_ input: String, type: InputType) -> Bool {
        let pattern: String
        
        switch type {
        case .email:
            pattern = emailPattern
        case .phone:
            pattern = phonePattern
        case .currency:
            pattern = currencyPattern
        case .alphanumeric:
            pattern = alphanumericPattern
        case .text, .general:
            return true // Will be sanitized instead
        }
        
        return input.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func detectInjectionAttempts(_ input: String) throws {
        let inputLower = input.lowercased()
        
        // Check for SQL injection patterns
        for pattern in sqlInjectionPatterns {
            if inputLower.range(of: pattern, options: .regularExpression) != nil {
                auditLogger.log(event: .suspiciousActivity(
                    details: "SQL injection attempt detected in input"
                ))
                throw ValidationError.sqlInjectionAttempt
            }
        }
        
        // Check for XSS patterns
        for pattern in xssPatterns {
            if inputLower.range(of: pattern, options: .regularExpression) != nil {
                auditLogger.log(event: .suspiciousActivity(
                    details: "XSS attempt detected in input"
                ))
                throw ValidationError.xssAttempt
            }
        }
        
        // Check for path traversal patterns
        for pattern in pathTraversalPatterns {
            if inputLower.range(of: pattern, options: .regularExpression) != nil {
                auditLogger.log(event: .suspiciousActivity(
                    details: "Path traversal attempt detected in input"
                ))
                throw ValidationError.pathTraversalAttempt
            }
        }
    }
    
    private func containsMaliciousPatterns(_ input: String) -> Bool {
        let combined = sqlInjectionPatterns + xssPatterns + pathTraversalPatterns
        
        for pattern in combined {
            if input.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Sanitization Methods
    
    private func sanitizeString(_ input: String, type: InputType) -> String {
        var sanitized = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch type {
        case .email:
            // Remove any non-email characters
            sanitized = sanitized.components(separatedBy: .whitespacesAndNewlines).joined()
            
        case .phone:
            // Keep only digits and plus sign
            sanitized = sanitized.components(separatedBy: CharacterSet(charactersIn: "0123456789+").inverted).joined()
            
        case .currency:
            // Keep only digits and decimal point
            sanitized = sanitized.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()
            
        case .alphanumeric:
            // Keep only alphanumeric characters, spaces, hyphens, underscores, and periods
            let allowedCharacters = CharacterSet.alphanumerics.union(.whitespaces).union(CharacterSet(charactersIn: "-_."))
            sanitized = sanitized.components(separatedBy: allowedCharacters.inverted).joined()
            
        case .text, .general:
            sanitized = sanitizeText(sanitized)
        }
        
        // Limit length
        let maxLength = type.maxLength
        if sanitized.count > maxLength {
            sanitized = String(sanitized.prefix(maxLength))
        }
        
        return sanitized
    }
    
    private func sanitizeText(_ text: String) -> String {
        var sanitized = text
        
        // Remove or escape dangerous characters
        sanitized = sanitized
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#x27;")
            .replacingOccurrences(of: "/", with: "&#x2F;")
        
        // Remove potentially dangerous Unicode characters
        sanitized = sanitized.components(separatedBy: .controlCharacters).joined()
        
        return sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func sanitizeFileName(_ fileName: String) throws -> String {
        // Remove path components
        let baseName = URL(fileURLWithPath: fileName).lastPathComponent
        
        // Check for dangerous file names
        let dangerousNames = ["con", "prn", "aux", "nul", "com1", "com2", "lpt1", "lpt2"]
        if dangerousNames.contains(baseName.lowercased()) {
            throw ValidationError.dangerousFileName(baseName)
        }
        
        // Sanitize the name
        var sanitized = baseName
            .replacingOccurrences(of: "..", with: "")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "*", with: "_")
            .replacingOccurrences(of: "?", with: "_")
            .replacingOccurrences(of: "<", with: "_")
            .replacingOccurrences(of: ">", with: "_")
            .replacingOccurrences(of: "|", with: "_")
        
        // Ensure it's not empty
        if sanitized.isEmpty {
            sanitized = "document"
        }
        
        // Limit length
        if sanitized.count > 100 {
            let nameWithoutExtension = URL(fileURLWithPath: sanitized).deletingPathExtension().lastPathComponent
            let pathExtension = URL(fileURLWithPath: sanitized).pathExtension
            let truncatedName = String(nameWithoutExtension.prefix(90))
            sanitized = pathExtension.isEmpty ? truncatedName : "\(truncatedName).\(pathExtension)"
        }
        
        return sanitized
    }
    
    // MARK: - File Validation
    
    private func isValidFileType(_ fileData: Data) -> Bool {
        // Check file signatures (magic numbers)
        let validSignatures: [Data] = [
            Data([0x25, 0x50, 0x44, 0x46]), // PDF
            Data([0xFF, 0xD8, 0xFF]),       // JPEG
            Data([0x89, 0x50, 0x4E, 0x47]), // PNG
            Data([0x50, 0x4B, 0x03, 0x04]), // ZIP/Office documents
            Data([0x50, 0x4B, 0x05, 0x06]), // ZIP empty
            Data([0x50, 0x4B, 0x07, 0x08])  // ZIP spanned
        ]
        
        for signature in validSignatures {
            if fileData.starts(with: signature) {
                return true
            }
        }
        
        return false
    }
    
    private func scanFileForThreats(_ fileData: Data) throws {
        // Basic malware signature detection
        let maliciousSignatures = [
            Data([0x4D, 0x5A]), // PE executable
            Data([0x7F, 0x45, 0x4C, 0x46]), // ELF executable
            Data([0xFE, 0xED, 0xFA, 0xCE]), // Mach-O 32-bit
            Data([0xFE, 0xED, 0xFA, 0xCF])  // Mach-O 64-bit
        ]
        
        for signature in maliciousSignatures {
            if fileData.starts(with: signature) {
                auditLogger.log(event: .suspiciousActivity(
                    details: "Potentially malicious file uploaded"
                ))
                throw ValidationError.maliciousFile
            }
        }
        
        // Check for embedded scripts in PDFs and Office documents
        if let content = String(data: fileData, encoding: .utf8) {
            let scriptPatterns = ["javascript:", "<script", "eval(", "document.write"]
            for pattern in scriptPatterns {
                if content.lowercased().contains(pattern) {
                    auditLogger.log(event: .suspiciousActivity(
                        details: "Embedded script detected in uploaded file"
                    ))
                    throw ValidationError.embeddedScript
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func validateNumber(_ number: NSNumber) -> NSNumber {
        let doubleValue = number.doubleValue
        
        // Check for infinity and NaN
        guard doubleValue.isFinite && !doubleValue.isNaN else {
            return NSNumber(value: 0.0)
        }
        
        // Reasonable bounds for financial data
        if doubleValue < -1_000_000_000 {
            return NSNumber(value: -1_000_000_000)
        } else if doubleValue > 1_000_000_000 {
            return NSNumber(value: 1_000_000_000)
        }
        
        return number
    }
    
    private func validateCurrency(_ amount: Double) throws -> Double {
        guard amount.isFinite && !amount.isNaN else {
            throw ValidationError.invalidCurrency
        }
        
        // Currency should not exceed reasonable bounds
        guard amount >= -1_000_000_000 && amount <= 1_000_000_000 else {
            throw ValidationError.currencyOutOfBounds
        }
        
        // Round to 2 decimal places
        return (amount * 100).rounded() / 100
    }
    
    private func validateDateString(_ dateString: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        
        if let date = formatter.date(from: dateString) {
            // Ensure date is within reasonable bounds
            let earliestDate = Calendar.current.date(byAdding: .year, value: -100, to: Date()) ?? Date()
            let latestDate = Calendar.current.date(byAdding: .year, value: 10, to: Date()) ?? Date()
            
            guard date >= earliestDate && date <= latestDate else {
                throw ValidationError.dateOutOfBounds
            }
            
            return date
        }
        
        // Try alternative formats
        let altFormatter = DateFormatter()
        altFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = altFormatter.date(from: dateString) {
            return date
        }
        
        throw ValidationError.invalidDateFormat
    }
    
    private func validateArray(_ array: [Any]) throws -> [Any] {
        // Limit array size
        guard array.count <= 1000 else {
            throw ValidationError.arrayTooLarge
        }
        
        var validatedArray: [Any] = []
        
        for item in array {
            if let stringItem = item as? String {
                validatedArray.append(try validateUserInput(stringItem, type: .general))
            } else if let numberItem = item as? NSNumber {
                validatedArray.append(validateNumber(numberItem))
            } else if let dictItem = item as? [String: Any] {
                validatedArray.append(try validateAPIRequest(dictItem))
            } else {
                validatedArray.append(item)
            }
        }
        
        return validatedArray
    }
}

// MARK: - Supporting Types

public enum InputType: String {
    case email = "email"
    case phone = "phone"
    case currency = "currency"
    case alphanumeric = "alphanumeric"
    case text = "text"
    case general = "general"
    
    var maxLength: Int {
        switch self {
        case .email: return 254
        case .phone: return 20
        case .currency: return 20
        case .alphanumeric: return 100
        case .text: return 1000
        case .general: return 500
        }
    }
}

public enum ValidationError: LocalizedError {
    case invalidFieldName(String)
    case typeMismatch(String)
    case invalidFormat(String)
    case sqlInjectionAttempt
    case xssAttempt
    case pathTraversalAttempt
    case maliciousInput
    case fileTooLarge(Int)
    case invalidFileType
    case maliciousFile
    case embeddedScript
    case dangerousFileName(String)
    case invalidCurrency
    case currencyOutOfBounds
    case dateOutOfBounds
    case invalidDateFormat
    case arrayTooLarge
    
    public var errorDescription: String? {
        switch self {
        case .invalidFieldName(let name):
            return "Invalid field name: \(name)"
        case .typeMismatch(let field):
            return "Type mismatch for field: \(field)"
        case .invalidFormat(let type):
            return "Invalid format for type: \(type)"
        case .sqlInjectionAttempt:
            return "SQL injection attempt detected"
        case .xssAttempt:
            return "Cross-site scripting attempt detected"
        case .pathTraversalAttempt:
            return "Path traversal attempt detected"
        case .maliciousInput:
            return "Malicious input detected"
        case .fileTooLarge(let size):
            return "File too large: \(size) bytes"
        case .invalidFileType:
            return "Invalid file type"
        case .maliciousFile:
            return "Potentially malicious file detected"
        case .embeddedScript:
            return "Embedded script detected in file"
        case .dangerousFileName(let name):
            return "Dangerous file name: \(name)"
        case .invalidCurrency:
            return "Invalid currency value"
        case .currencyOutOfBounds:
            return "Currency value out of bounds"
        case .dateOutOfBounds:
            return "Date value out of bounds"
        case .invalidDateFormat:
            return "Invalid date format"
        case .arrayTooLarge:
            return "Array size exceeds maximum allowed"
        }
    }
}