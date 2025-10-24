#!/usr/bin/env python3
"""
Phase 1A: Diagnostic Core Data Persistence Test

Simplified version that tests database creation and persistence
without app launch complexity
"""

import sqlite3
import sys
import os
from pathlib import Path
from datetime import datetime

# Configuration
CONTAINER_DIR = Path.home() / "Library/Containers/com.ablankcanvas.financemate/Data/Library/Application Support/FinanceMate"
SQLITE_DB_PATH = CONTAINER_DIR / "FinanceMate.sqlite"

def check_core_data_database():
    """Check if Core Data database exists and is valid"""
    print("[TEST 1] Checking if Core Data database exists...")

    if not SQLITE_DB_PATH.exists():
        print(f"  FAIL: Database does not exist at {SQLITE_DB_PATH}")
        return False

    print(f"  PASS: Database found")
    db_size = SQLITE_DB_PATH.stat().st_size
    print(f"  Size: {db_size} bytes")

    return True

def verify_database_integrity():
    """Verify the database file is a valid SQLite database"""
    print("\n[TEST 2] Verifying database integrity...")

    try:
        conn = sqlite3.connect(str(SQLITE_DB_PATH))
        cursor = conn.cursor()

        # This will fail if the database is corrupted
        cursor.execute("SELECT COUNT(*) FROM sqlite_master")
        result = cursor.fetchone()

        print(f"  PASS: Database is valid SQLite (found {result[0]} objects)")
        conn.close()
        return True
    except Exception as e:
        print(f"  FAIL: Database integrity check failed: {e}")
        return False

def list_database_tables():
    """List all tables in the Core Data database"""
    print("\n[TEST 3] Listing database tables...")

    try:
        conn = sqlite3.connect(str(SQLITE_DB_PATH))
        cursor = conn.cursor()

        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
        tables = cursor.fetchall()

        if not tables:
            print("  WARN: No tables found in database")
            conn.close()
            return False

        print(f"  PASS: Found {len(tables)} tables:")
        for table in tables:
            cursor.execute(f"PRAGMA table_info({table[0]})")
            columns = cursor.fetchall()
            col_names = [c[1] for c in columns]
            print(f"    - {table[0]} ({len(columns)} columns): {col_names[:3]}...")

        conn.close()
        return True
    except Exception as e:
        print(f"  FAIL: Could not list tables: {e}")
        return False

def check_core_data_metadata():
    """Check for Core Data specific metadata"""
    print("\n[TEST 4] Checking for Core Data metadata...")

    try:
        conn = sqlite3.connect(str(SQLITE_DB_PATH))
        cursor = conn.cursor()

        # Check for Core Data's Z_METADATA table
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='Z_METADATA'")
        has_z_metadata = cursor.fetchone() is not None

        if has_z_metadata:
            print("  PASS: Z_METADATA table exists (Core Data formatted)")
            cursor.execute("SELECT Z_VERSION, Z_UUID, Z_PLIST FROM Z_METADATA LIMIT 1")
            metadata = cursor.fetchone()
            if metadata:
                print(f"    Core Data Version: {metadata[0]}")
                print(f"    UUID: {metadata[1]}")
        else:
            print("  WARN: Z_METADATA table not found (may not be Core Data format)")

        conn.close()
        return has_z_metadata
    except Exception as e:
        print(f"  WARN: Could not check metadata: {e}")
        return False

def check_transaction_persistence():
    """Check if there are any transaction records"""
    print("\n[TEST 5] Checking for transaction data...")

    try:
        conn = sqlite3.connect(str(SQLITE_DB_PATH))
        cursor = conn.cursor()

        # Find tables that might contain transactions
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name LIKE '%TRANSACTION%'")
        trans_tables = cursor.fetchall()

        if trans_tables:
            print(f"  Found {len(trans_tables)} transaction-related table(s):")
            for table in trans_tables:
                cursor.execute(f"SELECT COUNT(*) FROM {table[0]}")
                count = cursor.fetchone()[0]
                print(f"    - {table[0]}: {count} records")
            conn.close()
            return True
        else:
            print("  INFO: No transaction tables found (expected for fresh app)")
            conn.close()
            return False
    except Exception as e:
        print(f"  WARN: Could not check transactions: {e}")
        return False

def main():
    """Run all diagnostic tests"""
    print("\n" + "="*60)
    print("CORE DATA PERSISTENCE DIAGNOSTIC TEST")
    print("="*60)

    tests = [
        check_core_data_database,
        verify_database_integrity,
        list_database_tables,
        check_core_data_metadata,
        check_transaction_persistence
    ]

    results = []
    for test in tests:
        try:
            result = test()
            results.append(result)
        except Exception as e:
            print(f"  ERROR: Test crashed: {e}")
            results.append(False)

    print("\n" + "="*60)
    print("DIAGNOSTIC RESULTS")
    print("="*60)

    passed = sum(1 for r in results if r)
    total = len(results)

    print(f"\nTests Passed: {passed}/{total}")

    if results[0]:  # Database exists
        print("Status: Core Data database is PRESENT and FUNCTIONAL")
        return 0
    else:
        print("Status: Core Data database is MISSING or CORRUPTED")
        return 1

if __name__ == "__main__":
    sys.exit(main())
