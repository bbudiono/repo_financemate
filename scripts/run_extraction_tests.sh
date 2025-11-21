#!/bin/bash
cd "$(dirname "$0")"

echo "🔨 Compiling Extraction Tests..."

swiftc \
    test_extraction_accuracy.swift \
    ../_macOS/FinanceMate/GmailTransactionExtractor.swift \
    ../_macOS/FinanceMate/GmailStandardTransactionExtractor.swift \
    ../_macOS/FinanceMate/GmailCashbackExtractor.swift \
    ../_macOS/FinanceMate/MerchantDatabase.swift \
    ../_macOS/FinanceMate/Services/InvoiceNumberExtractor.swift \
    ../_macOS/FinanceMate/Services/FieldValidator.swift \
    ../_macOS/FinanceMate/Services/ExtractionConstants.swift \
    ../_macOS/FinanceMate/GmailModels.swift \
    -o extraction_test

if [ $? -eq 0 ]; then
    echo "✅ Compilation Successful"
    echo "🏃 Running Tests..."
    ./extraction_test
    rm extraction_test
else
    echo "❌ Compilation Failed"
    exit 1
fi
