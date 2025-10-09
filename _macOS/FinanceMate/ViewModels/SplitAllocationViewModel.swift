import CoreData
import Foundation
import SwiftUI

/*
 * Purpose: Refactored SplitAllocationViewModel complying with <200 lines KISS principle
 * Last Updated: 2025-10-04
 */

struct SplitAllocationData {
    var percentage = 0.0
    var taxCategory = ""
}

enum QuickSplitType {
    case fiftyFifty
    case seventyThirty
}

final class SplitAllocationViewModel: ObservableObject {

    @Published var splitAllocations: [SplitAllocation] = []
    @Published var newSplitPercentage = 0.0
    @Published var selectedTaxCategory = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var customCategories: [String] = []

    var totalPercentage: Double {
        calculationService.calculateTotalPercentage(from: splitAllocations)
    }

    var isValidSplit: Bool {
        validationService.isValidSplitTotal(totalPercentage)
    }

    var remainingPercentage: Double {
        calculationService.calculateRemainingPercentage(for: splitAllocations)
    }

    var predefinedCategories: [String] {
        SplitAllocationTaxCategoryService.predefinedCategories
    }

    var availableTaxCategories: [String] {
        taxCategoryService.getAllAvailableCategories(customCategories: customCategories)
    }

    private let dataService: SplitAllocationDataService
    private let validationService: SplitAllocationValidationService
    private let taxCategoryService: SplitAllocationTaxCategoryService
    private let calculationService: SplitAllocationCalculationService

    init(context: NSManagedObjectContext) {
        self.dataService = SplitAllocationDataService(context: context)
        self.validationService = SplitAllocationValidationService()
        self.taxCategoryService = SplitAllocationTaxCategoryService()
        self.calculationService = SplitAllocationCalculationService()

        if !predefinedCategories.isEmpty {
            selectedTaxCategory = predefinedCategories[0]
        }
    }

      // MARK: - Operations

    func addSplitAllocation(to lineItem: LineItem) async {
        guard let cleanCategory = SplitAllocationHelpers.prepareCategory(selectedTaxCategory, taxCategoryService: taxCategoryService),
              validateAndCreateSplit(cleanCategory, lineItem: lineItem) else { return }
        newSplitPercentage = 0.0
        await fetchSplitAllocations(for: lineItem)
    }

    func updateSplitAllocation(_ splitAllocation: SplitAllocation) async {
        guard validationService.validatePercentage(splitAllocation.percentage) else {
            errorMessage = "Invalid percentage value"
            return
        }
        isLoading = true
        await handleResult(dataService.updateSplitAllocation(splitAllocation))
    }

    func deleteSplitAllocation(_ splitAllocation: SplitAllocation) async {
        isLoading = true
        await handleResult(dataService.deleteSplitAllocation(splitAllocation))
    }

    func fetchSplitAllocations(for lineItem: LineItem) async {
        splitAllocations = dataService.fetchSplitAllocations(for: lineItem)
    }

    func validateNewSplitAllocation() -> Bool {
        let result = SplitAllocationHelpers.validateNewSplit(
            existingAllocations: splitAllocations,
            newPercentage: newSplitPercentage,
            validationService: validationService
        )
        if !result.isValid { errorMessage = result.errorMessage }
        return result.isValid
    }

    func validatePercentage(_ percentage: Double) -> Bool {
        validationService.validatePercentage(percentage)
    }

    func validateLineItemSplitTotal(for lineItem: LineItem) -> Bool {
        calculationService.validateLineItemSplitTotal(for: lineItem)
    }

    func addCustomTaxCategory(_ categoryName: String) {
        let result = SplitAllocationHelpers.addCustomCategory(categoryName, to: customCategories, taxCategoryService: taxCategoryService)
        if result.isSuccess, let updatedCategories = result.categories {
            customCategories = updatedCategories
        } else {
            errorMessage = result.errorMessage
        }
    }

    func removeCustomTaxCategory(_ categoryName: String) {
        let result = SplitAllocationHelpers.removeCustomCategory(categoryName, from: customCategories, taxCategoryService: taxCategoryService)
        if result.isSuccess, let updatedCategories = result.categories {
            customCategories = updatedCategories
        } else {
            errorMessage = result.errorMessage
        }
    }

    func applyQuickSplit(_ splitType: QuickSplitType, primaryCategory: String, secondaryCategory: String, to lineItem: LineItem) async {
        isLoading = true
        let result = dataService.applyQuickSplit(splitType, primaryCategory: primaryCategory, secondaryCategory: secondaryCategory, to: lineItem)
        await handleResult(result) { await fetchSplitAllocations(for: lineItem) }
    }

    func clearAllSplits(for lineItem: LineItem) async {
        isLoading = true
        let result = dataService.clearAllSplits(for: lineItem)
        await handleResult(result) { await fetchSplitAllocations(for: lineItem) }
    }

    func formatPercentage(_ percentage: Double) -> String {
        calculationService.formatPercentage(percentage)
    }

    func calculateAmount(for percentage: Double, of lineItem: LineItem) -> Double {
        calculationService.calculateAllocatedAmount(for: percentage, of: lineItem)
    }

    func formatCurrency(_ amount: Double) -> String {
        calculationService.formatCurrency(amount)
    }

    private func validateAndCreateSplit(_ cleanCategory: String, lineItem: LineItem) -> Bool {
        let validationResult = SplitAllocationHelpers.validateNewSplit(
            existingAllocations: splitAllocations,
            newPercentage: newSplitPercentage,
            validationService: validationService
        )
        guard validationResult.isValid else {
            errorMessage = validationResult.errorMessage
            return false
        }
        isLoading = true
        let result = dataService.createSplitAllocation(percentage: newSplitPercentage, taxCategory: cleanCategory, lineItem: lineItem)
        Task { await handleResult(result) }
        return result.isSuccess
    }

    private func handleResult(_ result: SplitAllocationDataService.SplitAllocationResult, onSuccess: (() async -> Void)? = nil) async {
        if result.isSuccess { await onSuccess?() } else { errorMessage = result.errorMessage }
        isLoading = false
    }
}

// MARK: - SplitAllocationDataService Result Extension
extension SplitAllocationDataService.SplitAllocationResult {
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .error:
            return false
        }
    }

    var errorMessage: String? {
        switch self {
        case .success:
            return nil
        case .error(let message):
            return message
        }
    }
}