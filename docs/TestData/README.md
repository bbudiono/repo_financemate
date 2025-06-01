# TestData Directory

This directory is used to store test data files (images, PDFs, sample documents) for automated and manual testing of FinanceMate features. Add non-sensitive, realistic test files here for use in unit and UI tests. 

## Purpose & Importance

**DO NOT DELETE THIS DIRECTORY OR ITS CONTENTS**

This directory contains essential test files for:
- OCR (Optical Character Recognition) testing and development
- Document format validation
- Line item extraction verification
- Receipt/invoice type detection

## Current Test Files

The directory includes various PDF invoices and receipts with different formats, structures, and complexities to ensure comprehensive testing of OCR capabilities:

- `invoice.pdf` - Basic invoice format
- `Invoice-CD321CC3-0006.pdf` - Complex invoice with multiple sections
- `Invoice-ABE2A154-0046.pdf` / `Invoice-ABE2A154-0046 (1).pdf` - Duplicate test cases (intentional)
- `invoice_139999_1034005.pdf` / `invoice_139999_692431.pdf` - Numbered invoice series
- `INVOICE - Bell Legal.pdf` - Legal invoice format with detailed line items
- `invoice-w1m-000092156-20230618-232703.pdf` - Invoice with timestamp and ID in filename

## Usage in Tests

Reference these files in tests using:

```swift
// For unit tests
let testPDFPath = Bundle.module.path(forResource: "invoice", ofType: "pdf", inDirectory: "TestData")

// For UI tests
let testBundle = Bundle(for: type(of: self))
let testPDFURL = testBundle.url(forResource: "invoice", withExtension: "pdf", subdirectory: "TestData")
```

## Maintenance Guidelines

1. When adding new test files:
   - Ensure they are realistic but don't contain sensitive/private information
   - Use descriptive filenames indicating the document type and characteristics
   - Consider adding variants for edge cases (low quality, different languages, etc.)

2. Document any special characteristics of test files that make them useful for specific test cases

3. If a specific file is referenced in automated tests, note that dependency here to prevent accidental deletion

## Reference in Code

These files are referenced in:
- `OCRServiceTests.swift`
- `DocumentProcessingTests.swift`
- `TesseractOCRServiceTests.swift` 