import SwiftUI

public struct AvatarColor: Equatable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double

    public init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    var color: Color {
        Color(red: red, green: green, blue: blue)
    }

    var isLight: Bool {
        red * 0.299 + green * 0.587 + blue * 0.114 >= 128.0 / 255.0
    }

    func mixed(with other: AvatarColor, ratio: Double) -> AvatarColor {
        let clamped = min(max(ratio, 0), 1)
        return AvatarColor(
            red: red + (other.red - red) * clamped,
            green: green + (other.green - green) * clamped,
            blue: blue + (other.blue - blue) * clamped
        )
    }
}

public extension AvatarColor {
    static let blue = AvatarColor(red: 0.00, green: 0.48, blue: 1.00)
    static let green = AvatarColor(red: 0.20, green: 0.78, blue: 0.35)
    static let orange = AvatarColor(red: 1.00, green: 0.58, blue: 0.00)
    static let red = AvatarColor(red: 1.00, green: 0.23, blue: 0.19)
    static let pink = AvatarColor(red: 1.00, green: 0.18, blue: 0.33)
    static let purple = AvatarColor(red: 0.69, green: 0.32, blue: 0.87)
    static let indigo = AvatarColor(red: 0.35, green: 0.34, blue: 0.84)
    static let teal = AvatarColor(red: 0.35, green: 0.78, blue: 0.98)
    static let yellow = AvatarColor(red: 1.00, green: 0.80, blue: 0.00)
    static let gray = AvatarColor(red: 0.56, green: 0.56, blue: 0.58)
    static let cyan = AvatarColor(red: 0.20, green: 0.68, blue: 0.90)
    static let mint = AvatarColor(red: 0.00, green: 0.78, blue: 0.74)
    static let white = AvatarColor(red: 1.00, green: 1.00, blue: 1.00)
}

public struct AvatarPalette: Equatable, Sendable {
    private let colors: [AvatarColor]

    public static let `default` = AvatarPalette(colors: [
        .blue, .green, .orange, .red, .pink, .purple,
        .indigo, .teal, .yellow, .gray, .cyan, .mint,
    ])

    public init(colors: [AvatarColor]) {
        self.colors = colors.isEmpty ? Self.default.colors : colors
    }

    public func color(at index: Int) -> AvatarColor {
        guard !colors.isEmpty else {
            return Self.default.color(at: index)
        }

        let safeIndex = ((index % colors.count) + colors.count) % colors.count
        return colors[safeIndex]
    }

    var count: Int {
        colors.count
    }
}
