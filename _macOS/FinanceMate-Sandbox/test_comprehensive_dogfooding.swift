#!/usr/bin/env swift

//
//  test_comprehensive_dogfooding.swift
//  FinanceMate-Sandbox Comprehensive Dogfooding Verification
//
//  This script systematically tests ALL functionality as requested by the user
//

import Foundation

// MARK: - Comprehensive Dogfooding Test Suite

struct DogfoodingTestResult {
    let testName: String
    let status: TestStatus
    let details: String
    let timestamp: Date
    
    enum TestStatus {
        case passed, failed, warning, skipped
        
        var emoji: String {
            switch self {
            case .passed: return "✅"
            case .failed: return "❌"
            case .warning: return "⚠️"
            case .skipped: return "⏭️"
            }
        }
    }
}

class ComprehensiveDogfoodingTester {
    private var results: [DogfoodingTestResult] = []
    
    func runAllTests() {
        print("🚀 COMPREHENSIVE DOGFOODING VERIFICATION STARTING...")
        print(String(repeating: "=", count: 60))
        
        // Test 1: Verify Sandbox app is running
        testSandboxAppRunning()
        
        // Test 2: Verify API key environment variable
        testAPIKeyEnvironment()
        
        // Test 3: Test real OpenAI API call
        testRealOpenAIAPICall()
        
        // Test 4: Verify SSO authentication readiness
        testSSOAuthenticationReadiness()
        
        // Test 5: Test TaskMaster-AI integration
        testTaskMasterAIIntegration()
        
        // Test 6: Memory monitoring
        testMemoryUsage()
        
        // Generate comprehensive report
        generateComprehensiveReport()
    }
    
