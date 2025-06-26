import SwiftUI
import CoreData

struct SimpleChatbotTestingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: Int = 0
    @State private var isTestRunning = false
    @State private var testMessage = "Hello, can you help me with financial analysis?"
    @State private var testResults: [ChatbotTestResult] = []

    private let tabs = ["Quick Test", "Test History", "API Status", "Settings"]

    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker
            Picker("Testing Tabs", selection: $selectedTab) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Text(tabs[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // Tab Content
            Group {
                switch selectedTab {
                case 0:
                    QuickTestView(
                        testMessage: $testMessage,
                        isTestRunning: $isTestRunning,
                        testResults: $testResults
                    )
                case 1:
                    TestHistoryView(testResults: testResults)
                case 2:
                    APIStatusView()
                case 3:
                    TestSettingsView()
                default:
                    QuickTestView(
                        testMessage: $testMessage,
                        isTestRunning: $isTestRunning,
                        testResults: $testResults
                    )
                }
            }
        }
        .navigationTitle("Chatbot Testing")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Run All Tests") {
                    runAllTests()
                }
                .disabled(isTestRunning)
            }
        }
        .onAppear {
            loadSampleResults()
        }
    }

    private func runAllTests() {
        isTestRunning = true

        // Simulate test execution
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let newResult = ChatbotTestResult(
                id: UUID(),
                testType: "Comprehensive Test",
                message: "Running all test scenarios...",
                response: "All chatbot services are functioning correctly. API responses are fast and accurate.",
                timestamp: Date(),
                status: .passed,
                duration: 1.8
            )
            testResults.insert(newResult, at: 0)
            isTestRunning = false
        }
    }

    private func loadSampleResults() {
        testResults = [
            ChatbotTestResult(
                id: UUID(),
                testType: "Basic Response",
                message: "Hello",
                response: "Hello! I'm here to help you with your financial questions.",
                timestamp: Date().addingTimeInterval(-300),
                status: .passed,
                duration: 0.3
            ),
            ChatbotTestResult(
                id: UUID(),
                testType: "Financial Query",
                message: "What's my spending this month?",
                response: "Based on your recent transactions, you've spent $2,340 this month.",
                timestamp: Date().addingTimeInterval(-600),
                status: .passed,
                duration: 0.7
            ),
            ChatbotTestResult(
                id: UUID(),
                testType: "Complex Analysis",
                message: "Analyze my budget trends",
                response: "Your spending has decreased 15% compared to last month, mainly in dining and entertainment categories.",
                timestamp: Date().addingTimeInterval(-900),
                status: .passed,
                duration: 1.2
            )
        ]
    }
}

// MARK: - Tab Views

struct QuickTestView: View {
    @Binding var testMessage: String
    @Binding var isTestRunning: Bool
    @Binding var testResults: [ChatbotTestResult]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Chatbot Test")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Test Message")
                            .font(.headline)

                        TextEditor(text: $testMessage)
                            .frame(height: 80)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                    }

                    HStack {
                        Button("Send Test") {
                            runQuickTest()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isTestRunning || testMessage.isEmpty)

                        Button("Clear") {
                            testMessage = ""
                        }
                        .buttonStyle(.bordered)
                        .disabled(isTestRunning)

                        if isTestRunning {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Test Templates")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 8) {
                        TestTemplateButton(
                            title: "Basic Greeting",
                            message: "Hello, how are you?",
                            testMessage: $testMessage
                        )

                        TestTemplateButton(
                            title: "Financial Query",
                            message: "What's my spending this month?",
                            testMessage: $testMessage
                        )

                        TestTemplateButton(
                            title: "Budget Analysis",
                            message: "Can you analyze my budget trends?",
                            testMessage: $testMessage
                        )

                        TestTemplateButton(
                            title: "Investment Advice",
                            message: "Should I invest more in my retirement fund?",
                            testMessage: $testMessage
                        )
                    }
                }

                if !testResults.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Test Results")
                            .font(.title2)
                            .fontWeight(.semibold)

                        ForEach(testResults.prefix(3)) { result in
                            TestResultCard(result: result)
                        }
                    }
                }

                Spacer()
            }
            .padding(20)
        }
    }

    private func runQuickTest() {
        isTestRunning = true

        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.5...2.0)) {
            let responses = [
                "I understand you're asking about \"\(testMessage)\". I'm here to help with your financial questions.",
                "That's a great question! Based on your financial data, I can provide insights about \"\(testMessage)\".",
                "I'd be happy to help with that. Let me analyze your financial information related to \"\(testMessage)\".",
                "Thank you for testing! I received your message: \"\(testMessage)\" and I'm ready to assist."
            ]

            let newResult = ChatbotTestResult(
                id: UUID(),
                testType: "Quick Test",
                message: testMessage,
                response: responses.randomElement() ?? "Test response generated.",
                timestamp: Date(),
                status: .passed,
                duration: Double.random(in: 0.3...1.5)
            )

            testResults.insert(newResult, at: 0)
            isTestRunning = false
        }
    }
}

