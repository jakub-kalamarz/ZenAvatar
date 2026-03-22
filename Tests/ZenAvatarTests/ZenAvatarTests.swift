import XCTest
@testable import ZenAvatar

final class ZenAvatarTests: XCTestCase {
    func testAvatarVariantExposesOnlyBeam() {
        XCTAssertEqual(AvatarVariant.allCases, [.beam])
    }

    func testRecipeIsDeterministicForTheSameSeedAndPalette() {
        let palette = AvatarPalette(colors: [.red, .green, .blue])
        let first = BeamRecipe.generate(seed: "Alice", palette: palette)
        let second = BeamRecipe.generate(seed: "Alice", palette: palette)

        XCTAssertEqual(first, second)
    }

    func testDifferentPaletteSizesCanProduceDifferentRecipes() {
        let short = AvatarPalette(colors: [.red, .green])
        let long = AvatarPalette(colors: [.red, .orange, .yellow, .blue, .mint])

        let first = BeamRecipe.generate(seed: "Alice", palette: short)
        let second = BeamRecipe.generate(seed: "Alice", palette: long)

        XCTAssertNotEqual(first, second)
    }

    func testPaletteCyclesWhenTooShort() {
        let palette = AvatarPalette(colors: [.red, .green])

        XCTAssertEqual(palette.color(at: 0), .red)
        XCTAssertEqual(palette.color(at: 1), .green)
        XCTAssertEqual(palette.color(at: 2), .red)
        XCTAssertEqual(palette.color(at: 3), .green)
    }

    func testEmptyPaletteFallsBackToDefault() {
        let fallback = AvatarPalette(colors: [])

        XCTAssertEqual(fallback.color(at: 0), AvatarPalette.default.color(at: 0))
    }

    func testBeamRecipeUsesNewFaceRanges() {
        let palette = AvatarPalette(colors: [.red, .orange, .yellow, .green, .blue])
        let beam = BeamRecipe.generate(seed: "Alice", palette: palette)

        XCTAssertTrue((0...3).contains(beam.eyeSpread))
        XCTAssertTrue((0...2).contains(beam.mouthSpread))
        XCTAssertTrue((-4...4).contains(beam.faceRotate))
    }

    func testBeamRecipePreservesClassicWrapperShapeVariation() {
        let seeds = ["Alice", "Bruno", "Chloe", "Diana", "Eve", "Finn", "Grace", "Hiro"]
        let shapes = Set(seeds.map { BeamRecipe.generate(seed: $0, palette: .default).isCircle })

        XCTAssertEqual(shapes, [false, true])
    }
}
