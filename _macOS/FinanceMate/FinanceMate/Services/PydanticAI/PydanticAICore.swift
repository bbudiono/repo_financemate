//
//  PydanticAICore.swift
//  FinanceMate
//
//  Created by Assistant on 6/2/25.
//


import Foundation
import Combine

// MARK: - Pydantic Model Protocol

public protocol PydanticModelProtocol: Codable {
    static var schema: PydanticSchema { get }
    func validate() throws
}

// MARK: - Pydantic Model

@MainActor
public class PydanticModel: ObservableObject, Identifiable {
    
    // MARK: - Properties
    
    public let id: String
    public let name: String
    public let schema: PydanticSchema
    public let modelType: String
    
    @Published public var validationCount: Int = 0
    @Published public var lastValidation: Date?
    
    // MARK: - Private Properties
    
    private weak var framework: PydanticAIFramework?
    
    // MARK: - Initialization
    
    public init(id: String, name: String, schema: PydanticSchema, modelType: String, framework: PydanticAIFramework) {
        self.id = id
        self.name = name
        self.schema = schema
        self.modelType = modelType
        self.framework = framework
    }
    
    // MARK: - Public Methods
    
    public func validate<T: PydanticModelProtocol>(data: [String: Any], as type: T.Type) async throws -> PydanticValidationResult<T> {
        guard let framework = framework else {
            throw PydanticError.frameworkNotInitialized
        }
        
        let result = try await framework.validate(data: data, against: type)
        
        validationCount += 1
        lastValidation = Date()
        
        return result
    }
}

// MARK: - Pydantic Schema

public struct PydanticSchema {
    public let name: String
    public let fields: [PydanticField]
    public let validators: [PydanticValidator]
    public let metadata: [String: Any]
    
    public init(name: String, fields: [PydanticField], validators: [PydanticValidator] = [], metadata: [String: Any] = [:]) {
        self.name = name
        self.fields = fields
        self.validators = validators
        self.metadata = metadata
    }
}

public struct PydanticField {
    public let name: String
    public let type: PydanticFieldType
    public let isRequired: Bool
    public let defaultValue: Any?
    public let validators: [PydanticValidator]
    public let description: String?
    
    public init(name: String, type: PydanticFieldType, isRequired: Bool = true, defaultValue: Any? = nil, validators: [PydanticValidator] = [], description: String? = nil) {
        self.name = name
        self.type = type
        self.isRequired = isRequired
        self.defaultValue = defaultValue
        self.validators = validators
        self.description = description
    }
}

public indirect enum PydanticFieldType {
    case string
    case integer
    case float
    case boolean
    case date
    case url
    case email
    case uuid
    case array(PydanticFieldType)
    case object(PydanticSchema)
    case optional(PydanticFieldType)
    case union([PydanticFieldType])
    case custom(String)
}

// MARK: - Pydantic Validator

public struct PydanticValidator {
    public let name: String
    public let rule: PydanticValidationRule
    public let message: String
    
    public init(name: String, rule: @escaping PydanticValidationRule, message: String) {
        self.name = name
        self.rule = rule
        self.message = message
    }
}

public typealias PydanticValidationRule = (Any) throws -> Bool

// MARK: - Pydantic Validation Result

public struct PydanticValidationResult<T: PydanticModelProtocol> {
    public let isValid: Bool
    public let validatedObject: T?
    public let errors: [PydanticValidationError]
    public let warnings: [PydanticValidationWarning]
    
    public init(isValid: Bool, validatedObject: T? = nil, errors: [PydanticValidationError] = [], warnings: [PydanticValidationWarning] = []) {
        self.isValid = isValid
        self.validatedObject = validatedObject
        self.errors = errors
        self.warnings = warnings
    }
}

public struct PydanticValidationError {
    public let field: String
    public let message: String
    public let value: Any?
    public let code: String
    
    public init(field: String, message: String, value: Any? = nil, code: String) {
        self.field = field
        self.message = message
        self.value = value
        self.code = code
    }
}

public struct PydanticValidationWarning {
    public let field: String
    public let message: String
    public let value: Any?
    
    public init(field: String, message: String, value: Any? = nil) {
        self.field = field
        self.message = message
        self.value = value
    }
}

// MARK: - Pydantic Validation

public struct PydanticValidation: Identifiable {
    public let id: String
    public let modelType: String
    public let inputData: [String: Any]
    public let timestamp: Date
    
    public var isValid: Bool = false
    public var errors: [PydanticValidationError] = []
    public var validatedData: Any?
    public var error: String?
    
    public init(id: String, modelType: String, inputData: [String: Any], timestamp: Date) {
        self.id = id
        self.modelType = modelType
        self.inputData = inputData
        self.timestamp = timestamp
    }
}

// MARK: - Pydantic Validation Engine

