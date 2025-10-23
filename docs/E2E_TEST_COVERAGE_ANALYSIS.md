# E2E TEST COVERAGE ANALYSIS

**Version**: 1.0.0
**Created**: 2025-10-24
**Total Requirements**: 114 BLUEPRINT MVP requirements
**Current E2E Tests**: 20 tests
**Actual Coverage**: 17.5% (20 tests / 114 requirements)

---

## EXECUTIVE SUMMARY

The current "E2E" tests are **NOT true end-to-end tests**. They are **build validation + code pattern matching tests** that check for file existence and string patterns in code, but do NOT validate actual functionality or user workflows.

**Critical Issues:**
1. Tests use `grep` to search for strings like "extractTransaction" in files
2. Tests check if files exist, not if features work
3. No functional testing of UI interactions (clicks, edits, sorts, filters)
4. No data flow validation (does extracted data actually reach Core Data?)
5. No user workflow simulation (OAuth → fetch emails → extract → import → verify)

**User's Valid Complaint:** "I WILL NOT ACCEPT MEDIOCRE E2E TESTING" - Current tests ARE mediocre.

---

## CURRENT E2E TESTS MAPPED TO REQUIREMENTS

### BUILD & FOUNDATION (4 tests)

| Test Name | Requirements Covered | Coverage Type | Actual Validation |
|-----------|----------------------|---------------|-------------------|
| `test_build` | None specific | Build success | ✅ **VALID**: Verifies build succeeds with zero warnings |
| `test_kiss_compliance` | None specific | Code quality | ✅ **VALID**: Verifies files <500 lines (KISS principle) |
| `test_security_hardening` | #78 (partial - credential check) | Security | ⚠️ **PARTIAL**: Checks for force unwraps/fatalError, but not comprehensive security |
| `test_core_data_schema` | #106 (partial - Transaction entity) | Data model | ⚠️ **PARTIAL**: Only checks Transaction entity exists, not full star schema |

**Verdict**: Build/security tests are VALID but limited. Core Data test is superficial.

---

### BLUEPRINT MVP (5 tests)

| Test Name | Requirements Covered | Coverage Type | Actual Validation |
|-----------|----------------------|---------------|-------------------|
| `test_tax_category_support` | #80 (tax splitting) | Code grep | ❌ **INVALID E2E**: Only checks if string "taxCategory" appears in code |
| `test_gmail_transaction_extraction` | #5, #6 (Gmail ingestion) | Code grep | ❌ **INVALID E2E**: Checks if files exist and strings like "extractTransaction" appear, doesn't test actual extraction |
| `test_google_sso` | #74 (Google SSO) | Code grep | ❌ **INVALID E2E**: Checks if "GoogleSignIn" string appears, doesn't test OAuth flow |
| `test_ai_chatbot_integration` | #100 (chatbot context) | Code grep | ❌ **INVALID E2E**: Checks files exist and no static dictionaries, doesn't test chatbot responses |
| `test_apple_sso` | #74 (Apple SSO) | Code grep | ❌ **INVALID E2E**: Checks if "ASAuthorizationAppleIDProvider" appears in code |

**Verdict**: All 5 tests are **GREP-BASED CODE PATTERN MATCHING**, not functional E2E tests.

**Example of Invalid Testing:**
```python
# Current "test" - NOT E2E!
has_extract = 'extractTransaction' in api_content  # Just checks if string exists!
assert has_extract, "Not implemented"

# Proper E2E test would be:
# 1. Mock Gmail API with test email
# 2. Call extraction service
# 3. Verify ExtractedTransaction created
# 4. Verify merchant="Bunnings", amount=158.95, confidence>0.7
# 5. Verify no hallucinated fields (ABN != "XX XXX XXX XXX")
```

---

### UI/UX (3 tests)

