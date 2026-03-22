import SwiftUI

internal struct BeamAvatarPreviewHost: View {
    private let backgroundColor = Color(red: 0.96, green: 0.97, blue: 0.98)
    private let seeds = ["Alice", "Bruno", "Chloe", "Diana"]
    private let palette = AvatarPalette(colors: [.blue, .cyan, .mint, .indigo, .purple])

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Large Beam")
                        .font(.headline)
                    AvatarView(seed: "Alice", size: 180, palette: palette)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Beam Grid")
                        .font(.headline)

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 88), spacing: 16)],
                        spacing: 16
                    ) {
                        ForEach(seeds, id: \.self) { seed in
                            VStack(spacing: 8) {
                                AvatarView(seed: seed, size: 88, palette: palette)
                                Text(seed)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(backgroundColor.ignoresSafeArea())
    }
}

#if DEBUG
#Preview("Large Beam") {
    BeamAvatarPreviewHost()
}

#Preview("Beam Grid") {
    BeamAvatarPreviewHost()
}
#endif
