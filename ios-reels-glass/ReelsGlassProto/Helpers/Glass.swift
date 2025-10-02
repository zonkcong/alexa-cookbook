import SwiftUI

struct GlassBackground: View {
    enum Style { case dark, light }
    var style: Style = .dark
    var opacity: CGFloat = 0.7

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(tintColor.opacity(opacity))
                    .blur(radius: 24)
                    .saturation(1.8)
                    .brightness(-0.1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .blendMode(.overlay)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                    .blur(radius: 1)
                    .offset(y: -1)
                    .mask(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
            )
    }

    private var tintColor: Color {
        switch style {
        case .dark: return Color(red: 16/255, green: 16/255, blue: 20/255)
        case .light: return Color.white
        }
    }
}

struct GlassChip: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.black.opacity(0.6))
                            .blur(radius: 24)
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func glassChip() -> some View { modifier(GlassChip()) }
}
