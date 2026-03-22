# ZenAvatar

Deterministic SwiftUI avatars for Apple apps.

## Requirements

- iOS 15+
- macOS 12+
- Swift 6.2 toolchain

## Installation

Add the package in Xcode using the GitHub repository URL, or declare it in `Package.swift`:

```swift
.package(url: "https://github.com/jakub-kalamarz/ZenAvatar.git", from: "2.0.0")
```

Then add `ZenAvatar` to your target dependencies.

## Usage

```swift
import ZenAvatar

let palette = AvatarPalette(colors: [.red, .orange, .yellow])

AvatarView(
    seed: "Alice",
    size: 64,
    palette: palette
)
```

ZenAvatar currently exposes a single `.beam` style.

If a palette has fewer colors than `.beam` uses, ZenAvatar reuses colors cyclically.
