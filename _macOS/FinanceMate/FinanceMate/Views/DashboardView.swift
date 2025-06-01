//
//  DashboardView.swift
//  FinanceMate
//
//  Created by Assistant on 6/2/25.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack {
            Text("Dashboard")
                .font(.largeTitle)
                .padding()
            
            Text("Welcome to your financial dashboard")
                .foregroundColor(.secondary)
        }
        .navigationTitle("Dashboard")
    }
}

#Preview {
    DashboardView()
}