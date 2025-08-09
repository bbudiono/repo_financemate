import Foundation
import OSLog

/// Interactive walkthrough management system
/// Focused responsibility: Orchestrate and manage interactive walkthroughs for financial workflows
// EMERGENCY FIX: Removed @MainActor to eliminate Swift Concurrency crashes
final class HelpWalkthroughManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var activeWalkthrough: InteractiveWalkthrough?
    @Published var currentWalkthroughStep: WalkthroughStep?
    
    // MARK: - Private Properties
    
    private let logger = Logger(subsystem: "com.financemate.help", category: "HelpWalkthroughManager")
    private var walkthroughProgress: [FinancialWorkflow: Int] = [:]
    
    // MARK: - Initialization
    
    init() {
        logger.debug("HelpWalkthroughManager initialized")
    }
    
    // MARK: - Walkthrough Creation
    
    /// Create an interactive walkthrough for a specific workflow
    func createInteractiveWalkthrough(for workflow: FinancialWorkflow, userLevel: ExpertiseLevel = .intermediate) -> InteractiveWalkthrough? {
        let steps = WalkthroughStepGenerator.generateSteps(for: workflow)
        guard !steps.isEmpty else { return nil }
        
        let walkthrough = InteractiveWalkthrough(
            workflow: workflow,
            title: WorkflowMetadataProvider.getTitle(for: workflow),
            description: WorkflowMetadataProvider.getDescription(for: workflow),
            steps: steps,
            estimatedDuration: WorkflowMetadataProvider.getEstimatedDuration(for: workflow, stepCount: steps.count),
            targetUserLevel: userLevel
        )
        
        activeWalkthrough = walkthrough
        currentWalkthroughStep = steps.first
        
        logger.info("Interactive walkthrough created for workflow: \(workflow.rawValue)")
        return walkthrough
    }
    
    /// Advance to the next step in the current walkthrough
    func advanceWalkthroughStep() {
        guard let walkthrough = activeWalkthrough,
              let currentStep = currentWalkthroughStep else { return }
        
        let currentIndex = walkthrough.steps.firstIndex { $0.stepNumber == currentStep.stepNumber } ?? 0
        let nextIndex = currentIndex + 1
        
        if nextIndex < walkthrough.steps.count {
            currentWalkthroughStep = walkthrough.steps[nextIndex]
        } else {
            // Walkthrough completed
            walkthroughProgress[walkthrough.workflow] = walkthrough.steps.count
            activeWalkthrough = nil
            currentWalkthroughStep = nil
            logger.info("Walkthrough completed for workflow: \(walkthrough.workflow.rawValue)")
        }
    }
    
    /// Get the current walkthrough step
    func getCurrentWalkthroughStep() -> WalkthroughStep? {
        return currentWalkthroughStep
    }
    
    /// Check if a walkthrough has been completed
    func isWalkthroughCompleted(_ workflow: FinancialWorkflow) -> Bool {
        return walkthroughProgress[workflow] != nil
    }
    
    /// Reset walkthrough progress for a specific workflow
    func resetWalkthroughProgress(for workflow: FinancialWorkflow) {
        walkthroughProgress.removeValue(forKey: workflow)
        logger.debug("Walkthrough progress reset for workflow: \(workflow.rawValue)")
    }
    
    /// End the current walkthrough
    func endCurrentWalkthrough() {
        if let walkthrough = activeWalkthrough {
            logger.info("Walkthrough ended manually for workflow: \(walkthrough.workflow.rawValue)")
        }
        activeWalkthrough = nil
        currentWalkthroughStep = nil
    }
    
}