# Analysis of 10 Emails from User Screenshot (2025-10-17 08:49)

## Email 1: Gym and Fitness
- **Visible Merchant:** "Gym and Fitness"
- **Visible From:** "gymandfitness.com.au"
- **Visible Amount:** $139.00
- **Visible GST:** $12.64
- **Expected Result:** ✅ CORRECT - Merchant matches sender domain
- **Test Status:** Should PASS with current code

## Email 2: Bunnings (First occurrence - Row 2)
- **Visible Merchant:** "Bunnings"
- **Visible From:** "klook.com" (partial visible)
- **Visible Amount:** $123.45
- **Expected Merchant:** Should be "**Klook**" (sender domain is authoritative)
- **Current Result:** ❌ WRONG - Shows "Bunnings" instead of "Klook"
- **Root Cause:** Email from Klook about a Bunnings booking/purchase
- **Fix Needed:** Already fixed in commit 9909f46f (uses sender domain)
- **Test Status:** Should PASS after cache clear

## Email 3: Bunnings (Row 3)
- **Visible Merchant:** "Bunnings"
- **Visible From:** "bunnings.com" (appears to be actual bunnings domain)
- **Expected Result:** ✅ CORRECT - Should be "Bunnings"
- **Test Status:** Should PASS

## Email 4: ANZ Group Holdings Ltd
- **Visible Merchant:** "ANZ Group Holdings Ltd"
- **Visible From:** Likely "anz.com" or similar
- **Expected Result:** Should extract "ANZ" from domain
- **Test Needed:** Verify ANZ extraction works

## Email 5: Bunnings Holdings Ltd (Row 5)
- **Visible Merchant:** "Bunnings Holdings Ltd"
- **Visible From:** Partial visible, appears different from bunnings.com
- **Expected Merchant:** Should match sender domain (NOT "Bunnings Holdings")
- **Test Needed:** Verify this is marketplace/intermediary

## Email 6: BlueBet
- **Visible Merchant:** "BlueBet"
- **Visible From:** Appears to be "smai.com.au" based on earlier context
- **Expected Merchant:** Should be "**SMAI**" if sender is smai.com.au
- **Current Result:** ❌ WRONG if showing BlueBet with SMAI sender
- **Test Needed:** Verify sender domain extraction

## Email 7: Angel Foundry
- **Visible Merchant:** "Angel Foundry"
- **Visible From:** Likely "angelfoundry.com" or "smai.com.au"
- **Expected Merchant:** Should match sender domain
- **Test Needed:** Verify extraction

## Email 8: Bunnings (Row 8 - with MA.clevarea.com.au)
- **Visible Merchant:** "Bunnings"
- **Visible From:** "MA.clevarea.com.au"
- **Expected Merchant:** Should be "**Clevarea**"
- **Current Result:** ❌ WRONG - Shows "Bunnings" instead of "Clevarea"
- **Fix:** Already in commit 9909f46f
- **Test Status:** Should PASS after cache clear

## Email 9: Three Kings Pizza
- **Visible Merchant:** "Three Kings Pizza"
- **Visible From:** "notify.tryhuboox.com"
- **Expected Merchant:** Should be "**Huboox**" (sender) or "**Three Kings Pizza**" if explicitly in subject
- **Current Result:** Appears correct in screenshot
- **Test Needed:** Verify Huboox subdomain handling

## Email 10: Apple
- **Visible Merchant:** "Apple"
- **Visible From:** Likely "apple.com" domain
- **Expected Result:** ✅ Should be "Apple"
- **Test Status:** Should PASS

## Email 11: Amigo Energy
- **Visible Merchant:** "Amigo Energy"
- **Visible From:** "amigoenergy.com.au"
- **Expected Result:** ✅ Should be "Amigo Energy"
- **Test Status:** Should PASS

## SUMMARY OF ISSUES:

**Currently WRONG (need cache clear):**
- Klook emails showing as "Bunnings"
- Clevarea emails showing as "Bunnings"
- Possible SMAI emails showing wrong merchants

**Currently CORRECT:**
- Gym and Fitness
- Three Kings Pizza (via Huboox)
- Apple
- Amigo Energy
- Direct Bunnings emails

**ACTION:** User needs to clear Core Data cache or click Re-Extract All button
