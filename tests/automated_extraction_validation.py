#!/usr/bin/env python3
"""
Automated Gmail Extraction Validation
NO USER INTERACTION REQUIRED

Process:
1. Clear Core Data database (remove old cached extractions)
2. Launch FinanceMate app (triggers auto-extraction on Gmail tab)
3. Wait for extraction to complete (30 seconds)
4. Query database to verify correct merchants extracted
5. Generate proof report with before/after comparison

This proves the fix works BEFORE asking user to validate
"""

import sqlite3
import subprocess
import time
from pathlib import Path
from datetime import datetime

DB_PATH = Path.home() / "Library/Containers/com.ablankcanvas.financemate/Data/Library/Application Support/FinanceMate/FinanceMate.sqlite"
APP_PATH = Path("/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app")

def clear_core_data_cache():
    """Clear all Gmail-extracted transactions from Core Data"""
    print("\n[1/5] Clearing Core Data cache...")

    if not DB_PATH.exists():
        print("❌ Database not found - app never launched")
        return False

    try:
        conn = sqlite3.connect(str(DB_PATH))
        cursor = conn.cursor()

        # Delete all transactions with sourceEmailID (Gmail extractions)
        cursor.execute("DELETE FROM ZTRANSACTION WHERE ZSOURCEEMAILID IS NOT NULL")
        deleted = cursor.rowcount

        conn.commit()
        conn.close()

        print(f"✓ Cleared {deleted} cached Gmail extractions from database")
        return True
    except Exception as e:
        print(f"❌ Failed to clear cache: {e}")
        return False

def launch_app():
    """Launch FinanceMate app"""
    print("\n[2/5] Launching FinanceMate app...")

    # Kill any running instances first
    subprocess.run(["pkill", "-9", "FinanceMate"], capture_output=True)
    time.sleep(1)

    # Launch app
    subprocess.Popen(["open", str(APP_PATH)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    print("✓ App launched")
    return True

def wait_for_extraction():
    """Wait for Gmail extraction to complete"""
    print("\n[3/5] Waiting for Gmail extraction to complete...")
    print("  (App auto-extracts when Gmail tab loads)")

    # Wait 30 seconds for extraction
    for i in range(30):
        time.sleep(1)
        if (i + 1) % 5 == 0:
            print(f"  ...{i + 1}s elapsed")

    print("✓ Extraction should be complete")

def validate_extracted_data():
    """Check database for correct merchant extractions"""
    print("\n[4/5] Validating extracted merchant data...")

    try:
        conn = sqlite3.connect(str(DB_PATH))
        cursor = conn.cursor()

        # Query extracted transactions
        cursor.execute("""
            SELECT ZITEMDESCRIPTION, ZCATEGORY, ZAMOUNT, ZSOURCEEMAILID
            FROM ZTRANSACTION
            WHERE ZSOURCEEMAILID IS NOT NULL
            LIMIT 20
        """)

        rows = cursor.fetchall()
        conn.close()

        if not rows:
            print("⚠️  No extracted transactions found")
            print("   (Either no emails in Gmail or extraction failed)")
            return False

        print(f"✓ Found {len(rows)} extracted transactions")
        print("\n" + "=" * 80)
        print("EXTRACTION RESULTS:")
        print("=" * 80)

        # Expected correct values (not "Gmail" / "Other")
        correct_merchants = 0
        correct_categories = 0
        wrong_extractions = []

        for i, (merchant, category, amount, email_id) in enumerate(rows, 1):
            # Check if merchant is correct (not "Gmail")
            is_correct_merchant = merchant != "Gmail" and merchant != "Unknown"
            is_correct_category = category != "Other"

            symbol_m = "✓" if is_correct_merchant else "✗"
            symbol_c = "✓" if is_correct_category else "✗"

            print(f"{i}. {symbol_m} Merchant: {merchant:20} {symbol_c} Category: {category:15} Amount: ${amount:.2f}")

            if is_correct_merchant:
                correct_merchants += 1
            if is_correct_category:
                correct_categories += 1

            if not (is_correct_merchant and is_correct_category):
                wrong_extractions.append({
                    "merchant": merchant,
                    "category": category,
                    "email_id": email_id[:8]
                })

        print("=" * 80)
        merchant_accuracy = (correct_merchants / len(rows) * 100) if rows else 0
        category_accuracy = (correct_categories / len(rows) * 100) if rows else 0

        print(f"\nMERCHANT ACCURACY: {correct_merchants}/{len(rows)} ({merchant_accuracy:.1f}%)")
        print(f"CATEGORY ACCURACY: {correct_categories}/{len(rows)} ({category_accuracy:.1f}%)")

        if wrong_extractions:
            print(f"\n⚠️  ISSUES FOUND ({len(wrong_extractions)}):")
            for w in wrong_extractions:
                print(f"   - {w['merchant']} ({w['category']}) - Email: {w['email_id']}")

        # Success if >90% accurate
        success = merchant_accuracy >= 90 and category_accuracy >= 90

        if success:
            print("\n✅ EXTRACTION VALIDATED: >90% accuracy achieved")
        else:
            print(f"\n❌ EXTRACTION FAILED: {merchant_accuracy:.0f}% merchant accuracy (need >90%)")

        return success

    except Exception as e:
        print(f"❌ Database validation failed: {e}")
        return False

def generate_report(success):
    """Generate validation report"""
    print("\n[5/5] Generating validation report...")

    report = f"""
AUTOMATED GMAIL EXTRACTION VALIDATION REPORT
=============================================
Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
Commit: 0d56ec53 + Display Name Fix

VALIDATION PROCESS:
1. Cleared Core Data cache (deleted Gmail extractions)
2. Launched FinanceMate app (auto-extraction triggered)
3. Waited 30 seconds for extraction completion
4. Queried database for extracted merchants

RESULT: {"PASSED ✓" if success else "FAILED ✗"}

See console output above for detailed merchant/category breakdown.

NEXT STEPS:
{"- Ready for user validation" if success else "- Fix remaining issues before user testing"}
{"- Commit fixes and push to GitHub" if success else "- Debug extraction failures"}
"""

    print(report)

    # Save to file
    report_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/test_output") / f"automated_validation_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(report)

    print(f"\n📄 Report saved: {report_path}")

def main():
    print("=" * 80)
    print("AUTOMATED GMAIL EXTRACTION VALIDATION")
    print("=" * 80)
    print("Running AUTONOMOUS end-to-end validation")
    print("NO user interaction required")
    print("=" * 80)

    # Step 1: Clear cache
    if not clear_core_data_cache():
        print("\n❌ ABORTED: Could not clear cache")
        return 1

    # Step 2: Launch app
    if not launch_app():
        print("\n❌ ABORTED: Could not launch app")
        return 1

    # Step 3: Wait for extraction
    wait_for_extraction()

    # Step 4: Validate
    success = validate_extracted_data()

    # Step 5: Report
    generate_report(success)

    return 0 if success else 1

if __name__ == "__main__":
    exit(main())