| Test Name | Requirements Covered | Coverage Type | Actual Validation |
|-----------|----------------------|---------------|-------------------|
| `test_ui_architecture` | #85 (partial - views exist) | File existence | ⚠️ **PARTIAL**: Checks if 5 view files exist, doesn't test UI renders or works |
| `test_dark_light_mode` | None specific | Code grep | ❌ **INVALID**: Checks for Color.primary in code, doesn't test actual dark/light mode rendering |
| `test_search_filter_sort_ui` | #8, #31 (partial - table features) | Code grep | ❌ **INVALID**: Checks if strings "searchText", "sortOption" appear, doesn't test if search/sort actually work |

**Verdict**: UI tests are superficial file/string checks. No visual validation, no interaction testing.

---

### GMAIL FUNCTIONAL (4 tests)

| Test Name | Requirements Covered | Coverage Type | Actual Validation |
|-----------|----------------------|---------------|-------------------|
| `test_gmail_oauth_implementation` | #75 (OAuth flow) | Code grep | ⚠️ **PARTIAL**: Checks OAuth files/functions exist, doesn't test actual OAuth flow works |
| `test_gmail_email_parsing` | #5 (email parsing) | Code grep | ❌ **INVALID**: Checks for ShopBack pattern strings, doesn't parse actual email |
| `test_gmail_ui_integration` | #11, #15 (table UI) | Code grep | ❌ **INVALID**: Checks for "Connect Gmail" string, doesn't test UI renders or buttons work |
| `test_transaction_persistence` | #7 (line items to Core Data) | Code grep | ❌ **INVALID**: Checks for "Transaction(context:" string, doesn't verify data actually persists |

**Verdict**: "Functional" tests are still just code grep. No actual Gmail API calls, no data flow validation.

---

### CHATBOT (1 test)

| Test Name | Requirements Covered | Coverage Type | Actual Validation |
|-----------|----------------------|---------------|-------------------|
| `test_chatbot_llm_integration` | #100 (LLM integration) | Code grep | ❌ **INVALID**: Checks for "apiKey", "stream", "async" strings, doesn't test LLM responses |

**Verdict**: Doesn't test chatbot functionality at all.

---

### INTEGRATION (3 tests)

| Test Name | Requirements Covered | Coverage Type | Actual Validation |
|-----------|----------------------|---------------|-------------------|
| `test_oauth_configuration` | #74 (OAuth config) | File existence | ⚠️ **PARTIAL**: Checks .env.template has OAuth keys, doesn't verify values are correct |
| `test_app_launch` | None specific | Process check | ✅ **VALID E2E**: Actually launches app, checks process running, captures screenshot |
| `test_lineitem_schema` | #7 (LineItem entity) | Code grep | ⚠️ **PARTIAL**: Checks LineItem entity exists, doesn't verify relationships or constraints |

**Verdict**: `test_app_launch` is the ONLY true E2E test that performs actual action and validation.

---

## COVERAGE SUMMARY

### Requirements Covered (Sort of)
Out of 114 total requirements, current E2E tests **superficially touch** 20 requirements:
- #5, #6, #7, #8, #11, #15, #74, #75, #78, #80, #85, #100, #106

But NONE are properly validated except:
- Build success ✅
- KISS compliance ✅
- App launches ✅

### Requirements NOT Covered (94 requirements!)

