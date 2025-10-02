import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Circle().fill(Color.white.opacity(0.2)).frame(width: 88, height: 88)
                    Text("Creator Name")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)

                    HStack(spacing: 10) {
                        Button("Follow") {}.buttonStyle(.borderedProminent)
                        Button("Message") {}.buttonStyle(.bordered)
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(0..<30, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.black.ignoresSafeArea())
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .foregroundStyle(.white)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
    }
}
