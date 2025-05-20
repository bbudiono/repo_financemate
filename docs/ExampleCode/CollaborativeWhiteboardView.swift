// CollaborativeWhiteboardView.swift
// Advanced SwiftUI Example: Real-Time Collaborative Whiteboard
// Demonstrates a modular, production-quality whiteboard with simulated multi-user presence.
// Author: AI Agent (2025)
//
// Use case: Real-time collaborative drawing canvas for brainstorming, teaching, or design.
// Most challenging aspect: Real-time multi-user synchronization and conflict resolution (simulated here).

import SwiftUI

/// Represents a single stroke drawn by a user.
struct WhiteboardStroke: Identifiable, Equatable {
    let id = UUID()
    let userID: String
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
}

/// Simulated user presence for demonstration.
struct WhiteboardUser: Identifiable, Equatable {
    let id: String
    let name: String
    let color: Color
    var isActive: Bool
    var cursorPosition: CGPoint?
}

/// ViewModel for managing whiteboard state and simulated multi-user presence.
class CollaborativeWhiteboardViewModel: ObservableObject {
    @Published var strokes: [WhiteboardStroke] = []
    @Published var users: [WhiteboardUser] = [
        .init(id: "user1", name: "Alice", color: .blue, isActive: true, cursorPosition: nil),
        .init(id: "user2", name: "Bob", color: .green, isActive: true, cursorPosition: nil),
        .init(id: "user3", name: "Carol", color: .orange, isActive: false, cursorPosition: nil)
    ]
    @Published var currentStroke: WhiteboardStroke? = nil
    @Published var localUserID: String = "user1" // Simulate current user
    
    // Simulate remote user cursor movement (for demo)
    func simulateRemoteUserActivity() {
        guard let remoteIndex = users.firstIndex(where: { $0.id == "user2" }) else { return }
        Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            let randomPoint = CGPoint(x: CGFloat.random(in: 50...450), y: CGFloat.random(in: 50...350))
            self.users[remoteIndex].cursorPosition = randomPoint
        }
    }
    
    func beginStroke(at point: CGPoint) {
        let user = users.first(where: { $0.id == localUserID }) ?? users[0]
        currentStroke = WhiteboardStroke(userID: user.id, points: [point], color: user.color, lineWidth: 3)
    }
    
    func appendPoint(_ point: CGPoint) {
        currentStroke?.points.append(point)
    }
    
    func endStroke() {
        if let stroke = currentStroke {
            strokes.append(stroke)
        }
        currentStroke = nil
    }
    
    func clearBoard() {
        strokes.removeAll()
    }
}

/// Main collaborative whiteboard view.
struct CollaborativeWhiteboardView: View {
    @StateObject private var viewModel = CollaborativeWhiteboardViewModel()
    @GestureState private var dragLocation: CGPoint? = nil
    
    var body: some View {
        ZStack {
            // Whiteboard background
            Rectangle()
                .fill(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 4)
                .overlay(
                    // Draw all strokes
                    ZStack {
                        ForEach(viewModel.strokes) { stroke in
                            Path { path in
                                guard let first = stroke.points.first else { return }
                                path.move(to: first)
                                for pt in stroke.points.dropFirst() {
                                    path.addLine(to: pt)
                                }
                            }
                            .stroke(stroke.color, lineWidth: stroke.lineWidth)
                        }
                        // Draw current stroke
                        if let stroke = viewModel.currentStroke {
                            Path { path in
                                guard let first = stroke.points.first else { return }
                                path.move(to: first)
                                for pt in stroke.points.dropFirst() {
                                    path.addLine(to: pt)
                                }
                            }
                            .stroke(stroke.color.opacity(0.7), style: StrokeStyle(lineWidth: stroke.lineWidth, dash: [4,2]))
                        }
                    }
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if viewModel.currentStroke == nil {
                                viewModel.beginStroke(at: value.location)
                            } else {
                                viewModel.appendPoint(value.location)
                            }
                        }
                        .onEnded { _ in
                            viewModel.endStroke()
                        }
                )
                .padding()
            
            // Multi-user presence: show cursors for all users
            ForEach(viewModel.users) { user in
                if let pos = user.cursorPosition, user.id != viewModel.localUserID, user.isActive {
                    UserCursorView(user: user, position: pos)
                }
            }
            // Local user cursor (optional, for demo)
            if let drag = dragLocation {
                if let user = viewModel.users.first(where: { $0.id == viewModel.localUserID }) {
                    UserCursorView(user: user, position: drag)
                }
            }
            
            // Toolbar
            VStack {
                HStack {
                    Text("Collaborative Whiteboard")
                        .font(.headline)
                        .padding(.leading)
                    Spacer()
                    Button(action: { viewModel.clearBoard() }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .padding(.trailing)
                }
                Spacer()
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .onAppear {
            viewModel.simulateRemoteUserActivity()
        }
    }
}

/// Visual representation of a user's cursor on the whiteboard.
struct UserCursorView: View {
    let user: WhiteboardUser
    let position: CGPoint
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "hand.point.up.left.fill")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(user.color)
                .background(Circle().fill(Color.white).shadow(radius: 2))
            Text(user.name)
                .font(.caption2)
                .foregroundColor(user.color)
                .padding(2)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.8)))
        }
        .position(position)
        .animation(.easeInOut(duration: 0.3), value: position)
    }
}

// MARK: - Preview
struct CollaborativeWhiteboardView_Previews: PreviewProvider {
    static var previews: some View {
        CollaborativeWhiteboardView()
            .frame(width: 600, height: 450)
            .previewDisplayName("Collaborative Whiteboard")
    }
} 