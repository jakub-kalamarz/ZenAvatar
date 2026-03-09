import SwiftUI

public enum AvatarVariant: String, CaseIterable, Sendable {
    case pixel
    case beam
    case ring
}

public struct AvatarView: View {
    private let size: CGFloat
    private let palette: AvatarPalette
    private let recipe: AvatarRecipe

    public init(
        seed: String,
        size: CGFloat,
        variant: AvatarVariant = .pixel,
        palette: AvatarPalette = .default
    ) {
        let trimmed = seed.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedSeed = trimmed.isEmpty ? "Player" : trimmed
        self.size = size
        self.palette = palette
        self.recipe = AvatarRecipe.generate(seed: normalizedSeed, variant: variant, palette: palette)
    }

    public var body: some View {
        Group {
            switch recipe {
            case .pixel(let recipe):
                PixelAvatar(recipe: recipe, size: size, palette: palette)
            case .beam(let recipe):
                BeamAvatar(recipe: recipe, size: size, palette: palette)
            case .ring(let recipe):
                RingAvatar(recipe: recipe, size: size, palette: palette)
            }
        }
        .frame(width: size, height: size)
    }
}

private struct PixelAvatar: View {
    let recipe: PixelRecipe
    let size: CGFloat
    let palette: AvatarPalette

    private var background: Color {
        let base = palette.color(at: recipe.backgroundIndex)
        return base.mixed(with: .white, ratio: 0.65).color
    }

    var body: some View {
        GeometryReader { proxy in
            let dimension = min(proxy.size.width, proxy.size.height)
            let contentSize = dimension * 0.86
            let cellSize = contentSize / 5
            let offset = (dimension - contentSize) / 2

            ZStack {
                Circle()
                    .fill(background)
                    .frame(width: dimension, height: dimension)

                ForEach(0..<25, id: \.self) { index in
                    let colorIndex = recipe.cellColors[index]
                    if colorIndex >= 0 {
                        let row = index / 5
                        let col = index % 5
                        Rectangle()
                            .fill(palette.color(at: colorIndex).color)
                            .frame(width: cellSize, height: cellSize)
                            .position(
                                x: offset + (CGFloat(col) * cellSize) + cellSize / 2,
                                y: offset + (CGFloat(row) * cellSize) + cellSize / 2
                            )
                    }
                }
            }
            .frame(width: dimension, height: dimension)
            .clipShape(Circle())
        }
    }
}

private struct BeamAvatar: View {
    let recipe: BeamRecipe
    let size: CGFloat
    let palette: AvatarPalette

    var body: some View {
        ZStack {
            Circle()
                .fill(palette.color(at: recipe.baseIndex).color)

            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(palette.color(at: recipe.bar1Index).color)
                .frame(width: size * CGFloat(recipe.bar1Width), height: size * CGFloat(recipe.bar1Height))
                .rotationEffect(.degrees(45))
                .offset(x: size * CGFloat(recipe.bar1OffsetX), y: size * CGFloat(recipe.bar1OffsetY))

            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(palette.color(at: recipe.bar2Index).color)
                .frame(width: size * CGFloat(recipe.bar2Width), height: size * CGFloat(recipe.bar2Height))
                .rotationEffect(.degrees(-45))
                .offset(x: size * CGFloat(recipe.bar2OffsetX), y: size * CGFloat(recipe.bar2OffsetY))

            Circle()
                .fill(palette.color(at: recipe.accentIndex).color)
                .frame(width: size * CGFloat(recipe.accentSize), height: size * CGFloat(recipe.accentSize))
                .offset(x: size * CGFloat(recipe.accentOffsetX), y: size * CGFloat(recipe.accentOffsetY))
        }
        .clipShape(Circle())
    }
}

private struct RingAvatar: View {
    let recipe: RingRecipe
    let size: CGFloat
    let palette: AvatarPalette

    private var background: Color {
        let base = palette.color(at: recipe.backgroundIndex)
        return base.mixed(with: .white, ratio: 0.7).color
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(background)

            Circle()
                .stroke(palette.color(at: recipe.outerIndex).color, lineWidth: size * CGFloat(recipe.outerWidth))

            Circle()
                .stroke(palette.color(at: recipe.midIndex).color, lineWidth: size * CGFloat(recipe.midWidth))
                .scaleEffect(CGFloat(recipe.midScale))

            Circle()
                .stroke(palette.color(at: recipe.innerIndex).color, lineWidth: size * CGFloat(recipe.innerWidth))
                .scaleEffect(CGFloat(recipe.innerScale))

            Circle()
                .fill(palette.color(at: recipe.centerIndex).color)
                .frame(width: size * CGFloat(recipe.centerScale), height: size * CGFloat(recipe.centerScale))
        }
        .clipShape(Circle())
    }
}
