import XCTest
@testable import ZenAvatar

final class ZenAvatarTests: XCTestCase {
    func testRecipeIsDeterministicForTheSameSeedVariantAndPalette() {
        let palette = AvatarPalette(colors: [.red, .green, .blue])
        let first = AvatarRecipe.generate(seed: "Alice", variant: .beam, palette: palette)
        let second = AvatarRecipe.generate(seed: "Alice", variant: .beam, palette: palette)

        XCTAssertEqual(first, second)
    }

    func testDifferentPaletteSizesCanProduceDifferentRecipes() {
        let short = AvatarPalette(colors: [.red, .green])
        let long = AvatarPalette(colors: [.red, .orange, .yellow, .blue, .mint])

        let first = AvatarRecipe.generate(seed: "Alice", variant: .ring, palette: short)
        let second = AvatarRecipe.generate(seed: "Alice", variant: .ring, palette: long)

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

    func testPixelRecipeHasFullGrid() {
        let recipe = AvatarRecipe.generate(seed: "Alice", variant: .pixel, palette: .default)

        guard case let .pixel(pixel) = recipe else {
            return XCTFail("Expected pixel recipe")
        }

        XCTAssertEqual(pixel.cellColors.count, 25)
    }
}
