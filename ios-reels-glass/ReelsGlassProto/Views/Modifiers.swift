import SwiftUI

extension View {
    func glassPanel(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(
                GlassBackground()
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
    }
}
