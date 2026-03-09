import Foundation

enum AvatarRecipe: Equatable {
    case pixel(PixelRecipe)
    case beam(BeamRecipe)
    case ring(RingRecipe)

    static func generate(seed: String, variant: AvatarVariant, palette: AvatarPalette) -> AvatarRecipe {
        var rng = AvatarRNG(seed: seed)
        switch variant {
        case .pixel:
            return .pixel(PixelRecipe.generate(using: &rng, palette: palette))
        case .beam:
            return .beam(BeamRecipe.generate(using: &rng, palette: palette))
        case .ring:
            return .ring(RingRecipe.generate(using: &rng, palette: palette))
        }
    }
}

struct PixelRecipe: Equatable {
    let backgroundIndex: Int
    let cellColors: [Int]

    static func generate(using rng: inout AvatarRNG, palette: AvatarPalette) -> PixelRecipe {
        var used: Set<Int> = []
        let paletteCount = palette.count
        let backgroundIndex = rng.nextColorIndex(excluding: &used, count: paletteCount)
        let primaryIndex = rng.nextColorIndex(excluding: &used, count: paletteCount)
        let secondaryIndex = rng.nextColorIndex(excluding: &used, count: paletteCount)

        var cells = Array(repeating: -1, count: 25)
        for row in 0..<5 {
            for col in 0..<3 {
                let isCenter = row == 2 && col == 2
                let shouldFill = isCenter || rng.nextBool(probability: 0.6)
                if shouldFill {
                    let colorIndex = rng.nextBool(probability: 0.7) ? primaryIndex : secondaryIndex
                    let leftIndex = row * 5 + col
                    let rightIndex = row * 5 + (4 - col)
                    cells[leftIndex] = colorIndex
                    cells[rightIndex] = colorIndex
                }
            }
        }

        return PixelRecipe(backgroundIndex: backgroundIndex, cellColors: cells)
    }
}

struct BeamRecipe: Equatable {
    let baseIndex: Int
    let bar1Index: Int
    let bar2Index: Int
    let accentIndex: Int
    let bar1Width: Double
    let bar1Height: Double
    let bar2Width: Double
    let bar2Height: Double
    let bar1OffsetX: Double
    let bar1OffsetY: Double
    let bar2OffsetX: Double
    let bar2OffsetY: Double
    let accentSize: Double
    let accentOffsetX: Double
    let accentOffsetY: Double

    static func generate(using rng: inout AvatarRNG, palette: AvatarPalette) -> BeamRecipe {
        var used: Set<Int> = []
        let paletteCount = palette.count
        let baseIndex = rng.nextColorIndex(excluding: &used, count: paletteCount)
        let bar1Index = rng.nextColorIndex(excluding: &used, count: paletteCount)
        let bar2Index = rng.nextColorIndex(excluding: &used, count: paletteCount)
        let accentIndex = rng.nextColorIndex(excluding: &used, count: paletteCount)

        return BeamRecipe(
            baseIndex: baseIndex,
            bar1Index: bar1Index,
            bar2Index: bar2Index,
            accentIndex: accentIndex,
            bar1Width: rng.nextDouble(in: 0.90...1.10),
            bar1Height: rng.nextDouble(in: 0.22...0.32),
            bar2Width: rng.nextDouble(in: 0.85...1.05),
            bar2Height: rng.nextDouble(in: 0.22...0.32),
            bar1OffsetX: rng.nextDouble(in: -0.10...0.10),
            bar1OffsetY: rng.nextDouble(in: -0.10...0.10),
            bar2OffsetX: rng.nextDouble(in: -0.10...0.10),
            bar2OffsetY: rng.nextDouble(in: -0.10...0.10),
            accentSize: rng.nextDouble(in: 0.18...0.26),
            accentOffsetX: rng.nextDouble(in: -0.25...0.25),
            accentOffsetY: rng.nextDouble(in: -0.25...0.25)
        )
    }
}

struct RingRecipe: Equatable {
    let backgroundIndex: Int
    let outerIndex: Int
    let midIndex: Int
    let innerIndex: Int
    let centerIndex: Int
    let outerWidth: Double
    let midWidth: Double
    let innerWidth: Double
    let midScale: Double
    let innerScale: Double
    let centerScale: Double

    static func generate(using rng: inout AvatarRNG, palette: AvatarPalette) -> RingRecipe {
        var used: Set<Int> = []
        let paletteCount = palette.count
        let backgroundIndex = rng.nextColorIndex(excluding: &used, count: paletteCount)
        let outerIndex = rng.nextColorIndex(excluding: &used, count: paletteCount)
        let midIndex = rng.nextColorIndex(excluding: &used, count: paletteCount)
        let innerIndex = rng.nextColorIndex(excluding: &used, count: paletteCount)
        let centerIndex = rng.nextColorIndex(excluding: &used, count: paletteCount)

        return RingRecipe(
            backgroundIndex: backgroundIndex,
            outerIndex: outerIndex,
            midIndex: midIndex,
            innerIndex: innerIndex,
            centerIndex: centerIndex,
            outerWidth: rng.nextDouble(in: 0.10...0.14),
            midWidth: rng.nextDouble(in: 0.08...0.12),
            innerWidth: rng.nextDouble(in: 0.06...0.10),
            midScale: rng.nextDouble(in: 0.68...0.78),
            innerScale: rng.nextDouble(in: 0.40...0.52),
            centerScale: rng.nextDouble(in: 0.16...0.22)
        )
    }
}
