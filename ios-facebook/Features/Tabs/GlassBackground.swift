import SwiftUI

struct GlassBackground: View {
    var body: some View {
        ZStack {
            // Base gradient with Facebook blue and white tones
            LinearGradient(
                colors: [Color("FacebookBlue").opacity(0.15), .white.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Subtle bubbles for "liquid glass" feel
            Circle().fill(.ultraThinMaterial)
                .frame(width: 220, height: 220)
                .blur(radius: 24)
                .offset(x: -120, y: -240)

            Circle().fill(.ultraThinMaterial)
                .frame(width: 280, height: 280)
                .blur(radius: 30)
                .offset(x: 160, y: 260)
        }
    }
}
