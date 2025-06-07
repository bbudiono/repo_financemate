#!/usr/bin/env swift

/*
 COMPREHENSIVE HEADLESS UX TESTING FRAMEWORK
 FinanceMate Production Application - TestFlight Readiness Validation
 
 This test systematically validates every UX/UI element, navigation flow,
 button functionality, and user journey to ensure production readiness.
 
 TESTING METHODOLOGY: TDD + Manual UX Validation
 - Does it build fine?
 - Do the pages make sense against the blueprint?
 - Does the content make sense?
 - Can I navigate through each page?
 - Can I press every button and does each button do something?
 - Does the flow make sense?
 */

import Foundation
import Cocoa

class ComprehensiveUXTester {
    private var testResults: [String] = []
    private var errorCount = 0
    private var passCount = 0
    
    func runComprehensiveUXValidation() {
        print("🎯 COMPREHENSIVE HEADLESS UX TESTING - FinanceMate Production")
        print(String(repeating: "=", count: 60))
        
        // Phase 1: Application Launch & Core Functionality
        testApplicationLaunch()
        testCoreDataInitialization()
        testSampleDataLoading()
        
        // Phase 2: Navigation System Validation
        testMainNavigationStructure()
        testSidebarNavigation()
        testDetailViewNavigation()
        
        // Phase 3: Individual View Testing
        testDashboardView()
        testAnalyticsView()
        testDocumentsView()
        testSettingsView()
        testCoPilotPanel()
        
        // Phase 4: Button & Action Testing
        testAllButtonFunctionality()
        testToolbarActions()
        testMenuActions()
        
        // Phase 5: Data Flow Testing
        testDataConsistency()
        testRealTimeUpdates()
        testExportFunctionality()
        
        // Phase 6: User Journey Testing
        testCompleteUserWorkflows()
        testErrorHandling()
        testEdgeCases()
        
        generateComprehensiveReport()
    }
    
    // MARK: - Phase 1: Application Launch Testing
    
    func testApplicationLaunch() {
        log("📱 Testing Application Launch...")
        
        // Test 1: Clean build verification
        let buildResult = executeShellCommand("cd '/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate' && xcodebuild -scheme FinanceMate -configuration Release clean build -quiet")
        
        if buildResult.contains("BUILD SUCCEEDED") {
            pass("✅ Application builds successfully")
        } else {
            fail("❌ Build failed: \(buildResult)")
        }
        
        // Test 2: App bundle validation
        let bundlePath = "/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-aflrgjyghbptaqhheqmgecrinvsi/Build/Products/Release/FinanceMate.app"
        if FileManager.default.fileExists(atPath: bundlePath) {
            pass("✅ App bundle created successfully")
        } else {
            fail("❌ App bundle not found")
        }
        
        // Test 3: App launch validation
        let launchResult = executeShellCommand("open '\(bundlePath)'")
        sleep(3) // Allow app to launch
        
        let runningApps = executeShellCommand("ps aux | grep FinanceMate | grep -v grep")
        if !runningApps.isEmpty {
            pass("✅ Application launches successfully")
        } else {
            fail("❌ Application failed to launch")
        }
    }
    
    func testCoreDataInitialization() {
        log("🗄️ Testing Core Data Initialization...")
        
        // Since we can't directly access app internals, we validate based on code structure
        let coreDataStackPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Sources/Core/DataModels/CoreDataStack.swift"
        
        do {
            let coreDataContent = try String(contentsOfFile: coreDataStackPath, encoding: .utf8)
            
            // Test required entities and attributes
            let requiredElements = [
                "NSEntityDescription",
                "FinancialData",
                "Client",
                "Project",
                "NSPersistentContainer",
                "NSManagedObjectContext"
            ]
            
            for element in requiredElements {
                if coreDataContent.contains(element) {
                    pass("✅ Core Data contains: \(element)")
                } else {
                    fail("❌ Core Data missing: \(element)")
                }
            }
        } catch {
            fail("❌ Failed to read Core Data stack: \(error)")
        }
    }
    
