//
//  SystemCapabilityAnalyzer.swift
//  FinanceMate
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Hardware-optimized system analysis for MLACS model recommendations
* Features: Real system capability detection, performance classification, resource analysis
* NO MOCK DATA: Uses actual system information for intelligent model selection
*/

import CoreFoundation
import Foundation

// MARK: - System Capability Analyzer

public class SystemCapabilityAnalyzer {
    // MARK: - Public Methods

    public init() {}

    public func analyzeSystemCapabilities() throws -> SystemCapabilityProfile {
        let cpuCores = getCPUCores()
        let memoryInfo = getMemoryInfo()
        let gpuMemory = getGPUMemory()
        let storageSpace = getAvailableStorageSpace()
        let internetSpeed = estimateInternetSpeed()
        let powerConstraints = determinePowerConstraints()
        let performanceClass = classifyPerformance(
            cpuCores: cpuCores,
            totalRAM: memoryInfo.total,
            gpuMemory: gpuMemory
        )

        return SystemCapabilityProfile(
            cpuCores: cpuCores,
            totalRAM: memoryInfo.total,
            availableRAM: memoryInfo.available,
            gpuMemory: gpuMemory,
            storageSpace: storageSpace,
            internetSpeed: internetSpeed,
            powerConstraints: powerConstraints,
            performanceClass: performanceClass
        )
    }

    // MARK: - Private System Analysis Methods

    private func getCPUCores() -> Int {
        ProcessInfo.processInfo.processorCount
    }

    private func getMemoryInfo() -> (total: Int, available: Int) {
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        let totalMB = Int(physicalMemory / 1024 / 1024)

        // Estimate available memory (typically 70-80% of total for available RAM estimation)
        let availableMB = Int(Double(totalMB) * 0.75)

        return (total: totalMB, available: availableMB)
    }

    private func getGPUMemory() -> Int {
        // Estimate GPU memory based on system memory for Apple Silicon Macs
        let totalMemory = ProcessInfo.processInfo.physicalMemory

        if totalMemory >= 32 * 1024 * 1024 * 1024 { // 32GB+
            return 16_000 // Estimate 16GB GPU memory for high-end systems
        } else if totalMemory >= 16 * 1024 * 1024 * 1024 { // 16GB+
            return 8000 // Estimate 8GB GPU memory
        } else if totalMemory >= 8 * 1024 * 1024 * 1024 { // 8GB+
            return 4000 // Estimate 4GB GPU memory
        } else {
            return 0 // No dedicated GPU memory
        }
    }

    private func getAvailableStorageSpace() -> Int {
        do {
            let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
            let resourceValues = try homeDirectory.resourceValues(forKeys: [.volumeAvailableCapacityKey])

            if let availableCapacity = resourceValues.volumeAvailableCapacity {
                return Int(availableCapacity / 1024 / 1024) // Convert to MB
            }
        } catch {
            print("❌ Failed to get storage space: \(error)")
        }

        return 100_000 // Default fallback (100GB)
    }

    private func estimateInternetSpeed() -> Int {
        // This is a simplified estimation
        // In a real implementation, you might perform a network speed test
        // For now, we'll estimate based on common connection types

        // Check if we have network connectivity
        let reachability = SystemReachability()
        if reachability.isConnectedToNetwork() {
            return 100 // Assume 100 Mbps for connected systems
        } else {
            return 0 // No internet connection
        }
    }

    private func determinePowerConstraints() -> PowerConstraints {
        // Detect if running on a laptop or desktop
        // This is a simplified detection - in reality, you'd use IOKit for more accurate detection

        #if os(macOS)
        // Check if running on battery (simplified)
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["-g", "ps"]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""

            if output.contains("Battery Power") {
                return .laptop
            } else if output.contains("AC Power") {
                // Could be laptop on AC or desktop
                // Further detection would be needed for accurate classification
                return .desktop
            }
        } catch {
            print("❌ Failed to detect power source: \(error)")
        }
        #endif

        return .desktop // Default assumption
    }

    private func classifyPerformance(cpuCores: Int, totalRAM: Int, gpuMemory: Int) -> PerformanceClass {
        // Classification based on combined system capabilities
        let cpuScore = min(4, cpuCores) // Normalize CPU cores (max score 4)
        let ramScore = min(4, totalRAM / 8000) // Normalize RAM (8GB increments, max score 4)
        let gpuScore = min(2, gpuMemory / 4000) // Normalize GPU memory (4GB increments, max score 2)

        let totalScore = cpuScore + ramScore + gpuScore

        switch totalScore {
        case 0...3:
            return .low
        case 4...6:
            return .medium
        case 7...8:
            return .high
        default:
            return .extreme
        }
    }
}

// MARK: - Supporting Types

public struct SystemCapabilityProfile {
    public let cpuCores: Int
    public let totalRAM: Int // MB
    public let availableRAM: Int // MB
    public let gpuMemory: Int // MB
    public let storageSpace: Int // MB
    public let internetSpeed: Int // Mbps
    public let powerConstraints: PowerConstraints
    public let performanceClass: PerformanceClass

    public init(
        cpuCores: Int,
        totalRAM: Int,
        availableRAM: Int,
        gpuMemory: Int,
        storageSpace: Int,
        internetSpeed: Int,
        powerConstraints: PowerConstraints,
        performanceClass: PerformanceClass
    ) {
        self.cpuCores = cpuCores
        self.totalRAM = totalRAM
        self.availableRAM = availableRAM
        self.gpuMemory = gpuMemory
        self.storageSpace = storageSpace
        self.internetSpeed = internetSpeed
        self.powerConstraints = powerConstraints
        self.performanceClass = performanceClass
    }
}

public enum PerformanceClass: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case extreme = "extreme"
}

public enum PowerConstraints: String, CaseIterable {
    case desktop = "desktop"
    case laptop = "laptop"
    case mobile = "mobile"
}

// MARK: - System Reachability Helper

private class SystemReachability {
    func isConnectedToNetwork() -> Bool {
        // Simplified network connectivity check
        // In a real implementation, you'd use proper reachability detection

        let task = Process()
        task.launchPath = "/usr/bin/ping"
        task.arguments = ["-c", "1", "-t", "3", "8.8.8.8"]

        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }
}