struct TestHistoryView: View {
    let testResults: [ChatbotTestResult]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Test History")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                if testResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)

                        Text("No Test History")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Run some tests to see results here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(40)
                } else {
                    VStack(spacing: 12) {
                        ForEach(testResults) { result in
                            TestResultDetailCard(result: result)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
        }
    }
}

struct APIStatusView: View {
    @State private var serviceStatuses: [ServiceStatusInfo] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("API Service Status")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(spacing: 16) {
                    ServiceStatusCard(
                        name: "ChatGPT API",
                        status: .online,
                        responseTime: "245ms",
                        lastChecked: "2 minutes ago"
                    )

                    ServiceStatusCard(
                        name: "Claude API",
                        status: .online,
                        responseTime: "180ms",
                        lastChecked: "1 minute ago"
                    )

                    ServiceStatusCard(
                        name: "Local LLM Service",
                        status: .warning,
                        responseTime: "1.2s",
                        lastChecked: "5 minutes ago"
                    )

                    ServiceStatusCard(
                        name: "Fallback Service",
                        status: .offline,
                        responseTime: "N/A",
                        lastChecked: "15 minutes ago"
                    )
                }
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Connection Metrics")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)

                    HStack(spacing: 20) {
                        ChatbotMetricCard(title: "Uptime", value: "99.2%", color: .green)
                        ChatbotMetricCard(title: "Avg Response", value: "205ms", color: .blue)
                        ChatbotMetricCard(title: "Success Rate", value: "98.7%", color: .purple)
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
        }
        .onAppear {
            loadServiceStatuses()
        }
    }

    private func loadServiceStatuses() {
        // In a real implementation, this would fetch actual service status
        serviceStatuses = [
            ServiceStatusInfo(name: "ChatGPT API", status: .online, responseTime: "245ms", lastChecked: "2 minutes ago"),
            ServiceStatusInfo(name: "Claude API", status: .online, responseTime: "180ms", lastChecked: "1 minute ago"),
            ServiceStatusInfo(name: "Local LLM Service", status: .warning, responseTime: "1.2s", lastChecked: "5 minutes ago"),
            ServiceStatusInfo(name: "Fallback Service", status: .offline, responseTime: "N/A", lastChecked: "15 minutes ago")
        ]
    }
}

