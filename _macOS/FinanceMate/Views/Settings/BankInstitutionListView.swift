import SwiftUI

/*
 * Purpose: Institution selection component for bank connection workflow
 * Issues & Complexity Summary: Search functionality, institution filtering, list display
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~100
 *   - Core Algorithm Complexity: Medium (search/filter logic)
 *   - Dependencies: SwiftUI, BasiqAPIService, BasiqInstitution
 *   - State Management Complexity: Medium (search state, filtering)
 *   - Novelty/Uncertainty Factor: Low (standard list with search)
 * AI Pre-Task Self-Assessment: 92%
 * Problem Estimate: 70%
 * Initial Code Complexity Estimate: 72%
 * Final Code Complexity: 75%
 * Overall Result Score: 95%
 * Key Variances/Learnings: Efficient search implementation with lazy loading
 * Last Updated: 2025-10-07
 */

struct BankInstitutionListView: View {
  @ObservedObject var basiqService: BasiqAPIService
  let onInstitutionSelected: (BasiqInstitution) -> Void

  @State private var searchText = ""

  var filteredInstitutions: [BasiqInstitution] {
    if searchText.isEmpty {
      return basiqService.availableInstitutions
    } else {
      return basiqService.availableInstitutions.filter { institution in
        institution.name.localizedCaseInsensitiveContains(searchText)
          || institution.shortName.localizedCaseInsensitiveContains(searchText)
      }
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      // Search bar
      searchBarView

      // Institutions list or empty state
      if basiqService.availableInstitutions.isEmpty {
        loadingView
      } else if filteredInstitutions.isEmpty {
        emptyStateView
      } else {
        institutionsListView
      }
    }
  }

  // MARK: - Search Bar

  private var searchBarView: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.secondary)

      TextField("Search banks and institutions...", text: $searchText)
        .textFieldStyle(.plain)

      if !searchText.isEmpty {
        Button("Clear") {
          searchText = ""
        }
        .font(.caption)
        .foregroundColor(.blue)
      }
    }
    .padding()
    .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
    .padding(.horizontal)
    .padding(.bottom)
  }

  // MARK: - Loading View

  private var loadingView: some View {
    VStack(spacing: 16) {
      ProgressView()
        .scaleEffect(1.2)

      Text("Loading available institutions...")
        .font(.body)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
  }

  // MARK: - Empty State View

  private var emptyStateView: some View {
    VStack(spacing: 16) {
      Image(systemName: "magnifyingglass.circle")
        .font(.system(size: 48))
        .foregroundColor(.secondary)

      Text("No institutions found")
        .font(.title3)
        .fontWeight(.medium)

      Text("Try adjusting your search terms")
        .font(.body)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
  }

  // MARK: - Institutions List View

  private var institutionsListView: some View {
    ScrollView {
      LazyVStack(spacing: 8) {
        // Priority banks first (ANZ, NAB as per BLUEPRINT)
        if searchText.isEmpty {
          let priorityBanks = filteredInstitutions.filter { institution in
            institution.name.localizedCaseInsensitiveContains("ANZ") ||
            institution.name.localizedCaseInsensitiveContains("NAB")
          }

          if !priorityBanks.isEmpty {
            Text("Popular Banks")
              .font(.headline)
              .fontWeight(.semibold)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal)
              .padding(.top)

            ForEach(priorityBanks) { institution in
              BankInstitutionRowView(institution: institution) {
                onInstitutionSelected(institution)
              }
            }

            Divider()
              .padding(.vertical)

            Text("All Institutions")
              .font(.headline)
              .fontWeight(.semibold)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal)

            let otherBanks = filteredInstitutions.filter { institution in
              !institution.name.localizedCaseInsensitiveContains("ANZ") &&
              !institution.name.localizedCaseInsensitiveContains("NAB")
            }

            ForEach(otherBanks) { institution in
              BankInstitutionRowView(institution: institution) {
                onInstitutionSelected(institution)
              }
            }
          } else {
            // No priority banks found, show all
            ForEach(filteredInstitutions) { institution in
              BankInstitutionRowView(institution: institution) {
                onInstitutionSelected(institution)
              }
            }
          }
        } else {
          // Search results - no categorization
          ForEach(filteredInstitutions) { institution in
            BankInstitutionRowView(institution: institution) {
              onInstitutionSelected(institution)
            }
          }
        }
      }
      .padding(.horizontal)
    }
  }
}

// MARK: - Institution Row View

struct BankInstitutionRowView: View {
  let institution: BasiqInstitution
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 16) {
        // Institution icon
        institutionIconView

        VStack(alignment: .leading, spacing: 4) {
          Text(institution.name)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .multilineTextAlignment(.leading)

          HStack {
            Text(institution.institutionType.capitalized)
              .font(.caption)
              .foregroundColor(.secondary)

            if institution.authorization.adr {
              Text("• Open Banking")
                .font(.caption)
                .foregroundColor(.green)
            }
          }
        }

        Spacer()

        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .padding()
      .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
    }
    .buttonStyle(PlainButtonStyle())
    .accessibilityLabel("Connect to \(institution.name)")
  }

  private var institutionIconView: some View {
    RoundedRectangle(cornerRadius: 8)
      .fill(.blue.opacity(0.1))
      .frame(width: 48, height: 48)
      .overlay(
        Text(institution.shortName.prefix(2))
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(.blue)
      )
  }
}

// MARK: - Preview

struct BankInstitutionListView_Previews: PreviewProvider {
  static var previews: some View {
    BankInstitutionListView(basiqService: BasiqAPIService.preview) { _ in }
      .frame(height: 600)
  }
}