// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  AnalyticsView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Analytics")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                
                Text("🧪 SANDBOX")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(6)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(6)
                    .padding()
            }
            
            Text("View your financial analytics and insights (SANDBOX)")
                .foregroundColor(.secondary)
        }
        .navigationTitle("Analytics")
    }
}

#Preview {
    AnalyticsView()
}