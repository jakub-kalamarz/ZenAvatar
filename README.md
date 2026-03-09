# ZenAvatar

Deterministic SwiftUI avatars for Apple apps.

## Requirements

- iOS 15+
- macOS 12+
- Swift 6.2 toolchain

## Installation

Add the package in Xcode using the GitHub repository URL, or declare it in `Package.swift`:

```swift
.package(url: "https://github.com/jakub-kalamarz/ZenAvatar.git", from: "1.0.0")
```

Then add `ZenAvatar` to your target dependencies.

## Usage

```swift
import ZenAvatar

let palette = AvatarPalette(colors: [.red, .orange, .yellow])

AvatarView(
    seed: "Alice",
    size: 64,
    variant: .beam,
    palette: palette
)
```

If a palette has fewer colors than a variant would ideally use, ZenAvatar reuses colors cyclically.
