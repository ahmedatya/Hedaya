import SwiftUI

// This file is reserved for any additional counter-related views or components
// The main counter logic is implemented in AzkarGroupView.swift

/// A reusable circular progress indicator
struct CircularProgressView: View {
    let progress: Double
    let colors: [Color]
    let lineWidth: CGFloat
    
    init(progress: Double, colors: [Color], lineWidth: CGFloat = 6) {
        self.progress = progress
        self.colors = colors
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
    }
}

#Preview {
    CircularProgressView(
        progress: 0.6,
        colors: [Color(hex: "1B7A4A"), Color(hex: "2ECC71")]
    )
    .frame(width: 120, height: 120)
}
