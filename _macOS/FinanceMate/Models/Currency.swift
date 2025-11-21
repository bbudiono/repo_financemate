import Foundation
import SwiftUI

// MARK: - Currency Model
// BLUEPRINT Line 132: Multi-Currency Support with AUD default

enum SupportedCurrency: String, CaseIterable, Identifiable {
    case aud = "AUD"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case nzd = "NZD"
    case jpy = "JPY"
    case cad = "CAD"
    case sgd = "SGD"
    case hkd = "HKD"
    case cny = "CNY"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .aud: return "Australian Dollar"
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .nzd: return "New Zealand Dollar"
        case .jpy: return "Japanese Yen"
        case .cad: return "Canadian Dollar"
        case .sgd: return "Singapore Dollar"
        case .hkd: return "Hong Kong Dollar"
        case .cny: return "Chinese Yuan"
        }
    }

    var symbol: String {
        switch self {
        case .aud, .usd, .nzd, .cad, .sgd, .hkd: return "$"
        case .eur: return "E"
        case .gbp: return "L"
        case .jpy, .cny: return "Y"
        }
    }

    var flag: String {
        switch self {
        case .aud: return "AU"
        case .usd: return "US"
        case .eur: return "EU"
        case .gbp: return "GB"
        case .nzd: return "NZ"
        case .jpy: return "JP"
        case .cad: return "CA"
        case .sgd: return "SG"
        case .hkd: return "HK"
        case .cny: return "CN"
        }
    }

    var localeIdentifier: String {
        switch self {
        case .aud: return "en_AU"
        case .usd: return "en_US"
        case .eur: return "de_DE"
        case .gbp: return "en_GB"
        case .nzd: return "en_NZ"
        case .jpy: return "ja_JP"
        case .cad: return "en_CA"
        case .sgd: return "en_SG"
        case .hkd: return "zh_HK"
        case .cny: return "zh_CN"
        }
    }

    var decimalPlaces: Int {
        switch self {
        case .jpy: return 0
        default: return 2
        }
    }
}

// MARK: - Currency Formatter
// BLUEPRINT Line 132: Locale-correct currency formatting

struct CurrencyFormatter {

    /// Format amount with locale-correct currency display
    static func format(_ amount: Double, currency: SupportedCurrency = .aud) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        formatter.locale = Locale(identifier: currency.localeIdentifier)
        formatter.maximumFractionDigits = currency.decimalPlaces
        formatter.minimumFractionDigits = currency.decimalPlaces
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currency.symbol)\(amount)"
    }

    /// Format with both original and converted amounts
    static func formatWithConversion(
        originalAmount: Double,
        originalCurrency: SupportedCurrency,
        convertedAmount: Double,
        targetCurrency: SupportedCurrency = .aud
    ) -> String {
        if originalCurrency == targetCurrency {
            return format(originalAmount, currency: originalCurrency)
        }

        let original = format(originalAmount, currency: originalCurrency)
        let converted = format(convertedAmount, currency: targetCurrency)
        return "\(original) (\(converted))"
    }

    /// Parse currency string to double
    static func parse(_ string: String, currency: SupportedCurrency = .aud) -> Double? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        formatter.locale = Locale(identifier: currency.localeIdentifier)

        // Try parsing with formatter first
        if let number = formatter.number(from: string) {
            return number.doubleValue
        }

        // Fallback: strip non-numeric characters except decimal
        let cleaned = string.replacingOccurrences(of: "[^0-9.-]", with: "", options: .regularExpression)
        return Double(cleaned)
    }
}

// MARK: - Currency Display View

struct CurrencyAmountView: View {
    let amount: Double
    let currency: SupportedCurrency
    let originalAmount: Double?
    let originalCurrency: SupportedCurrency?
    let showConversion: Bool

    init(
        amount: Double,
        currency: SupportedCurrency = .aud,
        originalAmount: Double? = nil,
        originalCurrency: SupportedCurrency? = nil,
        showConversion: Bool = true
    ) {
        self.amount = amount
        self.currency = currency
        self.originalAmount = originalAmount
        self.originalCurrency = originalCurrency
        self.showConversion = showConversion
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(CurrencyFormatter.format(amount, currency: currency))
                .fontWeight(.medium)
                .foregroundColor(amount < 0 ? .red : .green)

            if showConversion,
               let origAmount = originalAmount,
               let origCurrency = originalCurrency,
               origCurrency != currency {
                Text("(\(CurrencyFormatter.format(origAmount, currency: origCurrency)))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Currency Picker View

struct CurrencyPicker: View {
    @Binding var selection: SupportedCurrency
    let label: String

    var body: some View {
        Picker(label, selection: $selection) {
            ForEach(SupportedCurrency.allCases) { currency in
                HStack {
                    Text(currency.flag)
                    Text("\(currency.rawValue) - \(currency.name)")
                }
                .tag(currency)
            }
        }
    }
}

// MARK: - Transaction Extension for Currency

extension Transaction {
    /// Get the display currency for this transaction
    var displayCurrency: SupportedCurrency {
        if let currencyCode = value(forKey: "originalCurrency") as? String,
           let currency = SupportedCurrency(rawValue: currencyCode) {
            return currency
        }
        return .aud
    }

    /// Formatted amount string with locale-correct display
    var formattedAmount: String {
        CurrencyFormatter.format(amount, currency: .aud)
    }

    /// Full formatted amount including original currency if different
    var formattedAmountWithConversion: String {
        guard let origAmount = value(forKey: "originalAmount") as? Double,
              let origCurrencyCode = value(forKey: "originalCurrency") as? String,
              let origCurrency = SupportedCurrency(rawValue: origCurrencyCode),
              origCurrency != .aud else {
            return CurrencyFormatter.format(amount, currency: .aud)
        }

        return CurrencyFormatter.formatWithConversion(
            originalAmount: origAmount,
            originalCurrency: origCurrency,
            convertedAmount: amount,
            targetCurrency: .aud
        )
    }
}
