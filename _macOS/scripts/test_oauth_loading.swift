#!/usr/bin/env swift
import Foundation

// Test OAuth credential loading
print("Testing OAuth Credential Loading...")
print(String(repeating: "=", count: 60))

// Load the .env file manually for testing
let envPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/.env"

if let contents = try? String(contentsOfFile: envPath, encoding: .utf8) {
    print(" Found .env file")

    // Parse and load environment variables
    let lines = contents.components(separatedBy: .newlines)
    var loadedCount = 0

    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !trimmed.hasPrefix("#") && trimmed.contains("=") {
            let parts = trimmed.split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                setenv(key, value, 1)
                loadedCount += 1

                // Debug output for OAuth vars only
                if key.contains("GOOGLE") {
                    let displayValue = value.count > 20 ? String(value.prefix(20)) + "..." : value
                    print("  Loaded: \(key) = \(displayValue)")
                }
            }
        }
    }

    print(" Loaded \(loadedCount) environment variables")
} else {
    print(" Could not find .env file at \(envPath)")
    exit(1)
}

print("\n" + String(repeating: "=", count: 60))
print("Validating OAuth Configuration...")
print(String(repeating: "=", count: 60))

// Test OAuth credential accessibility
let clientID = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_ID"] ?? ""
let clientSecret = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_SECRET"] ?? ""
let redirectURI = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_REDIRECT_URI"] ?? ""

// Expected values for bernhardbudiono@gmail.com
let expectedClientID = "[REDACTED_CLIENT_ID]"
let expectedRedirectURI = "http://localhost:8080/callback"

// Validate Client ID
if !clientID.isEmpty {
    if clientID == expectedClientID {
        print(" GOOGLE_OAUTH_CLIENT_ID: Correct for bernhardbudiono@gmail.com")
        print("   Value: \(String(clientID.prefix(40)))...")
    } else {
        print("️ GOOGLE_OAUTH_CLIENT_ID: Found but doesn't match bernhardbudiono@gmail.com")
        print("   Expected: \(expectedClientID)")
        print("   Got: \(clientID)")
    }
} else {
    print(" GOOGLE_OAUTH_CLIENT_ID: NOT FOUND in environment")
}

// Validate Client Secret
if !clientSecret.isEmpty {
    print(" GOOGLE_OAUTH_CLIENT_SECRET: Found (hidden for security)")
} else {
    print(" GOOGLE_OAUTH_CLIENT_SECRET: NOT FOUND in environment")
}

// Validate Redirect URI
if !redirectURI.isEmpty {
    if redirectURI == expectedRedirectURI {
        print(" GOOGLE_OAUTH_REDIRECT_URI: Correct")
        print("   Value: \(redirectURI)")
    } else {
        print("️ GOOGLE_OAUTH_REDIRECT_URI: Found but unexpected value")
        print("   Expected: \(expectedRedirectURI)")
        print("   Got: \(redirectURI)")
    }
} else {
    print(" GOOGLE_OAUTH_REDIRECT_URI: NOT FOUND in environment")
}

// Test OAuth URL generation
print("\n" + String(repeating: "=", count: 60))
print("Testing OAuth URL Generation...")
print(String(repeating: "=", count: 60))

var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")
components?.queryItems = [
    URLQueryItem(name: "client_id", value: clientID),
    URLQueryItem(name: "redirect_uri", value: "urn:ietf:wg:oauth:2.0:oob"),
    URLQueryItem(name: "response_type", value: "code"),
    URLQueryItem(name: "scope", value: "https://www.googleapis.com/auth/gmail.readonly"),
    URLQueryItem(name: "access_type", value: "offline"),
    URLQueryItem(name: "prompt", value: "consent")
]

if let url = components?.url {
    print(" OAuth URL generated successfully")
    print("   URL: \(String(url.absoluteString.prefix(100)))...")

    // Validate URL contains the right client ID
    if url.absoluteString.contains(expectedClientID) {
        print(" OAuth URL configured for bernhardbudiono@gmail.com")
    } else if url.absoluteString.contains("client_id=") {
        print("️ OAuth URL has a client_id but not for bernhardbudiono@gmail.com")
    } else {
        print(" OAuth URL missing client_id parameter")
    }
} else {
    print(" Failed to generate OAuth URL")
}

// Summary
print("\n" + String(repeating: "=", count: 60))
print("SUMMARY")
print(String(repeating: "=", count: 60))

let allValid = !clientID.isEmpty && !clientSecret.isEmpty && !redirectURI.isEmpty &&
               clientID == expectedClientID && components?.url != nil

if allValid {
    print(" ALL CHECKS PASSED - Gmail OAuth ready for bernhardbudiono@gmail.com")
    exit(0)
} else {
    print(" OAuth configuration incomplete or incorrect")
    print("   The 'Connect Gmail' button will not work until this is fixed")
    exit(1)
}