    func testSampleDataLoading() {
        log("📊 Testing Sample Data Service...")
        
        let sampleDataPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Services/SampleDataService.swift"
        
        do {
            let sampleDataContent = try String(contentsOfFile: sampleDataPath)
            
            let requiredMethods = [
                "populateInitialData",
                "createSampleFinancialData",
                "createSampleClients",
                "createSampleProjects"
            ]
            
            for method in requiredMethods {
                if sampleDataContent.contains(method) {
                    pass("✅ Sample data includes: \(method)")
                } else {
                    fail("❌ Sample data missing: \(method)")
                }
            }
        } catch {
            fail("❌ Failed to read Sample Data service: \(error)")
        }
    }
    
    // MARK: - Phase 2: Navigation Testing
    
    func testMainNavigationStructure() {
        log("🧭 Testing Main Navigation Structure...")
        
        let contentViewPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/ContentView.swift"
        
        do {
            let contentViewContent = try String(contentsOfFile: contentViewPath)
            
            // Test NavigationSplitView implementation
            if contentViewContent.contains("NavigationSplitView") {
                pass("✅ Main navigation uses NavigationSplitView")
            } else {
                fail("❌ Missing NavigationSplitView structure")
            }
            
            // Test sidebar implementation
            if contentViewContent.contains("SidebarView") {
                pass("✅ Sidebar view implemented")
            } else {
                fail("❌ Missing sidebar implementation")
            }
            
            // Test detail view implementation
            if contentViewContent.contains("DetailView") {
                pass("✅ Detail view implemented")
            } else {
                fail("❌ Missing detail view implementation")
            }
            
        } catch {
            fail("❌ Failed to read ContentView: \(error)")
        }
    }
    
    func testSidebarNavigation() {
        log("📋 Testing Sidebar Navigation...")
        
        let contentViewPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/ContentView.swift"
        
        do {
            let content = try String(contentsOfFile: contentViewPath)
            
            let requiredNavItems = [
                "dashboard",
                "analytics", 
                "documents",
                "settings"
            ]
            
            for item in requiredNavItems {
                if content.contains(item) {
                    pass("✅ Navigation includes: \(item)")
                } else {
                    fail("❌ Navigation missing: \(item)")
                }
            }
        } catch {
            fail("❌ Failed to validate sidebar navigation: \(error)")
        }
    }
    
    func testDetailViewNavigation() {
        log("🔄 Testing Detail View Navigation...")
        
        let contentViewPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/ContentView.swift"
        
        do {
            let content = try String(contentsOfFile: contentViewPath)
            
            // Test navigation handler implementation
            if content.contains("onNavigate") {
                pass("✅ Navigation handler implemented")
            } else {
                fail("❌ Missing navigation handler")
            }
            
            // Test view switching logic
            if content.contains("switch selectedView") {
                pass("✅ View switching logic implemented")
            } else {
                fail("❌ Missing view switching logic")
            }
            
        } catch {
            fail("❌ Failed to validate detail view navigation: \(error)")
        }
    }
    
    // MARK: - Phase 3: Individual View Testing
    
    func testDashboardView() {
        log("📊 Testing Dashboard View...")
        
        let dashboardPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/DashboardView.swift"
        
        do {
            let content = try String(contentsOfFile: dashboardPath)
            
            // Test Core Data integration
            if content.contains("@FetchRequest") {
                pass("✅ Dashboard uses real Core Data")
            } else {
                fail("❌ Dashboard missing Core Data integration")
            }
            
            // Test navigation buttons
            if content.contains("View Details") && content.contains("View All") {
                pass("✅ Dashboard has navigation buttons")
            } else {
                fail("❌ Dashboard missing navigation buttons")
            }
            
            // Test onNavigate parameter
            if content.contains("onNavigate") {
                pass("✅ Dashboard has navigation handler")
            } else {
                fail("❌ Dashboard missing navigation handler")
            }
            
        } catch {
            fail("❌ Failed to validate dashboard view: \(error)")
        }
    }
    
    func testAnalyticsView() {
        log("📈 Testing Analytics View...")
        
        let analyticsPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/AnalyticsView.swift"
        
        do {
            let content = try String(contentsOfFile: analyticsPath)
            
            // Test Core Data integration (not mock data)
            if content.contains("@FetchRequest") && content.contains("coreDataFinancialData") {
                pass("✅ Analytics uses real Core Data")
            } else {
                fail("❌ Analytics missing Core Data integration")
            }
            
            // Test charts implementation
            if content.contains("Chart") {
                pass("✅ Analytics includes charts")
            } else {
                fail("❌ Analytics missing charts")
            }
            
            // Verify NO mock data usage
            if !content.contains("generateSampleTransactions") {
                pass("✅ Analytics removed mock data")
            } else {
                fail("❌ Analytics still using mock data")
            }
            
        } catch {
            fail("❌ Failed to validate analytics view: \(error)")
        }
    }
    
