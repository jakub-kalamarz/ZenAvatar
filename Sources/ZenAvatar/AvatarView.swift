import SwiftUI

public enum AvatarVariant: String, CaseIterable, Sendable {
    case beam
}

public enum AvatarShape: Sendable {
    case circle
    case square
}

private struct AvatarClipShape: Shape {
    let shape: AvatarShape
    func path(in rect: CGRect) -> Path {
        switch shape {
        case .circle: Circle().path(in: rect)
        case .square: Rectangle().path(in: rect)
        }
    }
}

public struct AvatarView: View {
    private let size: CGFloat
    private let palette: AvatarPalette
    private let recipe: BeamRecipe
    private let shape: AvatarShape

    public init(
        seed: String,
        size: CGFloat,
        variant: AvatarVariant = .beam,
        palette: AvatarPalette = .default,
        shape: AvatarShape = .circle
    ) {
        self.init(seed: seed, size: size, palette: palette, shape: shape)
    }

    public init(
        seed: String,
        size: CGFloat,
        palette: AvatarPalette = .default,
        shape: AvatarShape = .circle
    ) {
        let trimmed = seed.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedSeed = trimmed.isEmpty ? "Player" : trimmed
        self.size = size
        self.palette = palette
        self.shape = shape
        self.recipe = BeamRecipe.generate(seed: normalizedSeed, palette: palette)
    }

    public var body: some View {
        BeamAvatar(recipe: recipe, size: size, palette: palette, shape: shape)
            .frame(width: size, height: size)
    }
}

private struct BeamAvatar: View {
    let recipe: BeamRecipe
    let size: CGFloat
    let palette: AvatarPalette
    let shape: AvatarShape

    var body: some View {
        Canvas { context, canvasSize in
            let s = canvasSize.width / 36.0
            let size = 36.0 * s
            let cx = size / 2
            let cy = size / 2
            let fullRect = CGRect(origin: .zero, size: canvasSize)

            switch shape {
            case .circle: context.clip(to: Path(ellipseIn: fullRect))
            case .square: context.clip(to: Path(fullRect))
            }

            context.fill(
                Path(fullRect),
                with: .color(palette.color(at: recipe.backgroundIndex).mixed(with: .white, ratio: 0.65).color)
            )

            let tx = recipe.wrapperTranslateX * s
            let ty = recipe.wrapperTranslateY * s
            let wr = Angle.degrees(recipe.wrapperRotate)
            let sw = recipe.wrapperScale

            var wrapperCtx = context
            wrapperCtx.translateBy(x: tx + cx, y: ty + cy)
            wrapperCtx.rotate(by: wr)
            wrapperCtx.translateBy(x: -cx, y: -cy)
            wrapperCtx.scaleBy(x: sw, y: sw)

            let wrapperCorner = recipe.isCircle ? size : size / 6
            wrapperCtx.fill(
                Path(roundedRect: fullRect, cornerRadius: wrapperCorner),
                with: .color(palette.color(at: recipe.wrapperColorIndex).color)
            )

            let faceColor: Color = palette.color(at: recipe.wrapperColorIndex).isLight ? .black : .white
            let ftx = recipe.faceTranslateX * s
            let fty = recipe.faceTranslateY * s
            let fr = Angle.degrees(recipe.faceRotate)

            var faceCtx = context
            faceCtx.translateBy(x: ftx + cx, y: fty + cy)
            faceCtx.rotate(by: fr)
            faceCtx.translateBy(x: -cx, y: -cy)

            let eyeY = 13.0 * s
            let eyeW = 2.0 * s
            let eyeH = 2.5 * s
            let eyeR = 1.0 * s
            let eyeSpread = (2.35 + recipe.eyeSpread * 0.2) * s
            faceCtx.fill(
                Path(roundedRect: CGRect(x: cx - eyeSpread - eyeW / 2, y: eyeY, width: eyeW, height: eyeH), cornerRadius: eyeR),
                with: .color(faceColor)
            )
            faceCtx.fill(
                Path(roundedRect: CGRect(x: cx + eyeSpread - eyeW / 2, y: eyeY, width: eyeW, height: eyeH), cornerRadius: eyeR),
                with: .color(faceColor)
            )

            let mouthY = (19.7 + recipe.mouthSpread * 0.22) * s
            var mouth = Path()
            if recipe.isMouthOpen {
                mouth.move(to: CGPoint(x: 15.0 * s, y: mouthY))
                mouth.addCurve(
                    to: CGPoint(x: 21.0 * s, y: mouthY),
                    control1: CGPoint(x: 16.8 * s, y: mouthY + 1.0 * s),
                    control2: CGPoint(x: 19.2 * s, y: mouthY + 1.0 * s)
                )
                faceCtx.stroke(mouth, with: .color(faceColor), style: StrokeStyle(lineWidth: 1.05 * s, lineCap: .round))
            } else {
                mouth.move(to: CGPoint(x: 14.8 * s, y: mouthY))
                mouth.addQuadCurve(
                    to: CGPoint(x: 21.2 * s, y: mouthY),
                    control: CGPoint(x: 18.0 * s, y: mouthY + 1.45 * s)
                )
                faceCtx.fill(mouth, with: .color(faceColor))
            }
        }
        .frame(width: size, height: size)
    }
}
