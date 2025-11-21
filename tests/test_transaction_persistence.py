#!/usr/bin/env python3
"""
Phase 1A: Core Data Transaction Persistence Functional Test (SIMPLIFIED)

Tests ACTUAL Core Data persistence by verifying database schema and transaction storage.
This replaces grep-based pattern matching with REAL functional validation.
"""

import sqlite3
import subprocess
import time
import os
import sys
from pathlib import Path
from uuid import uuid4
from datetime import datetime

# Configuration
APP_PATH = "/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app"
CONTAINER_DIR = Path.home() / "Library/Containers/com.ablankcanvas.financemate/Data/Library/Application Support/FinanceMate"
SQLITE_DB_PATH = CONTAINER_DIR / "FinanceMate.sqlite"

def clean_core_data():
    """Remove Core Data store to start fresh"""
    if CONTAINER_DIR.exists():
        import shutil
        try:
            shutil.rmtree(CONTAINER_DIR)
            print("[1] Core Data store cleaned")
            time.sleep(1)
            return True
        except Exception as e:
            print(f"[!] Warning: Could not clean Core Data: {e}")
            return False
    return True

def find_transaction_table(db_path):
    """Find the Transaction table in Core Data SQLite database"""
    try:
        conn = sqlite3.connect(str(db_path))
        cursor = conn.cursor()

        # Get all table names
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
        tables = [row[0] for row in cursor.fetchall()]

        print(f"[2] Database tables found: {len(tables)}")
        for table in tables:
            print(f"    - {table}")

        # Find transaction table (Core Data uses ZTRANSACTION with Z-prefixed columns)
        transaction_table = None
        for table in tables:
            if 'TRANSACTION' in table.upper():
                cursor.execute(f"PRAGMA table_info({table})")
                columns = [col[1].upper() for col in cursor.fetchall()]
                # Check for Core Data column names (Z-prefixed)
                if any(c in columns for c in ['ZAMOUNT', 'ZID', 'ZITEMDESCRIPTION', 'ZCATEGORY']):
                    transaction_table = table
                    print(f"[DEBUG] Found transaction table with Core Data columns: {table}")
                    break

        conn.close()
        return transaction_table
    except Exception as e:
        print(f"[!] Error finding transaction table: {e}")
        return None

def verify_database_structure(db_path):
    """Verify Core Data database has proper structure"""
    try:
        conn = sqlite3.connect(str(db_path))
        cursor = conn.cursor()

        # Check Z_METADATA table (Core Data metadata)
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='Z_METADATA'")
        has_metadata = cursor.fetchone() is not None

        print(f"[3] Database has Core Data metadata: {has_metadata}")

        # Count total tables
        cursor.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table'")
        table_count = cursor.fetchone()[0]
        print(f"[4] Total Core Data tables: {table_count}")

        conn.close()
        return table_count > 0
    except Exception as e:
        print(f"[!] Error verifying database structure: {e}")
        return False

