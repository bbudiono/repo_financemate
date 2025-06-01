//
//  AnalyticsView.swift
//  FinanceMate
//
//  Created by Assistant on 6/2/25.
//

import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        VStack {
            Text("Analytics")
                .font(.largeTitle)
                .padding()
            
            Text("View your financial analytics and insights")
                .foregroundColor(.secondary)
        }
        .navigationTitle("Analytics")
    }
}

#Preview {
    AnalyticsView()
}