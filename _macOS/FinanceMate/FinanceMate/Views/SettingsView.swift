//
//  SettingsView.swift
//  FinanceMate
//
//  Created by Assistant on 6/2/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            
            Text("Configure your FinanceMate preferences")
                .foregroundColor(.secondary)
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}