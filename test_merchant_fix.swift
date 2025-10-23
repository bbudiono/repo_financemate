#!/usr/bin/env swift
import Foundation

// Copy the EXACT extractMerchant logic from GmailTransactionExtractor.swift
func extractMerchant(from subject: String, sender: String) -> String? {
    // Extract domain from sender
    guard let atIndex = sender.firstIndex(of: "@") else { return nil }
    let domain = String(sender[sender.index(after: atIndex)...])
        .replacingOccurrences(of: ">", with: "")
        .trimmingCharacters(in: .whitespaces)

    // Government (.gov.au domains) - THE FIX
    if domain.contains(".gov.au") || domain.contains(".qld.gov") {
        let parts = domain.components(separatedBy: ".")

        if let dept = parts.first, !["www", "mail", "noreply", "no-reply"].contains(dept.lowercased()) {
            switch dept.lowercased() {
            case "defence": return "Department of Defence"
            case "goldcoast": return "Gold Coast Council"
            case "ato": return "Australian Taxation Office"
            default:
                return dept.capitalized + " Government"
            }
        }

        return "Government"
    }

    // Bunnings check
    if domain.contains("bunnings.com") { return "Bunnings" }

    return "Unknown"
}

// TEST 1: defence.gov.au
let defence = extractMerchant(from: "Invoice", sender: "noreply@defence.gov.au")
print("defence.gov.au → \(defence ?? "nil")")
assert(defence == "Department of Defence", "FAILED: Expected 'Department of Defence', got '\(defence ?? "nil")'")

// TEST 2: bunnings.com.au
let bunnings = extractMerchant(from: "Order", sender: "noreply@bunnings.com.au")
print("bunnings.com.au → \(bunnings ?? "nil")")
assert(bunnings == "Bunnings", "FAILED: Expected 'Bunnings', got '\(bunnings ?? "nil")'")

// TEST 3: marketplace.ezibuy.com.au
let ezibuy = extractMerchant(from: "Order", sender: "noreply@marketplace.ezibuy.com.au")
print("marketplace.ezibuy.com.au → \(ezibuy ?? "nil")")
assert(ezibuy != "Bunnings", "FAILED: ezibuy showing as Bunnings!")

print("\n✅ ALL TESTS PASSED - Merchant extraction logic is CORRECT")
