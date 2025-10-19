#!/usr/bin/env python3
"""
DIRECT DATABASE FIX - Normalize Merchants NOW
==============================================
Fixes verbose merchant names in YOUR Core Data database immediately
No code changes, no rebuilds - just fixes the actual data you're seeing
"""

import sqlite3
from pathlib import Path

DB_PATH = Path.home() / "Library/Containers/com.ablankcanvas.financemate/Data/Library/Application Support/FinanceMate/FinanceMate.sqlite"

def fix_merchants():
    print("=" * 80)
    print("DIRECT DATABASE FIX - Normalizing Merchant Names")
    print("=" * 80)

    if not DB_PATH.exists():
        print(f"❌ Database not found: {DB_PATH}")
        return

    conn = sqlite3.connect(str(DB_PATH))
    cursor = conn.cursor()

    # Show BEFORE state
    print("\nBEFORE FIX - Current merchants:")
    cursor.execute("""
        SELECT ZITEMDESCRIPTION, ZCATEGORY, COUNT(*) as Count
        FROM ZTRANSACTION
        WHERE ZSOURCEEMAILID IS NOT NULL
        GROUP BY ZITEMDESCRIPTION, ZCATEGORY
        ORDER BY Count DESC
        LIMIT 20
    """)
    before_rows = cursor.fetchall()
    for merchant, category, count in before_rows:
        print(f"  {merchant:30} | {category:15} | {count} rows")

    # Normalize verbose names
    print("\nNormalizing...")

    updates = [
        ("Bunnings", "%Bunnings%", "Bunnings"),
        ("ANZ", "%ANZ%", "ANZ"),
        ("Amazon", "%Amazon%", "Amazon"),
        ("Officeworks", "%Officeworks%", "Officeworks"),
        ("Menulog", "%Menulog%", "Menulog"),
        ("Umart", "%Umart%", "Umart"),
        ("Afterpay", "%Afterpay%", "Afterpay"),
        ("Woolworths", "%Woolworths%", "Woolworths"),
        ("Coles", "%Coles%", "Coles"),
    ]

    total_changed = 0
    for target, pattern, exclude in updates:
        cursor.execute(f"""
            UPDATE ZTRANSACTION
            SET ZITEMDESCRIPTION = ?
            WHERE ZITEMDESCRIPTION LIKE ?
              AND ZITEMDESCRIPTION != ?
              AND ZSOURCEEMAILID IS NOT NULL
        """, (target, pattern, exclude))
        changed = cursor.rowcount
        if changed > 0:
            print(f"  ✓ Normalized {changed} rows to '{target}'")
            total_changed += changed

    conn.commit()

    # Show AFTER state
    print("\nAFTER FIX - Normalized merchants:")
    cursor.execute("""
        SELECT ZITEMDESCRIPTION, ZCATEGORY, COUNT(*) as Count
        FROM ZTRANSACTION
        WHERE ZSOURCEEMAILID IS NOT NULL
        GROUP BY ZITEMDESCRIPTION, ZCATEGORY
        ORDER BY Count DESC
        LIMIT 20
    """)
    after_rows = cursor.fetchall()
    for merchant, category, count in after_rows:
        is_clean = all(x not in merchant for x in ["Warehouse", ".com", "Group", "Holdings", "Prime", "Ltd"])
        symbol = "✓" if is_clean else "⚠"
        print(f"  {symbol} {merchant:30} | {category:15} | {count} rows")

    conn.close()

    print("\n" + "=" * 80)
    print(f"TOTAL FIXED: {total_changed} merchant names normalized")
    print("=" * 80)
    print("\n✅ DATABASE UPDATED")
    print("Launch FinanceMate app now to see corrected merchant names")
    print("=" * 80)

if __name__ == "__main__":
    fix_merchants()
