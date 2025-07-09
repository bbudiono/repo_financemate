# SweetPad Debugging Guide for FinanceMate
**Version:** 1.0.0  
**Last Updated:** 2025-07-08  
**Status:** Production Ready

---

## 🎯 Overview

This guide provides comprehensive debugging workflows for FinanceMate development using SweetPad (VSCode Swift extension), offering enhanced debugging capabilities beyond traditional Xcode workflows.

## 🚀 Quick Start

### Prerequisites
- SweetPad VSCode extension installed
- Xcode Command Line Tools
- LLDB properly configured
- FinanceMate project workspace configured

### Launch Debugging Session
1. Open VSCode in the `_macOS` directory
2. Press `F5` or use Command Palette: `Debug: Start Debugging`
3. Select configuration:
   - **FinanceMate Production**: Full production environment debugging
   - **FinanceMate Sandbox**: Sandbox environment with watermark testing
   - **FinanceMate Performance Profile**: Release build with performance analysis

---

## 🔧 Debug Configurations

### Production Debug Configuration
```json
{
    "name": "FinanceMate Production",
    "type": "lldb",
    "request": "launch",
    "program": "${workspaceFolder}/build/Debug/FinanceMate.app/Contents/MacOS/FinanceMate",
    "environment": [
        { "name": "FINANCEMATE_ENV", "value": "PRODUCTION" }
    ]
}
```

**Use Cases:**
- Production bug reproduction
- Feature validation in production environment
- Performance debugging with production data

### Sandbox Debug Configuration
```json
{
    "name": "FinanceMate Sandbox",
    "type": "lldb", 
    "request": "launch",
    "program": "${workspaceFolder}/build/Debug/FinanceMate-Sandbox.app/Contents/MacOS/FinanceMate-Sandbox",
    "environment": [
        { "name": "FINANCEMATE_ENV", "value": "SANDBOX" }
    ]
}
```

**Use Cases:**
- New feature development
- Experimental functionality testing
- Safe testing with watermark identification

### Performance Debug Configuration
```json
{
    "name": "FinanceMate Performance Profile",
    "type": "lldb",
    "request": "launch", 
    "program": "${workspaceFolder}/build/Release/FinanceMate.app/Contents/MacOS/FinanceMate",
    "environment": [
        { "name": "INSTRUMENTS_PROFILING", "value": "1" }
    ]
}
```

**Use Cases:**
- Performance bottleneck identification
- Memory leak detection
- CPU usage optimization

---

## 🔍 Debugging Workflows

### 1. ViewModel Debugging

#### Setting Breakpoints in ViewModels
```swift
// In DashboardViewModel.swift
@MainActor
class DashboardViewModel: ObservableObject {
    @Published var totalBalance: Double = 0.0
    
    func calculateBalance() async {
        // Set breakpoint here for balance calculation debugging
        let transactions = await fetchTransactions()
        // Step through calculation logic
        totalBalance = transactions.reduce(0) { $0 + $1.amount }
    }
}
```

#### Debug Commands for ViewModels
```lldb
# Print current ViewModel state
(lldb) po self.totalBalance
(lldb) po self.transactions.count

# Examine @Published property changes
(lldb) watchpoint set variable totalBalance
(lldb) watchpoint set expression self.isLoading

# Debug async operations
(lldb) thread list
(lldb) thread select 1
(lldb) bt
```

### 2. Core Data Debugging

#### NSManagedObjectContext Debugging
```swift
// Set breakpoints in PersistenceController.swift
class PersistenceController {
    static let shared = PersistenceController()
    
    lazy var container: NSPersistentContainer = {
        // Debug Core Data stack initialization
        let container = NSPersistentContainer(name: "FinanceMate")
        container.loadPersistentStores { _, error in
            if let error = error {
                // Breakpoint: Core Data setup errors
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
}
```

#### Core Data Debug Commands
```lldb
# Examine managed object context
(lldb) po context.persistentStoreCoordinator
(lldb) po context.insertedObjects
(lldb) po context.deletedObjects
(lldb) po context.changedObjects

# Debug fetch requests
(lldb) po fetchRequest.predicate
(lldb) po fetchRequest.sortDescriptors

# Check entity relationships
(lldb) po transaction.lineItems
(lldb) po splitAllocation.lineItem
```

### 3. SwiftUI View Debugging

#### View State Debugging
```swift
// In TransactionsView.swift
struct TransactionsView: View {
    @StateObject private var viewModel = TransactionsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Set breakpoint for view updates
                List(viewModel.transactions) { transaction in
                    TransactionRowView(transaction: transaction)
                }
            }
        }
        .onAppear {
            // Debug view lifecycle
            Task {
                await viewModel.loadTransactions()
            }
        }
    }
}
```

#### SwiftUI Debug Commands
```lldb
# Examine view hierarchy
(lldb) po Mirror(reflecting: self).children
(lldb) po viewModel.transactions

# Debug state changes
(lldb) expr viewModel.isLoading = false
(lldb) po $0

# View modifier debugging
(lldb) po self.modifier(GlassmorphismModifier(.primary))
```

### 4. Glassmorphism UI Debugging

#### Modifier Debugging
```swift
// In GlassmorphismModifier.swift
struct GlassmorphismModifier: ViewModifier {
    let style: Style
    
    func body(content: Content) -> some View {
        content
            .background {
                // Debug glassmorphism rendering
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        // Breakpoint: Visual effect debugging
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderGradient, lineWidth: 1)
                    }
            }
    }
}
```

