// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  SettingsView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Settings")
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
            
            Text("Configure your FinanceMate preferences (SANDBOX)")
                .foregroundColor(.secondary)
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}