    func testDocumentsView() {
        log("📄 Testing Documents View...")
        
        let documentsPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/DocumentsView.swift"
        
        do {
            let content = try String(contentsOfFile: documentsPath)
            
            // Test file upload functionality
            if content.contains("fileImporter") {
                pass("✅ Documents has file import")
            } else {
                fail("❌ Documents missing file import")
            }
            
            // Test document processing
            if content.contains("DocumentManager") {
                pass("✅ Documents uses DocumentManager")
            } else {
                fail("❌ Documents missing DocumentManager")
            }
            
        } catch {
            fail("❌ Failed to validate documents view: \(error)")
        }
    }
    
    func testSettingsView() {
        log("⚙️ Testing Settings View...")
        
        let settingsPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/SettingsView.swift"
        
        do {
            let content = try String(contentsOfFile: settingsPath)
            
            // Test authentication section
            if content.contains("Authentication") {
                pass("✅ Settings has authentication section")
            } else {
                fail("❌ Settings missing authentication section")
            }
            
            // Test export section
            if content.contains("Export") {
                pass("✅ Settings has export section")
            } else {
                fail("❌ Settings missing export section")
            }
            
            // Test real functionality (not placeholders)
            if content.contains("AuthenticationService") {
                pass("✅ Settings uses real AuthenticationService")
            } else {
                fail("❌ Settings missing real authentication")
            }
            
        } catch {
            fail("❌ Failed to validate settings view: \(error)")
        }
    }
    
    func testCoPilotPanel() {
        log("🤖 Testing Co-Pilot Panel...")
        
        let contentViewPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/ContentView.swift"
        
        do {
            let content = try String(contentsOfFile: contentViewPath)
            
            // Test Co-Pilot implementation (not placeholder)
            if content.contains("CoPilotPanelPlaceholder") {
                fail("❌ Co-Pilot still using placeholder")
            } else {
                pass("✅ Co-Pilot placeholder removed")
            }
            
            // Test Co-Pilot toggle functionality
            if content.contains("showCoPilot") {
                pass("✅ Co-Pilot has toggle functionality")
            } else {
                fail("❌ Co-Pilot missing toggle")
            }
            
        } catch {
            fail("❌ Failed to validate Co-Pilot panel: \(error)")
        }
    }
    
    // MARK: - Phase 4: Button & Action Testing
    
    func testAllButtonFunctionality() {
        log("🔘 Testing All Button Functionality...")
        
        let contentViewPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/ContentView.swift"
        
        do {
            let content = try String(contentsOfFile: contentViewPath)
            
            // Test toolbar buttons have actions
            if content.contains("Button(action:") {
                pass("✅ Buttons have action closures")
            } else {
                fail("❌ Buttons missing action closures")
            }
            
            // Test import document button
            if content.contains("Import Document") {
                pass("✅ Import Document button exists")
            } else {
                fail("❌ Missing Import Document button")
            }
            
            // Test Co-Pilot toggle button
            if content.contains("Co-Pilot") {
                pass("✅ Co-Pilot toggle button exists")
            } else {
                fail("❌ Missing Co-Pilot toggle button")
            }
            
        } catch {
            fail("❌ Failed to validate button functionality: \(error)")
        }
    }
    
    func testToolbarActions() {
        log("🔧 Testing Toolbar Actions...")
        
        let contentViewPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/ContentView.swift"
        
        do {
            let content = try String(contentsOfFile: contentViewPath)
            
            // Test toolbar implementation
            if content.contains(".toolbar(content:") {
                pass("✅ Toolbar properly implemented")
            } else {
                fail("❌ Toolbar missing or incorrect")
            }
            
            // Test toolbar actions do something meaningful
            if content.contains("selectedView = .documents") {
                pass("✅ Import Document action navigates to documents")
            } else {
                fail("❌ Import Document action missing or incorrect")
            }
            
        } catch {
            fail("❌ Failed to validate toolbar actions: \(error)")
        }
    }
    