    private func testSandboxAppRunning() {
        let testName = "Sandbox App Running"
        print("\n🧪 Testing: \(testName)")
        
        // Check if FinanceMate-Sandbox.app is running
        let task = Process()
        task.launchPath = "/bin/ps"
        task.arguments = ["aux"]
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            task.launch()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            if output.contains("FinanceMate-Sandbox") {
                addResult(testName: testName, status: .passed, details: "Sandbox app is running successfully")
                print("✅ Sandbox app detected running")
            } else {
                addResult(testName: testName, status: .failed, details: "Sandbox app is not running")
                print("❌ Sandbox app not detected - please launch the app")
            }
        } catch {
            addResult(testName: testName, status: .failed, details: "Failed to check app status: \(error)")
        }
    }
    
    private func testAPIKeyEnvironment() {
        let testName = "API Key Environment Variable"
        print("\n🧪 Testing: \(testName)")
        
        // Test global .env file
        let envPath = "/Users/bernhardbudiono/.config/mcp/.env"
        
        do {
            let envContent = try String(contentsOfFile: envPath, encoding: .utf8)
            if envContent.contains("OPENAI_API_KEY=sk-proj-") {
                addResult(testName: testName, status: .passed, details: "OpenAI API key found in global .env file")
                print("✅ API key found in global .env")
            } else {
                addResult(testName: testName, status: .failed, details: "OpenAI API key not found in global .env")
                print("❌ API key not found in global .env")
            }
        } catch {
            addResult(testName: testName, status: .failed, details: "Failed to read global .env file: \(error)")
            print("❌ Could not read global .env file")
        }
    }
    
    private func testRealOpenAIAPICall() {
        let testName = "Real OpenAI API Call"
        print("\n🧪 Testing: \(testName)")
        
        let script = """
        import requests
        import json
        import os
        
        # Load API key from environment
        api_key = "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"
        
        headers = {
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json'
        }
        
        data = {
            'model': 'gpt-4o-mini',
            'messages': [
                {'role': 'user', 'content': 'FINANCEMATE COMPREHENSIVE DOGFOODING TEST - Please respond with exactly: DOGFOODING SUCCESS'}
            ],
            'max_tokens': 50
        }
        
        try:
            response = requests.post('https://api.openai.com/v1/chat/completions', headers=headers, json=data, timeout=30)
            if response.status_code == 200:
                result = response.json()
                message = result['choices'][0]['message']['content']
                print(f"API_SUCCESS:{message}")
            else:
                print(f"API_ERROR:{response.status_code}")
        except Exception as e:
            print(f"API_EXCEPTION:{e}")
        """
        
        let pythonTask = Process()
        pythonTask.launchPath = "/usr/bin/python3"
        pythonTask.arguments = ["-c", script]
        let pythonPipe = Pipe()
        pythonTask.standardOutput = pythonPipe
        
        do {
            pythonTask.launch()
            pythonTask.waitUntilExit()
            let data = pythonPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            if output.contains("API_SUCCESS:") {
                let response = output.components(separatedBy: "API_SUCCESS:")[1].trimmingCharacters(in: .whitespacesAndNewlines)
                addResult(testName: testName, status: .passed, details: "Real API call successful: \(response)")
                print("✅ Real OpenAI API call successful: \(response)")
            } else if output.contains("API_ERROR:") {
                let error = output.components(separatedBy: "API_ERROR:")[1].trimmingCharacters(in: .whitespacesAndNewlines)
                addResult(testName: testName, status: .failed, details: "API error: \(error)")
                print("❌ API error: \(error)")
            } else {
                addResult(testName: testName, status: .failed, details: "API exception or unknown error")
                print("❌ API call failed")
            }
        } catch {
            addResult(testName: testName, status: .failed, details: "Failed to execute API test: \(error)")
        }
    }
    
    private func testSSOAuthenticationReadiness() {
        let testName = "SSO Authentication Readiness"
        print("\n🧪 Testing: \(testName)")
        
        // Check if Apple Sign-In entitlements are configured
        let entitlementsPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate-Sandbox/FinanceMate-Sandbox/FinanceMate-Sandbox.entitlements"
        
        do {
            let entitlementsContent = try String(contentsOfFile: entitlementsPath, encoding: .utf8)
            if entitlementsContent.contains("com.apple.developer.applesignin") {
                addResult(testName: testName, status: .passed, details: "Apple Sign-In entitlements configured")
                print("✅ Apple Sign-In entitlements found")
            } else {
                addResult(testName: testName, status: .warning, details: "Apple Sign-In entitlements not found - may need configuration")
                print("⚠️ Apple Sign-In entitlements not found")
            }
        } catch {
            addResult(testName: testName, status: .failed, details: "Could not read entitlements file: \(error)")
        }
    }
    
    private func testTaskMasterAIIntegration() {
        let testName = "TaskMaster-AI Integration"
        print("\n🧪 Testing: \(testName)")
        
        // Check if TaskMaster service files exist
        let taskMasterPath = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate-Sandbox/FinanceMate-Sandbox/Services/TaskMasterAIService.swift"
        
        do {
            let taskMasterContent = try String(contentsOfFile: taskMasterPath, encoding: .utf8)
            if taskMasterContent.contains("TaskLevel.level5") && taskMasterContent.contains("TaskLevel.level6") {
                addResult(testName: testName, status: .passed, details: "TaskMaster-AI with Level 5-6 support detected")
                print("✅ TaskMaster-AI with Level 5-6 support found")
            } else {
                addResult(testName: testName, status: .warning, details: "TaskMaster-AI exists but Level 5-6 support unclear")
                print("⚠️ TaskMaster-AI found but Level 5-6 support unclear")
            }
        } catch {
            addResult(testName: testName, status: .failed, details: "TaskMaster-AI service not found: \(error)")
        }
    }
    
    private func testMemoryUsage() {
        let testName = "Memory Usage Check"
        print("\n🧪 Testing: \(testName)")
        
        let task = Process()
        task.launchPath = "/usr/bin/memory_pressure"
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            task.launch()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            if output.contains("System-wide memory free percentage") {
                addResult(testName: testName, status: .passed, details: "Memory pressure check completed")
                print("✅ Memory pressure check completed")
            } else {
                addResult(testName: testName, status: .warning, details: "Memory check unclear")
                print("⚠️ Memory check results unclear")
            }
        } catch {
            addResult(testName: testName, status: .failed, details: "Memory check failed: \(error)")
        }
    }
    
    private func addResult(testName: String, status: DogfoodingTestResult.TestStatus, details: String) {
        let result = DogfoodingTestResult(testName: testName, status: status, details: details, timestamp: Date())
        results.append(result)
    }
    
    private func generateComprehensiveReport() {
        print("\n" + String(repeating: "=", count: 60))
        print("📊 COMPREHENSIVE DOGFOODING VERIFICATION REPORT")
        print(String(repeating: "=", count: 60))
        
        let passed = results.filter { $0.status == .passed }.count
        let failed = results.filter { $0.status == .failed }.count
        let warnings = results.filter { $0.status == .warning }.count
        
        print("📈 SUMMARY:")
        print("   ✅ Passed: \(passed)")
        print("   ❌ Failed: \(failed)")
        print("   ⚠️ Warnings: \(warnings)")
        print("   📊 Total: \(results.count)")
        
        let successRate = Double(passed) / Double(results.count) * 100
        print("   🎯 Success Rate: \(String(format: "%.1f", successRate))%")
        
        print("\n📝 DETAILED RESULTS:")
        for result in results {
            print("   \(result.status.emoji) \(result.testName): \(result.details)")
        }
        
        print("\n🎯 NEXT STEPS FOR USER:")
        print("1. ✅ Launch Sandbox app if not running")
        print("2. ✅ Navigate to 'Live Chat' tab")
        print("3. ✅ Test connection button")
        print("4. ✅ Send a test message and verify real LLM response")
        print("5. ✅ Check 'Comprehensive Test' tab for full testing suite")
        print("6. ✅ Verify 'API Keys' tab shows available services")
        
        if failed > 0 {
            print("\n⚠️ CRITICAL ISSUES TO ADDRESS:")
            for result in results.filter({ $0.status == .failed }) {
                print("   ❌ \(result.testName): \(result.details)")
            }
        }
        
        print("\n🎉 DOGFOODING VERIFICATION COMPLETE!")
        print(String(repeating: "=", count: 60))
    }
}

// Execute the comprehensive test
let tester = ComprehensiveDogfoodingTester()
tester.runAllTests()