#### Visual Effect Debug Commands
```lldb
# Debug visual effects
(lldb) po style
(lldb) po borderGradient.stops

# Color debugging
(lldb) expr print(Color.accentColor)
(lldb) po Color.primary
```

---

## 🧪 Advanced Debugging Techniques

### 1. Memory Debugging

#### Memory Leak Detection
```lldb
# Enable malloc stack logging
(lldb) env MallocStackLogging=1

# Check for memory leaks
(lldb) malloc_info --stack-history 0x123456789
(lldb) heap --addresses-for-type Transaction

# Monitor memory usage
(lldb) memory read --size 8 --format x --count 16 0x123456789
```

#### Instruments Integration
```bash
# Launch with Memory Graph debugger
instruments -t "Allocations" /path/to/FinanceMate.app

# Time Profiler for performance analysis
instruments -t "Time Profiler" /path/to/FinanceMate.app
```

### 2. Async/Await Debugging

#### Task Debugging
```swift
// Debug async ViewModel operations
@MainActor
class TransactionsViewModel: ObservableObject {
    func loadTransactions() async {
        // Set breakpoint for async debugging
        do {
            let transactions = try await dataService.fetchTransactions()
            // Debug task context
            await MainActor.run {
                self.transactions = transactions
            }
        } catch {
            // Debug error handling
            print("Error loading transactions: \(error)")
        }
    }
}
```

#### Async Debug Commands
```lldb
# List all tasks
(lldb) task list

# Debug task state
(lldb) task info 0x123456789
(lldb) po await transaction.description

# Actor debugging
(lldb) po await MainActor.shared
```

### 3. Performance Profiling

#### CPU Usage Debugging
```lldb
# Profile CPU usage
(lldb) settings set target.process.thread.step-avoid-regexp ^std::
(lldb) thread backtrace --count 20

# Time sensitive operations
(lldb) expr CFAbsoluteTimeGetCurrent()
```

#### Memory Usage Monitoring
```lldb
# Check memory footprint
(lldb) memory read --outfile /tmp/memory_dump.txt 0x0 0x1000
(lldb) process status

# Debug memory pressure
(lldb) expr vm_pressure_monitor_start()
```

---

## 🔧 Troubleshooting Common Issues

### 1. Build Failures in SweetPad

#### Xcode Build Server Issues
```bash
# Regenerate build server configuration
cd _macOS
xcode-build-server config -workspace FinanceMate.xcworkspace -scheme FinanceMate

# Restart VSCode and language server
killall sourcekit-lsp
code --reload-window
```

#### Missing Symbols
```lldb
# Load symbols manually
(lldb) target symbols add /path/to/FinanceMate.app.dSYM

# Check symbol loading
(lldb) image list FinanceMate
(lldb) image lookup --type Transaction
```

### 2. Core Data Context Issues

#### Context Debugging
```lldb
# Check context state
(lldb) po context.hasChanges
(lldb) po context.concurrencyType

# Reset context if needed
(lldb) expr context.reset()
(lldb) expr try! context.save()
```

### 3. SwiftUI Update Issues

#### State Update Debugging
```lldb
# Force UI update
(lldb) expr await MainActor.run { viewModel.objectWillChange.send() }

# Check Publisher state
(lldb) po viewModel.$transactions
(lldb) po viewModel.$isLoading
```

---

## 📊 Debug Metrics and Monitoring

### Performance Metrics
- **Build Time**: Target <120 seconds for full rebuild
- **Launch Time**: Target <3 seconds for app launch
- **Memory Usage**: Target <200MB for typical operation
- **CPU Usage**: Target <20% during idle state

### Key Performance Indicators
```swift
// Add performance monitoring to ViewModels
private func measurePerformance<T>(operation: () async throws -> T) async rethrows -> T {
    let startTime = CFAbsoluteTimeGetCurrent()
    defer {
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Operation completed in \(timeElapsed) seconds")
    }
    return try await operation()
}
```

---

## 🔗 Integration with Existing Workflow

### Xcode Compatibility
- SweetPad and Xcode can be used interchangeably
- Debugging sessions can be transferred between tools
- Build artifacts are compatible across both environments

### Git Integration
- Debug configurations are version controlled
- Team members can share debugging setups
- Breakpoints and debug settings sync across devices

### CI/CD Integration
```yaml
# GitHub Actions debug build validation
- name: Debug Build Validation
  run: |
    cd _macOS
    xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate -configuration Debug build
    # Additional debug validation steps
```

---

## 📚 Additional Resources

### Documentation
- [Apple Developer Documentation - Debugging](https://developer.apple.com/documentation/xcode/debugging)
- [LLDB Quick Start Guide](https://lldb.llvm.org/use/tutorial.html)
- [SweetPad Extension Documentation](https://marketplace.visualstudio.com/items?itemName=SweetPad.sweetpad)

### Team Training
- Regular debugging workshop sessions
- Best practices documentation
- Debug scenario playbooks

---

## 🎯 Success Metrics

### Debug Efficiency
- **Issue Resolution Time**: Target 50% reduction with SweetPad
- **Debug Session Setup**: Target <30 seconds
- **Breakpoint Accuracy**: Target 95% hit rate
- **Memory Leak Detection**: Target 100% leak identification

### Team Adoption
- **Developer Satisfaction**: Target >90% positive feedback
- **Tool Usage**: Target 80% of debugging sessions using SweetPad
- **Knowledge Transfer**: Target 100% team proficiency within 30 days

---

*Last updated: 2025-07-08 - SweetPad Advanced Debug Configuration Complete*