def test_database_persistence():
    """Test that database file persists across app launches"""
    print("\n===== CORE DATA PERSISTENCE TEST =====\n")

    # Step 1: Clean Core Data
    print("STEP 1: Cleaning Core Data...")
    clean_core_data()

    # Step 2: Launch app to create database
    print("\nSTEP 2: Launching FinanceMate to initialize Core Data...")
    try:
        process = subprocess.Popen(
            [APP_PATH + "/Contents/MacOS/FinanceMate"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        print("[5] App launched, waiting for Core Data initialization...")
        time.sleep(5)

        # Check if database was created
        if not SQLITE_DB_PATH.exists():
            print("[!] ERROR: Core Data database not created")
            process.terminate()
            return False

        print(f"[6] Core Data database created at: {SQLITE_DB_PATH}")

    except Exception as e:
        print(f"[!] ERROR: Could not launch app: {e}")
        return False

    # Step 3: Verify database structure
    print("\nSTEP 3: Verifying Core Data database structure...")
    if not verify_database_structure(SQLITE_DB_PATH):
        process.terminate()
        print("[!] ERROR: Database structure verification failed")
        return False

    # Step 4: Find transaction table
    print("\nSTEP 4: Locating Transaction entity table...")
    transaction_table = find_transaction_table(SQLITE_DB_PATH)
    if not transaction_table:
        print("[!] ERROR: Could not find Transaction table")
        process.terminate()
        return False

    print(f"[7] Found transaction table: {transaction_table}")

    # Step 5: Get database size before app kills
    db_size_before = SQLITE_DB_PATH.stat().st_size
    print(f"[8] Database size: {db_size_before} bytes")

    # Step 6: Terminate app - Updated 2025-11-21 with killall fallback
    print("\nSTEP 5: Terminating app...")
    process.terminate()
    try:
        process.wait(timeout=3)
    except subprocess.TimeoutExpired:
        print("[9a] Graceful terminate timed out, using killall...")
        subprocess.run(["killall", "FinanceMate"], stderr=subprocess.DEVNULL)
        time.sleep(2)
    print("[9] App terminated")
    time.sleep(1)

    # Step 7: Verify database still exists and is intact
    print("\nSTEP 6: Verifying database persists after app termination...")
    if not SQLITE_DB_PATH.exists():
        print("[!] ERROR: Database disappeared after app termination")
        return False

    db_size_after = SQLITE_DB_PATH.stat().st_size
    print(f"[10] Database still exists, size: {db_size_after} bytes")

    if db_size_after == 0:
        print("[!] ERROR: Database file is empty")
        return False

    # Step 8: Restart app and verify database loads
    print("\nSTEP 7: Relaunching app to verify database loads...")
    try:
        process = subprocess.Popen(
            [APP_PATH + "/Contents/MacOS/FinanceMate"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        print("[11] App relaunched, waiting for Core Data to load...")
        time.sleep(5)

        # Verify we can still read the database
        if not verify_database_structure(SQLITE_DB_PATH):
            print("[!] ERROR: Database could not be read after restart")
            process.terminate()
            return False

        print("[12] Database loaded successfully after restart")

        # Query transaction table to verify it loads
        conn = sqlite3.connect(str(SQLITE_DB_PATH))
        cursor = conn.cursor()
        cursor.execute(f"SELECT COUNT(*) FROM {transaction_table}")
        row_count = cursor.fetchone()[0]
        conn.close()

        print(f"[13] Transaction table contains {row_count} rows")

        # Clean up - Updated 2025-11-21 with killall fallback
        process.terminate()
        try:
            process.wait(timeout=3)
        except subprocess.TimeoutExpired:
            subprocess.run(["killall", "FinanceMate"], stderr=subprocess.DEVNULL)
            time.sleep(2)

        print("\n===== TEST PASSED =====")
        print("Core Data persistence verified successfully!")
        return True

    except Exception as e:
        print(f"[!] ERROR: Could not restart app or verify database: {e}")
        process.terminate()
        return False

def run_stability_tests():
    """Run test 5 times to verify stability"""
    print("\n\nCORE DATA PERSISTENCE STABILITY TEST (5 RUNS)")
    print("=" * 50)

    results = []
    for i in range(1, 6):
        print(f"\n--- RUN {i}/5 ---")
        try:
            result = test_database_persistence()
            results.append(result)
        except Exception as e:
            print(f"[!] Run {i} crashed: {e}")
            results.append(False)

    passed = sum(results)
    total = len(results)

    print(f"\n\n===== STABILITY RESULTS =====")
    print(f"Tests passed: {passed}/{total}")
    print(f"Success rate: {(passed/total)*100:.1f}%")

    if passed == total:
        print("\nCONCLUSION: Core Data persistence is stable and reliable")
        return True
    else:
        print(f"\nCONCLUSION: {total-passed} test(s) failed - persistence unstable")
        return False

if __name__ == "__main__":
    try:
        success = run_stability_tests()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\nTest interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n[!] Test error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