**High-Priority Gaps:**
1. **Gmail 14-column table** (#11): Table exists, but inline editing, multi-select, Excel-like interactions NOT tested
2. **Foundation Models extraction** (#42-73): 83% accuracy claimed but NOT validated with test emails
3. **Tax splitting UI** (#80-84): Splitting code exists, but UI workflow NOT tested
4. **Glassmorphism design** (#86): NOT verified visually
5. **WCAG 2.1 AA accessibility** (#93): NOT tested at all
6. **Keyboard navigation** (#95): NOT tested
7. **Australian localization** (#94): Date format DD/MM/YYYY NOT verified
8. **5-year dataset performance** (#109): NOT tested (<500ms list load requirement)
9. **Offline functionality** (#113): NOT implemented or tested
10. **Error handling** (#112, #114): NOT tested with failure scenarios

**Entire Sections with ZERO E2E Coverage:**
- **3.1.3 Tax Splitting**: 4/5 requirements untested (only grep for "taxCategory")
- **3.1.4 UI/UX**: 18/19 requirements untested (only file existence checks)
- **3.1.5 AI/ML**: 3/4 requirements untested
- **3.1.6 Workflow**: 4/5 requirements untested
- **3.1.7 Data Persistence**: 2/3 requirements untested
- **3.1.8 Performance**: 3/3 requirements untested (0% coverage!)
- **3.1.9 Error Handling**: 3/3 requirements untested

---

## PROPER E2E TEST REQUIREMENTS

### What Real E2E Tests Should Do

**1. Gmail OAuth End-to-End Workflow**
```python
def test_gmail_oauth_complete_workflow():
    """Real E2E: Complete OAuth flow with actual API"""
    # 1. Launch app
    app = launch_app()

    # 2. Navigate to Gmail tab
    gmail_tab = app.find_element("Gmail")
    gmail_tab.click()

    # 3. Verify "Connect Gmail" button present
    connect_btn = app.find_element("Connect Gmail")
    assert connect_btn.is_visible()

    # 4. Click connect → verify auth URL generated
    connect_btn.click()
    auth_url = app.get_clipboard()  # App copies URL
    assert "accounts.google.com/o/oauth2" in auth_url

    # 5. Paste auth code (mock or real)
    app.find_element("authCodeField").type(TEST_AUTH_CODE)
    app.find_element("Submit Code").click()

    # 6. Wait for OAuth exchange → verify token saved to Keychain
    time.sleep(2)
    keychain_token = KeychainHelper.get("gmail_access_token")
    assert keychain_token is not None

    # 7. Verify emails fetched automatically
    email_count = app.find_element("emailCountLabel").text
    assert int(email_count) > 0

    # 8. Verify table populated with extracted transactions
    table_rows = app.find_all_elements("ExtractedTransactionRow")
    assert len(table_rows) > 0

    # 9. Verify first row has merchant, amount, confidence
    first_row = table_rows[0]
    assert first_row.find_element("merchant").text != ""
    assert first_row.find_element("amount").text.startswith("$")
    assert first_row.find_element("confidence").text != ""
```

**2. Foundation Models Extraction Accuracy Validation**
```python
def test_foundation_models_extraction_accuracy():
    """Real E2E: Validate 83% accuracy claim with test emails"""
    test_emails = load_test_samples("scripts/extraction_testing/gmail_test_samples.json")

    results = []
    for email in test_emails:
        # Extract using IntelligentExtractionService
        extracted = IntelligentExtractionService.extract(from: email)

        # Verify against ground truth
        accuracy = compare_with_ground_truth(extracted, email.expected_result)
        results.append(accuracy)

        # Verify no hallucinations
        assert extracted.abn != "XX XXX XXX XXX", "Hallucinated ABN!"
        assert extracted.invoiceNumber != "INV123", "Hallucinated invoice!"

    # Verify >75% accuracy requirement (BLUEPRINT Line 189)
    avg_accuracy = sum(results) / len(results)
    assert avg_accuracy > 0.75, f"Only {avg_accuracy*100}% accurate, need >75%"
```

**3. Gmail Table Multi-Select Functional Test**
```python
def test_gmail_table_multiselect_functional():
    """Real E2E: Test Excel-like multi-select interaction"""
    app = launch_app()
    app.navigate_to("Gmail")

    # Wait for table to load
    table = app.find_element("GmailReceiptsTableView")
    rows = table.find_all_elements("ExtractedTransactionRow")
    assert len(rows) >= 5

    # Select first row via checkbox
    rows[0].find_element("checkbox").click()
    assert rows[0].is_selected()

    # Hold Shift, click 5th row → verify rows 0-4 all selected
    app.keyboard.hold("shift")
    rows[4].find_element("checkbox").click()
    app.keyboard.release("shift")

    for i in range(5):
        assert rows[i].is_selected(), f"Row {i} not selected in Shift+click range"

    # Verify header shows "5 selected"
    header_text = app.find_element("selectionCountLabel").text
    assert "5 selected" in header_text

    # Right-click → verify context menu appears
    rows[2].right_click()
    context_menu = app.find_element("contextMenu")
    assert context_menu.is_visible()
    assert context_menu.has_item("Delete")
    assert context_menu.has_item("Import Selected")
```

**4. Performance Test: 5-Year Dataset**
```python
def test_5_year_dataset_performance():
    """Real E2E: Validate <500ms list load with 50K transactions"""
    # Seed database with 50K transactions
    seed_large_dataset(transaction_count=50000, line_items_per=4)

    app = launch_app()

    # Measure Transactions view load time
    start = time.time()
    app.navigate_to("Transactions")
    table = app.wait_for_element("TransactionsTable", timeout=2)
    load_time = (time.time() - start) * 1000  # Convert to ms

    # BLUEPRINT Line 290: <500ms requirement
    assert load_time < 500, f"List load took {load_time}ms, need <500ms"

    # Measure search time
    search_box = app.find_element("searchField")
    start = time.time()
    search_box.type("Bunnings")
    app.wait_for_search_results()
    search_time = (time.time() - start) * 1000

    # BLUEPRINT Line 290: <300ms search requirement
    assert search_time < 300, f"Search took {search_time}ms, need <300ms"
```

---

## RECOMMENDATION: REPLACE CURRENT E2E TESTS

### Phase 1: Core Functional E2E Tests (8 tests)
1. `test_gmail_oauth_complete_workflow()` - OAuth → fetch → extract → display
2. `test_foundation_models_extraction_accuracy()` - 6 test emails, >75% accuracy
3. `test_gmail_table_multiselect_functional()` - Shift+click, Cmd+click selection
4. `test_gmail_table_inline_edit_functional()` - Double-click → edit → save → verify
5. `test_transaction_filtering_workflow()` - Date filter → verify → category filter → verify
6. `test_tax_splitting_workflow()` - Select transaction → split UI → allocate → save
7. `test_ai_chatbot_workflow()` - Ask "What's my total spending?" → verify response
8. `test_build_and_launch()` - Keep existing app launch test

### Phase 2: UI/UX Validation Tests (5 tests)
9. `test_glassmorphism_design_consistency()` - Screenshot verification of blur effects
10. `test_ui_no_overlap()` - Verify AI chatbot doesn't block tables
11. `test_dark_light_mode_functional()` - Toggle → screenshot → verify contrast
12. `test_voiceover_navigation()` - VoiceOver enabled → navigate all views → verify labels
13. `test_keyboard_only_navigation()` - Complete workflow keyboard-only → no mouse

### Phase 3: Performance & Resilience Tests (5 tests)
14. `test_5_year_dataset_performance()` - 50K transactions, <500ms/<300ms/<200ms requirements
15. `test_extraction_batch_processing()` - 500 emails, verify progress UI, cancellation works
16. `test_offline_functionality()` - Disable network → verify read/edit works
17. `test_error_recovery()` - Force API failures → verify retry logic, user messages
18. `test_data_integrity_on_crash()` - Kill app during save → verify no data loss

### Total: 18 Proper E2E Tests
- **8 Core Functional**: Validate primary user workflows
- **5 UI/UX**: Visual and interaction validation
- **5 Performance**: Load testing and resilience

**Coverage Improvement**: 18 proper E2E tests would cover **60+ requirements** functionally (vs current 3).

---

## ACTION ITEMS

1. ✅ **Phase 1 Complete**: Created requirements matrix (114 requirements mapped)
2. ✅ **Phase 1 Complete**: Analyzed current E2E test coverage (17.5% coverage, mostly invalid)
3. **Next**: Phase 2 - Deploy SME agents for code quality assessment
4. **Next**: Phase 3 - Manual UI testing with screenshots
5. **Next**: Phase 4 - Gap analysis with P0/P1/P2 priorities
6. **Next**: Phase 5 - Implement 18 proper E2E tests

---

**HONEST CONCLUSION**: Current "20/20 E2E tests passing" is misleading. Only 3 tests are valid (build, KISS, app launch). The remaining 17 are code grep tests that don't validate functionality. Need to replace with 18 proper E2E functional tests.