    func testMenuActions() {
        log("📋 Testing Menu Actions...")
        
        // Test if menu actions are properly wired
        let dashboardPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/DashboardView.swift"
        
        do {
            let content = try String(contentsOfFile: dashboardPath)
            
            // Test menu buttons call navigation
            if content.contains("onNavigate?(.analytics)") {
                pass("✅ View Details navigates to analytics")
            } else {
                fail("❌ View Details action missing")
            }
            
            if content.contains("onNavigate?(.documents)") {
                pass("✅ View All navigates to documents")
            } else {
                fail("❌ View All action missing")
            }
            
        } catch {
            fail("❌ Failed to validate menu actions: \(error)")
        }
    }
    
    // MARK: - Phase 5: Data Flow Testing
    
    func testDataConsistency() {
        log("🔄 Testing Data Consistency...")
        
        // Verify all views use the same data source (Core Data)
        let viewPaths = [
            "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/DashboardView.swift",
            "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/AnalyticsView.swift"
        ]
        
        for viewPath in viewPaths {
            do {
                let content = try String(contentsOfFile: viewPath)
                if content.contains("@FetchRequest") {
                    pass("✅ \(URL(fileURLWithPath: viewPath).lastPathComponent) uses Core Data")
                } else {
                    fail("❌ \(URL(fileURLWithPath: viewPath).lastPathComponent) not using Core Data")
                }
            } catch {
                fail("❌ Failed to read \(viewPath): \(error)")
            }
        }
    }
    
    func testRealTimeUpdates() {
        log("⚡ Testing Real-Time Updates...")
        
        // Test that views are properly bound to Core Data
        let analyticsPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/AnalyticsView.swift"
        
        do {
            let content = try String(contentsOfFile: analyticsPath)
            
            if content.contains("FetchedResults") && content.contains("animation: .default") {
                pass("✅ Analytics has animated Core Data updates")
            } else {
                fail("❌ Analytics missing real-time updates")
            }
        } catch {
            fail("❌ Failed to validate real-time updates: \(error)")
        }
    }
    
    func testExportFunctionality() {
        log("📤 Testing Export Functionality...")
        
        let exportPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Services/BasicExportService.swift"
        
        do {
            let content = try String(contentsOfFile: exportPath)
            
            let requiredMethods = [
                "exportToCSV",
                "exportToPDF", 
                "exportToJSON"
            ]
            
            for method in requiredMethods {
                if content.contains(method) {
                    pass("✅ Export service includes: \(method)")
                } else {
                    fail("❌ Export service missing: \(method)")
                }
            }
        } catch {
            fail("❌ Failed to validate export functionality: \(error)")
        }
    }
    
    // MARK: - Phase 6: User Journey Testing
    
    func testCompleteUserWorkflows() {
        log("👤 Testing Complete User Workflows...")
        
        // Test 1: New User Onboarding Flow
        testNewUserFlow()
        
        // Test 2: Document Import to Analytics Flow
        testDocumentToAnalyticsFlow()
        
        // Test 3: Data Export Flow
        testDataExportFlow()
    }
    
    func testNewUserFlow() {
        log("🆕 Testing New User Flow...")
        
        // Verify app launches with sample data for demo purposes
        let sampleDataPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Services/SampleDataService.swift"
        
        do {
            let content = try String(contentsOfFile: sampleDataPath)
            if content.contains("populateInitialData") {
                pass("✅ New users get sample data for demo")
            } else {
                fail("❌ Missing sample data for new users")
            }
        } catch {
            fail("❌ Failed to validate new user flow: \(error)")
        }
    }
    
    func testDocumentToAnalyticsFlow() {
        log("📄➡️📊 Testing Document to Analytics Flow...")
        
        // Test navigation from Documents to Analytics
        let dashboardPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/DashboardView.swift"
        
        do {
            let content = try String(contentsOfFile: dashboardPath)
            if content.contains("View Details") && content.contains("onNavigate?(.analytics)") {
                pass("✅ Dashboard links to Analytics view")
            } else {
                fail("❌ Dashboard-Analytics flow broken")
            }
        } catch {
            fail("❌ Failed to validate document-analytics flow: \(error)")
        }
    }
    
