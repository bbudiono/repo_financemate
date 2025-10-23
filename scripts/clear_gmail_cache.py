#!/usr/bin/env python3
"""Clear poisoned Gmail extraction cache from Core Data SQLite store"""

import sqlite3
import os
from pathlib import Path

# Core Data store path (sandboxed container)
store_path = Path.home() / "Library/Containers/com.ablankcanvas.financemate/Data/Library/Application Support/FinanceMate/FinanceMate.sqlite"

print(f"Core Data Store: {store_path}")

if not store_path.exists():
    print(f"ERROR: Store not found at {store_path}")
    print("Have you run the app at least once to create the database?")
    exit(1)

# Connect to SQLite database
conn = sqlite3.connect(str(store_path))
cursor = conn.cursor()

# Count cached extractions (transactions with sourceEmailID)
cursor.execute("SELECT COUNT(*) FROM ZTRANSACTION WHERE ZSOURCEEMAILID IS NOT NULL")
count = cursor.fetchone()[0]

print(f"\nFound {count} cached extraction(s) in Core Data")

if count == 0:
    print("Cache already empty - nothing to clear")
    conn.close()
    exit(0)

# Show sample of poisoned data before deletion
print("\nSample of cached data (first 5):")
cursor.execute("""
    SELECT ZITEMDESCRIPTION, ZSOURCEEMAILID, ZAMOUNT
    FROM ZTRANSACTION
    WHERE ZSOURCEEMAILID IS NOT NULL
    LIMIT 5
""")
for row in cursor.fetchall():
    print(f"  - Merchant: {row[0]}, EmailID: {row[1]}, Amount: ${row[2]}")

# Delete all cached extractions
print(f"\nDeleting {count} cached extraction(s)...")
cursor.execute("DELETE FROM ZTRANSACTION WHERE ZSOURCEEMAILID IS NOT NULL")
conn.commit()

# Verify deletion
cursor.execute("SELECT COUNT(*) FROM ZTRANSACTION WHERE ZSOURCEEMAILID IS NOT NULL")
remaining = cursor.fetchone()[0]

if remaining == 0:
    print(f"SUCCESS: Cleared {count} cached extraction(s)")
    print("\nNEXT STEPS:")
    print("1. Launch FinanceMate app")
    print("2. Navigate to Gmail tab")
    print("3. Click 'Refresh' or 'Re-Extract All' button")
    print("4. Verify defence.gov.au emails show 'Department of Defence' (NOT 'Bunnings')")
else:
    print(f"WARNING: {remaining} records still remain after deletion")

conn.close()
