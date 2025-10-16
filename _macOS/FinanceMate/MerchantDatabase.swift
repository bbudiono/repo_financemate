import Foundation

/// Comprehensive Australian merchant database for accurate domain-to-brand name mapping
/// Handles complex email domains like "info.shopback.com.au" → "Shopback" instead of "info"
struct MerchantDatabase {

    /// Australian merchant domain mappings with brand recognition
    /// Format: "domain_pattern": "BrandName"
    private static let merchantMappings: [String: String] = [
        // Payment & Financial Services
        "afterpay.com": "Afterpay",
        "afterpay.com.au": "Afterpay",
        "paypal.com": "PayPal",
        "zip.co": "Zip Pay",
        "zipmoney.com.au": "Zip Pay",
        "klarna.com": "Klarna",
        "shopback.com": "Shopback",
        "shopback.com.au": "Shopback",

        // Banks & Financial Institutions
        "commbank.com.au": "Commonwealth Bank",
        "cba.com.au": "Commonwealth Bank",
        "nab.com.au": "NAB",
        "anz.com": "ANZ",
        "anz.com.au": "ANZ",
        "westpac.com.au": "Westpac",
        "ing.com.au": "ING",
        "ingdirect.com.au": "ING",
        "macquarie.com": "Macquarie Bank",
        "bendigobank.com.au": "Bendigo Bank",
        "suncorp.com.au": "Suncorp",
        "bankwest.com.au": "Bankwest",
        "mebank.com.au": "ME Bank",
        "ubank.com.au": "UBank",
        "virginmoney.com.au": "Virgin Money",

        // Supermarkets & Grocery
        "woolworths.com.au": "Woolworths",
        "woolworths.com": "Woolworths",
        "coles.com.au": "Coles",
        "aldi.com.au": "ALDI",
        "iga.com.au": "IGA",
        "foodworks.com.au": "Foodworks",
        "harrisfarm.com.au": "Harris Farm Markets",
        "drakes.com.au": "Drakes",

        // Retail & Department Stores
        "kmart.com.au": "Kmart",
        "target.com.au": "Target",
        "bigw.com.au": "Big W",
        "myer.com.au": "Myer",
        "davidjones.com.au": "David Jones",
        "harveynorman.com.au": "Harvey Norman",
        "jbhifi.com.au": "JB Hi-Fi",
        "officeworks.com.au": "Officeworks",
        "bunnings.com.au": "Bunnings",

        // Food Delivery & Takeout
        "ubereats.com": "Uber Eats",
        "doordash.com": "DoorDash",
        "menulog.com.au": "Menulog",
        "deliveroo.com.au": "Deliveroo",
        "foodora.com.au": "Foodora",
        "pizza Hut.com.au": "Pizza Hut",
        "dominos.com.au": "Domino's",
        "dominos.com": "Domino's",
        "subway.com": "Subway",
        "kfc.com.au": "KFC",
        "maccas.com.au": "McDonald's",
        "mcdonalds.com.au": "McDonald's",
        "hungryjacks.com.au": "Hungry Jack's",
        "boostjuice.com.au": "Boost Juice",
        "guzmanygomez.com.au": "Guzman y Gomez",
        "oporto.com.au": "Oporto",
        "nandos.com.au": "Nando's",

        // Online Retail
        "amazon.com.au": "Amazon",
        "amazon.com": "Amazon",
        "ebay.com.au": "eBay",
        "ebay.com": "eBay",
        "thegoodguys.com.au": "The Good Guys",
        "appliancesonline.com.au": "Appliances Online",
        "catch.com.au": "Catch",
        "temu.com": "Temu",
        "shein.com": "SHEIN",
        "aliexpress.com": "AliExpress",
        "ikea.com": "IKEA",
        "ikea.com.au": "IKEA",

        // Fashion & Apparel
        "cottonon.com": "Cotton On",
        "cottonon.com.au": "Cotton On",
        "countryroad.com.au": "Country Road",
        " Witchery.com.au": "Witchery",
        "bonds.com.au": "Bonds",
        "justjeans.com.au": "Just Jeans",
        "jaysports.com.au": "Jay Jays",
        "dotti.com.au": "Dotti",
        "glassons.com": "Glassons",

        // Home & Hardware
        "mitre10.com.au": "Mitre 10",
        "hardwarehouse.com.au": "Hardware House",
        "rebel.com.au": "Rebel Sport",

        // Entertainment & Streaming
        "netflix.com": "Netflix",
        "spotify.com": "Spotify",
        "disneyplus.com": "Disney+",
        "primevideo.com": "Prime Video",
        "youtube.com": "YouTube",
        "apple.com": "Apple",
        "google.com": "Google",
        "microsoft.com": "Microsoft",
        "adobe.com": "Adobe",

        // Travel & Accommodation
        "booking.com": "Booking.com",
        "expedia.com.au": "Expedia",
        "airbnb.com.au": "Airbnb",
        "airbnb.com": "Airbnb",
        "hotels.com": "Hotels.com",
        "wotif.com.au": "Wotif",
        "trip.com": "Trip.com",
        "qantas.com.au": "Qantas",
        "virginaustralia.com": "Virgin Australia",
        "jetstar.com": "Jetstar",

        // Utilities & Services
        "telstra.com.au": "Telstra",
        "optus.com.au": "Optus",
        "vodafone.com.au": "Vodafone",
        "agl.com.au": "AGL",
        "originenergy.com.au": "Origin Energy",
        "energyaustralia.com.au": "Energy Australia",

        // Health & Beauty
        "chemistwarehouse.com.au": "Chemist Warehouse",
        "priceline.com.au": "Priceline",
        "treatt.com.au": "Treatt",

        // Pet Supplies
        "petbarn.com.au": "Petbarn",
        "petstock.com.au": "Petstock",

        // Automotive
        "servo.com.au": "Servo",
        "bp.com.au": "BP",
        "shell.com.au": "Shell",
        "caltex.com.au": "Caltex",
        "7-eleven.com.au": "7-Eleven"
    ]

