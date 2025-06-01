//
//  DocumentsView.swift
//  FinanceMate
//
//  Created by Assistant on 6/2/25.
//

import SwiftUI

struct DocumentsView: View {
    var body: some View {
        VStack {
            Text("Documents")
                .font(.largeTitle)
                .padding()
            
            Text("Manage your financial documents")
                .foregroundColor(.secondary)
        }
        .navigationTitle("Documents")
    }
}

#Preview {
    DocumentsView()
}