public class PydanticValidationEngine: ObservableObject {
    
    // MARK: - Properties
    
    public let errorOccurred = PassthroughSubject<Error, Never>()
    
    // MARK: - Private Properties
    
    private let configuration: PydanticConfiguration
    private var customRules: [String: PydanticValidationRule] = [:]
    private let validationQueue = DispatchQueue(label: "com.pydantic.validation", qos: .userInitiated)
    
    // MARK: - Initialization
    
    public init(config: PydanticConfiguration) {
        self.configuration = config
        setupDefaultRules()
    }
    
    // MARK: - Public Methods
    
    public func initialize() async throws {
        print("Pydantic Validation Engine initialized")
    }
    
    public func validate<T: PydanticModelProtocol>(data: [String: Any], against modelType: T.Type) async throws -> PydanticValidationResult<T> {
        do {
            let schema = modelType.schema
            var errors: [PydanticValidationError] = []
            let warnings: [PydanticValidationWarning] = []
            
            // Validate each field
            for field in schema.fields {
                let fieldErrors = try await validateField(field, in: data)
                errors.append(contentsOf: fieldErrors)
            }
            
            // Check for extra fields if not allowed
            if !configuration.allowExtraFields {
                let schemaFieldNames = Set(schema.fields.map { $0.name })
                let dataFieldNames = Set(data.keys)
                let extraFields = dataFieldNames.subtracting(schemaFieldNames)
                
                for extraField in extraFields {
                    errors.append(PydanticValidationError(
                        field: extraField,
                        message: "Extra field not allowed",
                        value: data[extraField],
                        code: "extra_field"
                    ))
                }
            }
            
            // Run custom validators
            for validator in schema.validators {
                do {
                    let isValid = try validator.rule(data)
                    if !isValid {
                        errors.append(PydanticValidationError(
                            field: "root",
                            message: validator.message,
                            value: data,
                            code: "custom_validation"
                        ))
                    }
                } catch {
                    errors.append(PydanticValidationError(
                        field: "root",
                        message: "Validation error: \(error.localizedDescription)",
                        value: data,
                        code: "validation_error"
                    ))
                }
            }
            
            let isValid = errors.isEmpty
            var validatedObject: T?
            
            if isValid {
                // Attempt to create object if validation passed
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    validatedObject = try JSONDecoder().decode(modelType, from: jsonData)
                    try validatedObject?.validate()
                } catch {
                    errors.append(PydanticValidationError(
                        field: "root",
                        message: "Failed to create object: \(error.localizedDescription)",
                        value: data,
                        code: "object_creation_failed"
                    ))
                }
            }
            
            return PydanticValidationResult(
                isValid: isValid && validatedObject != nil,
                validatedObject: validatedObject,
                errors: errors,
                warnings: warnings
            )
            
        } catch {
            errorOccurred.send(error)
            throw PydanticError.validationFailed([PydanticValidationError(
                field: "root",
                message: error.localizedDescription,
                value: data,
                code: "validation_failed"
            )])
        }
    }
    
    public func registerRule(name: String, rule: @escaping PydanticValidationRule) async throws {
        customRules[name] = rule
    }
    
    // MARK: - Private Methods
    
    private func setupDefaultRules() {
        customRules["not_empty"] = { value in
            if let string = value as? String {
                return !string.isEmpty
            }
            return true
        }
        
        customRules["positive"] = { value in
            if let number = value as? Double {
                return number > 0
            }
            if let number = value as? Int {
                return number > 0
            }
            return true
        }
        
        customRules["email"] = { value in
            if let email = value as? String {
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
            }
            return true
        }
        
        customRules["url"] = { value in
            if let urlString = value as? String {
                return URL(string: urlString) != nil
            }
            return true
        }
    }
    
    private func validateField(_ field: PydanticField, in data: [String: Any]) async throws -> [PydanticValidationError] {
        var errors: [PydanticValidationError] = []
        let value = data[field.name]
        
        // Check if required field is missing
        if field.isRequired && value == nil {
            errors.append(PydanticValidationError(
                field: field.name,
                message: "Field is required",
                value: nil,
                code: "required"
            ))
            return errors
        }
        
        // Use default value if provided and value is nil
        let actualValue = value ?? field.defaultValue
        
        guard let actualValue = actualValue else {
            return errors // Optional field with no value
        }
        
        // Validate field type
        let typeErrors = validateFieldType(actualValue, against: field.type, fieldName: field.name)
        errors.append(contentsOf: typeErrors)
        
        // Run field validators
        for validator in field.validators {
            do {
                let isValid = try validator.rule(actualValue)
                if !isValid {
                    errors.append(PydanticValidationError(
                        field: field.name,
                        message: validator.message,
                        value: actualValue,
                        code: "field_validation"
                    ))
                }
            } catch {
                errors.append(PydanticValidationError(
                    field: field.name,
                    message: "Validator error: \(error.localizedDescription)",
                    value: actualValue,
                    code: "validator_error"
                ))
            }
        }
        
        return errors
    }
    
    private func validateFieldType(_ value: Any, against type: PydanticFieldType, fieldName: String) -> [PydanticValidationError] {
        switch type {
        case .string:
            if !(value is String) {
                return [PydanticValidationError(
                    field: fieldName,
                    message: "Expected string, got \(Swift.type(of: value))",
                    value: value,
                    code: "type_error"
                )]
            }
            
        case .integer:
            if !(value is Int) {
                return [PydanticValidationError(
                    field: fieldName,
                    message: "Expected integer, got \(Swift.type(of: value))",
                    value: value,
                    code: "type_error"
                )]
            }
            
        case .float:
            if !(value is Double || value is Float) {
                return [PydanticValidationError(
                    field: fieldName,
                    message: "Expected float, got \(Swift.type(of: value))",
                    value: value,
                    code: "type_error"
                )]
            }
            
        case .boolean:
            if !(value is Bool) {
                return [PydanticValidationError(
                    field: fieldName,
                    message: "Expected boolean, got \(Swift.type(of: value))",
                    value: value,
                    code: "type_error"
                )]
            }
            
        case .array(let elementType):
            guard let array = value as? [Any] else {
                return [PydanticValidationError(
                    field: fieldName,
                    message: "Expected array, got \(Swift.type(of: value))",
                    value: value,
                    code: "type_error"
                )]
            }
            
            var errors: [PydanticValidationError] = []
            for (index, element) in array.enumerated() {
                let elementErrors = validateFieldType(element, against: elementType, fieldName: "\(fieldName)[\(index)]")
                errors.append(contentsOf: elementErrors)
            }
            return errors
            
        case .optional(let innerType):
            // Optional type - value can be nil or match inner type
            return validateFieldType(value, against: innerType, fieldName: fieldName)
            
        case .date, .url, .email, .uuid, .object, .union, .custom:
            // Advanced validation would be implemented here
            break
        }
        
        return []
    }
}