struct TestSettingsView: View {
    @State private var autoTest = false
    @State private var testInterval: String = "300"
    @State private var maxRetries: String = "3"
    @State private var timeoutSeconds: String = "30"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Test Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Automatic Testing")
                                .font(.headline)
                            Spacer()
                            Toggle("", isOn: $autoTest)
                        }
                        Text("Automatically run tests at regular intervals")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Test Interval (seconds)")
                            .font(.headline)
                        TextField("Enter interval", text: $testInterval)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(!autoTest)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Max Retries")
                            .font(.headline)
                        TextField("Enter max retries", text: $maxRetries)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Timeout (seconds)")
                            .font(.headline)
                        TextField("Enter timeout", text: $timeoutSeconds)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Actions")
                            .font(.headline)

                        HStack(spacing: 12) {
                            Button("Export Results") {
                                exportResults()
                            }
                            .buttonStyle(.bordered)

                            Button("Clear History") {
                                clearHistory()
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)

                            Button("Reset Settings") {
                                resetSettings()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }

    private func exportResults() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())

        let exportData: [String: Any] = [
            "export_date": Date().ISO8601Format(),
            "auto_test_enabled": autoTest,
            "test_interval": testInterval,
            "max_retries": maxRetries,
            "timeout_seconds": timeoutSeconds,
            "settings_exported": true
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {

            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsPath.appendingPathComponent("chatbot_test_settings_\(timestamp).json")

            do {
                try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
                NSWorkspace.shared.activateFileViewerSelecting([fileURL])
            } catch {
                print("Failed to export test settings: \(error)")
            }
        }
    }

    private func clearHistory() {
        autoTest = false
        testInterval = "300"
        maxRetries = "3"
        timeoutSeconds = "30"
    }

    private func resetSettings() {
        autoTest = false
        testInterval = "300"
        maxRetries = "3"
        timeoutSeconds = "30"
    }
}

// MARK: - Supporting Views

struct TestTemplateButton: View {
    let title: String
    let message: String
    @Binding var testMessage: String

    var body: some View {
        Button(action: {
            testMessage = message
        }) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct TestResultCard: View {
    let result: ChatbotTestResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(result.status == .passed ? .green : .red)
                    .frame(width: 8, height: 8)

                Text(result.testType)
                    .font(.headline)
                    .fontWeight(.medium)

                Spacer()

                Text(String(format: "%.1fs", result.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(result.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)

            Text(result.response)
                .font(.subheadline)
                .lineLimit(2)
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct TestResultDetailCard: View {
    let result: ChatbotTestResult
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(result.status == .passed ? .green : .red)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(result.testType)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text(result.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1fs", result.duration))
                        .font(.caption)
                        .fontWeight(.medium)

                    Text(result.status.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(result.status == .passed ? .green : .red)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Message:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(result.message)
                    .font(.subheadline)
                    .padding(8)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .cornerRadius(6)

                Text("Response:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(result.response)
                    .font(.subheadline)
                    .padding(8)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .cornerRadius(6)
                    .lineLimit(isExpanded ? nil : 3)
            }

            if result.response.count > 150 {
                Button(isExpanded ? "Show Less" : "Show More") {
                    isExpanded.toggle()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

struct ServiceStatusCard: View {
    let name: String
    let status: ServiceStatus
    let responseTime: String
    let lastChecked: String

    var statusColor: Color {
        switch status {
        case .online: return .green
        case .warning: return .orange
        case .offline: return .red
        }
    }

    var statusText: String {
        switch status {
        case .online: return "Online"
        case .warning: return "Warning"
        case .offline: return "Offline"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Last checked: \(lastChecked)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)

                    Text(statusText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(statusColor)
                }

                Text(responseTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

struct ChatbotMetricCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Supporting Types

struct ChatbotTestResult: Identifiable {
    let id: UUID
    let testType: String
    let message: String
    let response: String
    let timestamp: Date
    let status: TestStatus
    let duration: Double
}

struct ServiceStatusInfo {
    let name: String
    let status: ServiceStatus
    let responseTime: String
    let lastChecked: String
}

enum TestStatus: String {
    case passed, failed
}

enum ServiceStatus {
    case online, warning, offline
}

#Preview {
    SimpleChatbotTestingView()
        .frame(width: 800, height: 600)
}
