import SwiftUI

/// BLUEPRINT MANDATORY: Unified Navigation Sidebar
/// Requirements: Section 3.1.1.7 - Replace TabView with persistent left-hand navigation sidebar
/// Provides persistent, left-hand navigation with active states and high-quality icons
struct NavigationSidebar: View {
    /// Binding for the currently selected navigation item
    @Binding var selectedTab: Int

    /// Navigation items configuration
    private let navigationItems: [NavigationItem] = [
        NavigationItem(title: "Dashboard", iconName: "chart.bar.fill"),
        NavigationItem(title: "Transactions", iconName: "list.bullet"),
        NavigationItem(title: "Gmail", iconName: "envelope.fill"),
        NavigationItem(title: "Settings", iconName: "gearshape.fill")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Navigation header
            VStack(alignment: .leading, spacing: 8) {
                Text("FinanceMate")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Personal Wealth Management")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)

            // Navigation items
            VStack(spacing: 4) {
                ForEach(0..<navigationItems.count, id: \.self) { index in
                    NavigationItemView(
                        item: navigationItems[index],
                        isSelected: selectedTab == index,
                        action: {
                            selectedTab = index
                        }
                    )
                }
            }

            Spacer()

            // Footer
            VStack(alignment: .leading, spacing: 4) {
                Text("Version 1.0.0")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(width: 240)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .trailing
        )
    }
}

/// Individual navigation item view with active state styling
private struct NavigationItemView: View {
    let item: NavigationItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: item.iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(width: 20, height: 20)

                // Title
                Text(item.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                .padding(.horizontal, 8)
        )
    }
}

/// Navigation item model for sidebar configuration
struct NavigationItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let iconName: String

    static func == (lhs: NavigationItem, rhs: NavigationItem) -> Bool {
        return lhs.id == rhs.id
    }
}

#Preview {
    NavigationSidebar(selectedTab: .constant(0))
}