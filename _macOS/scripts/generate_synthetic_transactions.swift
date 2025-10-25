#!/usr/bin/env swift
import Foundation
import CoreData

// Generate 50,000 synthetic transactions spanning 5 years
// For performance testing per BLUEPRINT Lines 290-294

print("Generating 50,000 synthetic transactions...")

let merchants = [
    "Woolworths", "Coles", "Bunnings", "Kmart", "Target",
    "Chemist Warehouse", "JB Hi-Fi", "Harvey Norman", "The Good Guys",
    "Dan Murphy's", "BWS", "Liquorland", "First Choice", "Vintage Cellars",
    "McDonald's", "KFC", "Hungry Jack's", "Subway", "Domino's",
    "Uber", "Uber Eats", "Menulog", "DoorDash", "Deliveroo",
    "Petrol Station", "BP", "Caltex", "Shell", "7-Eleven",
    "ATO", "Rates Notice", "Electricity", "Gas", "Water",
    "Internet", "Mobile Phone", "Gym Membership", "Insurance"
]

let categories = ["Groceries", "Household", "Dining", "Transport", "Utilities", "Entertainment", "Health", "Other"]

let today = Date()
let fiveYearsAgo = Calendar.current.date(byAdding: .year, value: -5, to: today)!

var transactions: [[String: Any]] = []

for i in 0..<50000 {
    let randomDays = Int.random(in: 0...(365*5))
    let date = Calendar.current.date(byAdding: .day, value: -randomDays, to: today)!

    let merchant = merchants.randomElement()!
    let amount = Double.random(in: 5.0...500.0)
    let category = categories.randomElement()!
    let gst = amount * 0.1

    transactions.append([
        "merchant": merchant,
        "amount": String(format: "%.2f", amount),
        "date": ISO8601DateFormatter().string(from: date),
        "category": category,
        "gst": String(format: "%.2f", gst),
        "description": "\(merchant) purchase on \(date.formatted())"
    ])

    if (i + 1) % 10000 == 0 {
        print("Generated \(i + 1) transactions...")
    }
}

// Save to JSON
let jsonData = try! JSONSerialization.data(withJSONObject: transactions, options: .prettyPrinted)
let outputPath = "synthetic_transactions_50k.json"
try! jsonData.write(to: URL(fileURLWithPath: outputPath))

print("✅ Generated 50,000 transactions")
print("   Saved to: \(outputPath)")
print("   Date range: \(fiveYearsAgo.formatted()) to \(today.formatted())")