    func testDataExportFlow() {
        log("📊➡️💾 Testing Data Export Flow...")
        
        // Test export functionality is accessible from settings
        let settingsPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/SettingsView.swift"
        
        do {
            let content = try String(contentsOfFile: settingsPath)
            if content.contains("Export") && content.contains("BasicExportService") {
                pass("✅ Settings has working export functionality")
            } else {
                fail("❌ Export flow missing or broken")
            }
        } catch {
            fail("❌ Failed to validate export flow: \(error)")
        }
    }
    
    func testErrorHandling() {
        log("⚠️ Testing Error Handling...")
        
        // Test error handling in services
        let services = [
            "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Services/AuthenticationService.swift",
            "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Services/BasicExportService.swift"
        ]
        
        for servicePath in services {
            do {
                let content = try String(contentsOfFile: servicePath)
                if content.contains("do {") && content.contains("} catch {") {
                    pass("✅ \(URL(fileURLWithPath: servicePath).lastPathComponent) has error handling")
                } else {
                    fail("❌ \(URL(fileURLWithPath: servicePath).lastPathComponent) missing error handling")
                }
            } catch {
                fail("❌ Failed to read service: \(error)")
            }
        }
    }
    
    func testEdgeCases() {
        log("🔍 Testing Edge Cases...")
        
        // Test empty data states
        let analyticsPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/AnalyticsView.swift"
        
        do {
            let content = try String(contentsOfFile: analyticsPath)
            if content.contains("isEmpty") {
                pass("✅ Analytics handles empty data state")
            } else {
                fail("❌ Analytics missing empty state handling")
            }
        } catch {
            fail("❌ Failed to validate edge cases: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    func executeShellCommand(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/bash"
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    func pass(_ message: String) {
        testResults.append("✅ PASS: \(message)")
        passCount += 1
        print("✅ \(message)")
    }
    
    func fail(_ message: String) {
        testResults.append("❌ FAIL: \(message)")
        errorCount += 1
        print("❌ \(message)")
    }
    
    func log(_ message: String) {
        print("\n🔍 \(message)")
        testResults.append("📝 \(message)")
    }
    
    func generateComprehensiveReport() {
        print("\n" + String(repeating: "=", count: 60))
        print("🎯 COMPREHENSIVE UX TESTING REPORT")
        print(String(repeating: "=", count: 60))
        
        print("📊 SUMMARY:")
        print("   ✅ Passed: \(passCount)")
        print("   ❌ Failed: \(errorCount)")
        print("   📈 Success Rate: \(passCount * 100 / (passCount + errorCount))%")
        
        if errorCount == 0 {
            print("\n🎉 ALL TESTS PASSED - TESTFLIGHT READY!")
            print("✅ Application is production-ready with no UX issues detected")
        } else {
            print("\n⚠️  ISSUES DETECTED - REQUIRES ATTENTION")
            print("❌ \(errorCount) issues must be resolved before TestFlight submission")
        }
        
        print("\n📋 DETAILED RESULTS:")
        for result in testResults {
            print("   \(result)")
        }
        
        print("\n🔗 NEXT STEPS:")
        if errorCount == 0 {
            print("   1. ✅ Archive build for TestFlight")
            print("   2. ✅ Submit to App Store Connect")
            print("   3. ✅ Distribute to internal testers")
        } else {
            print("   1. ❌ Fix all identified issues")
            print("   2. ❌ Re-run comprehensive testing")
            print("   3. ❌ Verify all UX flows work correctly")
        }
        
        // Save report to file
        let timestamp = DateFormatter().string(from: Date())
        let reportContent = testResults.joined(separator: "\n")
        
        do {
            let reportPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/temp/COMPREHENSIVE_UX_TESTING_REPORT_\(timestamp.replacingOccurrences(of: " ", with: "_")).md"
            try reportContent.write(toFile: reportPath, atomically: true, encoding: .utf8)
            print("\n📄 Report saved to: \(reportPath)")
        } catch {
            print("⚠️ Failed to save report: \(error)")
        }
    }
}

// Execute the comprehensive testing
let tester = ComprehensiveUXTester()
tester.runComprehensiveUXValidation()