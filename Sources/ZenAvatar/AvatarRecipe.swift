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
    // Colors
    let backgroundIndex: Int
    let wrapperColorIndex: Int
    // Wrapper transform (in 36×36 SVG units)
    let wrapperTranslateX: Double
    let wrapperTranslateY: Double
    let wrapperRotate: Double   // degrees
    let wrapperScale: Double
    let isCircle: Bool          // wrapper corner radius: fully round vs SIZE/6
    // Face
    let isMouthOpen: Bool
    let eyeSpread: Double       // 0…5
    let mouthSpread: Double     // 0…3
    let faceRotate: Double      // degrees 0…10
    let faceTranslateX: Double
    let faceTranslateY: Double

    static func generate(using rng: inout AvatarRNG, palette: AvatarPalette) -> BeamRecipe {
        var used: Set<Int> = []
        let paletteCount = palette.count
        let backgroundIndex = rng.nextColorIndex(excluding: &used, count: paletteCount)
        let wrapperColorIndex = rng.nextColorIndex(excluding: &used, count: paletteCount)

        let SIZE = 36.0

        let preX = rng.nextDouble(in: 0...10)
        let wrapperTranslateX = preX < 5 ? preX + SIZE / 9 : preX
        let preY = rng.nextDouble(in: 0...10)
        let wrapperTranslateY = preY < 5 ? preY + SIZE / 9 : preY

        let wrapperRotate = rng.nextDouble(in: 0...360)
        let wrapperScale = 1.0 + rng.nextDouble(in: 0...(SIZE / 12)) / 10.0
        let isCircle = rng.nextBool(probability: 0.5)
        let isMouthOpen = rng.nextBool(probability: 0.5)

        let eyeSpread = rng.nextDouble(in: 0...5)
        let mouthSpread = rng.nextDouble(in: 0...3)
        let faceRotate = rng.nextDouble(in: 0...10)

        let faceTranslateX = wrapperTranslateX > SIZE / 6
            ? wrapperTranslateX / 2
            : rng.nextDouble(in: 0...8)
        let faceTranslateY = wrapperTranslateY > SIZE / 6
            ? wrapperTranslateY / 2
            : rng.nextDouble(in: 0...7)

        return BeamRecipe(
            backgroundIndex: backgroundIndex,
            wrapperColorIndex: wrapperColorIndex,
            wrapperTranslateX: wrapperTranslateX,
            wrapperTranslateY: wrapperTranslateY,
            wrapperRotate: wrapperRotate,
            wrapperScale: wrapperScale,
            isCircle: isCircle,
            isMouthOpen: isMouthOpen,
            eyeSpread: eyeSpread,
            mouthSpread: mouthSpread,
            faceRotate: faceRotate,
            faceTranslateX: faceTranslateX,
            faceTranslateY: faceTranslateY
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
