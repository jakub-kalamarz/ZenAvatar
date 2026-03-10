import SwiftUI

public enum AvatarVariant: String, CaseIterable, Sendable {
    case pixel
    case beam
    case ring
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
    private let recipe: AvatarRecipe
    private let shape: AvatarShape

    public init(
        seed: String,
        size: CGFloat,
        variant: AvatarVariant = .pixel,
        palette: AvatarPalette = .default,
        shape: AvatarShape = .circle
    ) {
        let trimmed = seed.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedSeed = trimmed.isEmpty ? "Player" : trimmed
        self.size = size
        self.palette = palette
        self.shape = shape
        self.recipe = AvatarRecipe.generate(seed: normalizedSeed, variant: variant, palette: palette)
    }

    public var body: some View {
        Group {
            switch recipe {
            case .pixel(let recipe):
                PixelAvatar(recipe: recipe, size: size, palette: palette, shape: shape)
            case .beam(let recipe):
                BeamAvatar(recipe: recipe, size: size, palette: palette, shape: shape)
            case .ring(let recipe):
                RingAvatar(recipe: recipe, size: size, palette: palette, shape: shape)
            }
        }
        .frame(width: size, height: size)
    }
}

private struct PixelAvatar: View {
    let recipe: PixelRecipe
    let size: CGFloat
    let palette: AvatarPalette
    let shape: AvatarShape

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
                AvatarClipShape(shape: shape)
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
            .clipShape(AvatarClipShape(shape: shape))
        }
    }
}

private struct BeamAvatar: View {
    let recipe: BeamRecipe
    let size: CGFloat
    let palette: AvatarPalette
    let shape: AvatarShape

    var body: some View {
        Canvas { context, canvasSize in
            // All coordinates are in the 36×36 SVG unit space, scaled to canvas.
            let s = canvasSize.width / 36.0
            let SIZE = 36.0 * s
            let cx = SIZE / 2
            let cy = SIZE / 2
            let fullRect = CGRect(origin: .zero, size: canvasSize)

            // ── Clip to avatar shape ──────────────────────────────────────────
            switch shape {
            case .circle: context.clip(to: Path(ellipseIn: fullRect))
            case .square:  context.clip(to: Path(fullRect))
            }

            // ── 1. Background ─────────────────────────────────────────────────
            context.fill(Path(fullRect), with: .color(palette.color(at: recipe.backgroundIndex).color))

            // ── 2. Wrapper ────────────────────────────────────────────────────
            // SVG transform: translate(tx ty) rotate(r cx cy) scale(sw)
            // Equivalent: T(tx,ty) · T(cx,cy) · R(r) · T(-cx,-cy) · S(sw)
            let tx = recipe.wrapperTranslateX * s
            let ty = recipe.wrapperTranslateY * s
            let wr = Angle.degrees(recipe.wrapperRotate)
            let sw = recipe.wrapperScale

            var wrapperCtx = context
            wrapperCtx.translateBy(x: tx + cx, y: ty + cy)
            wrapperCtx.rotate(by: wr)
            wrapperCtx.translateBy(x: -cx, y: -cy)
            wrapperCtx.scaleBy(x: sw, y: sw)

            let wrapperCorner = recipe.isCircle ? SIZE : SIZE / 6
            wrapperCtx.fill(
                Path(roundedRect: fullRect, cornerRadius: wrapperCorner),
                with: .color(palette.color(at: recipe.wrapperColorIndex).color)
            )

            // ── 3. Face ───────────────────────────────────────────────────────
            // Face color = contrast against wrapper (black if wrapper is light, white if dark)
            let faceColor: Color = palette.color(at: recipe.wrapperColorIndex).isLight ? .black : .white

            // SVG transform: translate(ftx fty) rotate(fr cx cy)
            let ftx = recipe.faceTranslateX * s
            let fty = recipe.faceTranslateY * s
            let fr = Angle.degrees(recipe.faceRotate)

            var faceCtx = context
            faceCtx.translateBy(x: ftx + cx, y: fty + cy)
            faceCtx.rotate(by: fr)
            faceCtx.translateBy(x: -cx, y: -cy)

            // Eyes — each is a 1.5×2 rounded rect
            let eyeY = 14 * s
            let eyeW = 1.5 * s
            let eyeH = 2.0 * s
            let eyeR = 1.0 * s
            faceCtx.fill(
                Path(roundedRect: CGRect(x: (14 - recipe.eyeSpread) * s, y: eyeY, width: eyeW, height: eyeH), cornerRadius: eyeR),
                with: .color(faceColor)
            )
            faceCtx.fill(
                Path(roundedRect: CGRect(x: (20 + recipe.eyeSpread) * s, y: eyeY, width: eyeW, height: eyeH), cornerRadius: eyeR),
                with: .color(faceColor)
            )

            // Mouth
            let my = (19 + recipe.mouthSpread) * s
            var mouth = Path()
            if recipe.isMouthOpen {
                // M15,my c2,1 4,1 6,0  (open smile stroke)
                mouth.move(to: CGPoint(x: 15 * s, y: my))
                mouth.addCurve(
                    to: CGPoint(x: 21 * s, y: my),
                    control1: CGPoint(x: 17 * s, y: my + s),
                    control2: CGPoint(x: 19 * s, y: my + s)
                )
                faceCtx.stroke(mouth, with: .color(faceColor), style: StrokeStyle(lineWidth: s, lineCap: .round))
            } else {
                // M13,my a1,0.75 0 0,0 10,0 (closed smile fill)
                // SVG auto-scales radii: effective rx=5, ry=3.75 in SVG units.
                // Quadratic control chosen so the midpoint lands at (18, my + 3.75·s).
                mouth.move(to: CGPoint(x: 13 * s, y: my))
                mouth.addQuadCurve(
                    to: CGPoint(x: 23 * s, y: my),
                    control: CGPoint(x: 18 * s, y: my + 7.5 * s)
                )
                faceCtx.fill(mouth, with: .color(faceColor))
            }
        }
        .frame(width: size, height: size)
    }
}

private struct RingAvatar: View {
    let recipe: RingRecipe
    let size: CGFloat
    let palette: AvatarPalette
    let shape: AvatarShape

    private var background: Color {
        let base = palette.color(at: recipe.backgroundIndex)
        return base.mixed(with: .white, ratio: 0.7).color
    }

    var body: some View {
        ZStack {
            AvatarClipShape(shape: shape)
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
        .clipShape(AvatarClipShape(shape: shape))
    }
}