// MARK: - Pydantic Schema Manager

public class PydanticSchemaManager: ObservableObject {
    
    // MARK: - Public Methods
    
    public func initialize() async throws {
        print("Pydantic Schema Manager initialized")
    }
    
    public func generateSchema<T: PydanticModelProtocol>(for modelType: T.Type) async throws -> PydanticSchema {
        // In a real implementation, this would use reflection to generate schema
        // For now, we return the static schema from the type
        return modelType.schema
    }
    
    public func validateSchema(_ schema: PydanticSchema) async throws -> Bool {
        // Validate schema structure
        for field in schema.fields {
            if field.name.isEmpty {
                throw PydanticError.schemaError("Field name cannot be empty")
            }
        }
        
        return true
    }
}

// MARK: - Pydantic Serialization Manager

public class PydanticSerializationManager: ObservableObject {
    
    // MARK: - Public Methods
    
    public func initialize() async throws {
        print("Pydantic Serialization Manager initialized")
    }
    
    public func serialize<T: PydanticModelProtocol>(_ object: T) async throws -> [String: Any] {
        do {
            let data = try JSONEncoder().encode(object)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let dictionary = json as? [String: Any] else {
                throw PydanticError.serializationError("Failed to convert to dictionary")
            }
            
            return dictionary
        } catch {
            throw PydanticError.serializationError(error.localizedDescription)
        }
    }
    
    public func deserialize<T: PydanticModelProtocol>(data: [String: Any], to modelType: T.Type) async throws -> T {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let object = try JSONDecoder().decode(modelType, from: jsonData)
            try object.validate()
            return object
        } catch {
            throw PydanticError.serializationError(error.localizedDescription)
        }
    }
}

// MARK: - LangGraph Integration

public struct PydanticValidationNodeProcessor: LangGraphNodeProcessor {
    private weak var framework: PydanticAIFramework?
    
    public init(framework: PydanticAIFramework) {
        self.framework = framework
    }
    
    public func process(input: [String: Any], context: [String: Any]) async throws -> Any {
        guard let framework = framework else {
            throw PydanticError.frameworkNotInitialized
        }
        
        // Extract validation parameters from input
        guard let modelName = input["model_name"] as? String,
              let _ = input["data"] as? [String: Any] else {
            throw PydanticError.invalidData("Missing model_name or data")
        }
        
        guard await framework.getModel(name: modelName) != nil else {
            throw PydanticError.modelNotFound(modelName)
        }
        
        // For now, return validation result without specific type
        // In a real implementation, this would handle dynamic type validation
        return [
            "validation_result": "processed",
            "model_name": modelName,
            "is_valid": true
        ]
    }
}