    /// Extract merchant name from email subject and sender using comprehensive database
    /// - Parameters:
    ///   - subject: Email subject line
    ///   - sender: Sender email address
    /// - Returns: Accurate merchant brand name
    static func extractMerchant(from subject: String, sender: String) -> String? {
        // First try subject line extraction (existing logic)
        if let range = subject.range(of: #"(from|at) ([A-Za-z\s]+)"#, options: .regularExpression) {
            let merchantName = String(subject[range])
                .replacingOccurrences(of: "from ", with: "")
                .replacingOccurrences(of: "at ", with: "")
                .trimmingCharacters(in: .whitespaces)

            if !merchantName.isEmpty {
                return merchantName
            }
        }

        // Enhanced domain-based extraction using merchant database
        return extractMerchantFromDomain(sender: sender)
    }

    /// Extract merchant name from email domain using comprehensive database
    /// - Parameter sender: Sender email address
    /// - Returns: Merchant brand name from database or nil if not found
    private static func extractMerchantFromDomain(sender: String) -> String? {
        guard let atIndex = sender.firstIndex(of: "@") else {
            return nil
        }

        let domain = String(sender[sender.index(after: atIndex)...]).lowercased()

        // Check exact domain matches first
        if let merchant = merchantMappings[domain] {
            return merchant
        }

        // Check partial domain matches (for subdomains like info.shopback.com.au)
        for (mappedDomain, merchant) in merchantMappings {
            if domain.contains(mappedDomain) || mappedDomain.contains(domain) {
                return merchant
            }
        }

        // Fallback: try to extract meaningful brand from domain
        return extractBrandFromDomain(domain: domain)
    }

    /// Extract brand name from domain when no database match found
    /// - Parameter domain: Email domain
    /// - Returns: Best guess brand name
    private static func extractBrandFromDomain(domain: String) -> String? {
        let parts = domain.split(separator: ".").map { $0.lowercased() }

        // Remove common prefixes and suffixes
        let commonPrefixes = ["info", "noreply", "no-reply", "support", "contact", "hello", "team", "orders", "service", "mail", "email"]
        let commonSuffixes = ["com", "com.au", "net", "org", "au", "online", "store", "shop"]

        var brandParts: [String] = []

        for part in parts {
            // Skip common prefixes
            if commonPrefixes.contains(part) {
                continue
            }

            // Skip domain suffixes
            if commonSuffixes.contains(part) {
                continue
            }

            // Skip very short parts
            if part.count < 2 {
                continue
            }

            brandParts.append(part)
        }

        // If we have brand parts, capitalize the first one
        if let firstBrand = brandParts.first {
            return firstBrand.prefix(1).uppercased() + firstBrand.dropFirst()
        }

        // Last resort: return the domain part before common TLDs
        if let mainPart = parts.first, mainPart.count > 2 {
            return mainPart.prefix(1).uppercased() + mainPart.dropFirst()
        }

        return nil
    }
}