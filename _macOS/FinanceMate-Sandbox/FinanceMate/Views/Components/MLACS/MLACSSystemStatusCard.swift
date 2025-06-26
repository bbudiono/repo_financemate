//
//  MLACSSystemStatusCard.swift
//  FinanceMate
//
//  Created by Assistant on 6/9/25.
//

/*
* Purpose: MLACS System Status Card Component
* Part of MLACSView refactoring following Manager pattern
* Displays system status information in a card format
*/

import SwiftUI

struct MLACSSystemStatusCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let details: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)

            if let details = details {
                Text(details)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

#Preview {
    MLACSSystemStatusCard(
        title: "System Status",
        value: "Operational",
        icon: "checkmark.circle.fill",
        color: .green,
        details: "All systems running normally"
    )
    .padding()
}
