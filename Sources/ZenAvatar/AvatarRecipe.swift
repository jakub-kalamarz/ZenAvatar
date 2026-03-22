import Foundation

struct BeamRecipe: Equatable {
    static func generate(seed: String, palette: AvatarPalette) -> BeamRecipe {
        var rng = AvatarRNG(seed: seed)
        return BeamRecipe.generate(using: &rng, palette: palette)
    }

    // Colors
    let backgroundIndex: Int
    let wrapperColorIndex: Int
    // Wrapper transform (in 36×36 SVG units)
    let wrapperTranslateX: Double
    let wrapperTranslateY: Double
    let wrapperRotate: Double   // degrees
    let wrapperScale: Double
    let isCircle: Bool
    // Face
    let isMouthOpen: Bool
    let eyeSpread: Double       // 0...3
    let mouthSpread: Double     // 0...2
    let faceRotate: Double      // degrees -4...4
    let faceTranslateX: Double
    let faceTranslateY: Double

    static func generate(using rng: inout AvatarRNG, palette: AvatarPalette) -> BeamRecipe {
        var used: Set<Int> = []
        let paletteCount = palette.count
        let backgroundIndex = rng.nextColorIndex(excluding: &used, count: paletteCount)
        let wrapperColorIndex = rng.nextColorIndex(excluding: &used, count: paletteCount)

        let size = 36.0
        let preX = rng.nextDouble(in: 0...10)
        let wrapperTranslateX = preX < 5 ? preX + size / 9 : preX
        let preY = rng.nextDouble(in: 0...10)
        let wrapperTranslateY = preY < 5 ? preY + size / 9 : preY

        let wrapperRotate = rng.nextDouble(in: 0...360)
        let wrapperScale = 1.0 + rng.nextDouble(in: 0...(size / 12)) / 10.0
        let isCircle = rng.nextBool(probability: 0.5)
        let isMouthOpen = rng.nextBool(probability: 0.5)

        let eyeSpread = rng.nextDouble(in: 0...3)
        let mouthSpread = rng.nextDouble(in: 0...2)
        let faceRotate = rng.nextDouble(in: -4...4)
        let faceTranslateX = wrapperTranslateX > size / 6
            ? wrapperTranslateX / 2
            : rng.nextDouble(in: 0...8)
        let faceTranslateY = wrapperTranslateY > size / 6
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
