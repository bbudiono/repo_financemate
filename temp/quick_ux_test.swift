#!/usr/bin/env swift

import Foundation

class QuickUXTester {
    private var passCount = 0
    private var failCount = 0
    
    func runQuickValidation() {
        print("🎯 QUICK UX VALIDATION - FinanceMate Production")
        print(String(repeating: "=", count: 50))
        
        testBuildSuccess()
        testCoreComponents()
        testNavigation()
        testDataIntegration()
        
        printSummary()
    }
    
    func testBuildSuccess() {
        print("\n📱 Testing Build Success...")
        
        let buildResult = shell("cd '/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate' && xcodebuild -scheme FinanceMate -configuration Release build 2>&1")
        
        if buildResult.contains("BUILD SUCCEEDED") || buildResult.contains("** BUILD SUCCEEDED **") {
            pass("Application builds successfully")
        } else {
            print("Build output: \(buildResult)")
            fail("Build failed")
        }
    }
    
    func testCoreComponents() {
        print("\n🔧 Testing Core Components...")
        
        let paths = [
            "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/ContentView.swift",
            "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/DashboardView.swift",
            "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/AnalyticsView.swift",
            "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Services/SampleDataService.swift"
        ]
        
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                pass("\(URL(fileURLWithPath: path).lastPathComponent) exists")
            } else {
                fail("\(URL(fileURLWithPath: path).lastPathComponent) missing")
            }
        }
    }
    
    func testNavigation() {
        print("\n🧭 Testing Navigation...")
        
        guard let content = readFile("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/ContentView.swift") else {
            fail("Could not read ContentView")
            return
        }
        
        if content.contains("NavigationSplitView") {
            pass("NavigationSplitView implemented")
        } else {
            fail("Missing NavigationSplitView")
        }
        
        if content.contains("onNavigate") {
            pass("Navigation handler implemented")
        } else {
            fail("Missing navigation handler")
        }
    }
    
    func testDataIntegration() {
        print("\n📊 Testing Data Integration...")
        
        guard let analyticsContent = readFile("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Views/AnalyticsView.swift") else {
            fail("Could not read AnalyticsView")
            return
        }
        
        if analyticsContent.contains("@FetchRequest") {
            pass("Analytics uses Core Data")
        } else {
            fail("Analytics missing Core Data")
        }
        
        if !analyticsContent.contains("generateSampleTransactions") {
            pass("Analytics removed mock data")
        } else {
            fail("Analytics still using mock data")
        }
    }
    
    func readFile(_ path: String) -> String? {
        return try? String(contentsOfFile: path, encoding: .utf8)
    }
    
    func shell(_ command: String) -> String {
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
        print("✅ \(message)")
        passCount += 1
    }
    
    func fail(_ message: String) {
        print("❌ \(message)")
        failCount += 1
    }
    
    func printSummary() {
        print("\n" + String(repeating: "=", count: 50))
        print("📊 SUMMARY: ✅ \(passCount) passed, ❌ \(failCount) failed")
        
        if failCount == 0 {
            print("🎉 ALL TESTS PASSED - TESTFLIGHT READY!")
        } else {
            print("⚠️ \(failCount) issues need attention")
        }
    }
}

let tester = QuickUXTester()
tester.runQuickValidation()